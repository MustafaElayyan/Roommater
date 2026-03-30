using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Expense;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class ExpenseService : IExpenseService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public ExpenseService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<ExpenseDto>> GetExpensesAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var expenses = await _db.Expenses
            .Include(e => e.Splits)
            .Where(e => e.HouseholdId == householdId)
            .OrderByDescending(e => e.CreatedAt)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return expenses.Select(ToExpenseDto).ToList();
    }

    public async Task<List<BalanceDto>> GetBalancesAsync(Guid householdId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var expenses = await _db.Expenses
            .Include(e => e.Splits)
            .Where(e => e.HouseholdId == householdId)
            .ToListAsync();

        var balances = new Dictionary<(Guid from, Guid to), decimal>();

        foreach (var expense in expenses)
        {
            foreach (var split in expense.Splits.Where(s => !s.IsPaid))
            {
                if (split.OwedByUserId == expense.PaidByUserId)
                {
                    continue;
                }

                var key = (split.OwedByUserId, expense.PaidByUserId);
                balances.TryGetValue(key, out var current);
                balances[key] = current + split.Amount;
            }
        }

        return balances
            .Where(x => x.Value > 0)
            .Select(x => new BalanceDto
            {
                FromUserId = x.Key.from,
                ToUserId = x.Key.to,
                Amount = decimal.Round(x.Value, 2)
            })
            .OrderByDescending(x => x.Amount)
            .ToList();
    }

    public async Task<ExpenseDto> CreateExpenseAsync(Guid householdId, Guid userId, CreateExpenseDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        if (dto.Splits.Count == 0)
        {
            throw new ApiException(HttpStatusCode.BadRequest, "At least one split is required.");
        }

        var totalSplits = dto.Splits.Sum(s => s.Amount);
        if (decimal.Round(totalSplits, 2) != decimal.Round(dto.Amount, 2))
        {
            throw new ApiException(HttpStatusCode.BadRequest, "Splits total must equal expense amount.");
        }

        foreach (var split in dto.Splits)
        {
            var isMember = await _db.Users.AnyAsync(u => u.Id == split.OwedByUserId && u.HouseholdId == householdId);
            if (!isMember)
            {
                throw new ApiException(HttpStatusCode.BadRequest, "All split users must belong to this household.");
            }
        }

        var expense = new Expense
        {
            HouseholdId = householdId,
            Title = dto.Title.Trim(),
            Amount = dto.Amount,
            Category = dto.Category.Trim(),
            Currency = dto.Currency.Trim(),
            PaidByUserId = userId,
            Splits = dto.Splits.Select(s => new ExpenseSplit
            {
                OwedByUserId = s.OwedByUserId,
                Amount = s.Amount,
                IsPaid = false
            }).ToList()
        };

        _db.Expenses.Add(expense);
        await _db.SaveChangesAsync();

        return ToExpenseDto(expense);
    }

    public async Task MarkSplitPaidAsync(Guid householdId, Guid expenseId, Guid splitId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var split = await _db.ExpenseSplits
            .Include(s => s.Expense)
            .FirstOrDefaultAsync(s => s.Id == splitId && s.ExpenseId == expenseId && s.Expense!.HouseholdId == householdId)
            ?? throw new ApiException(HttpStatusCode.NotFound, "Expense split not found.");

        if (split.OwedByUserId != userId && split.Expense!.PaidByUserId != userId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only involved users can mark split as paid.");
        }

        split.IsPaid = true;
        await _db.SaveChangesAsync();
    }

    public async Task DeleteExpenseAsync(Guid householdId, Guid expenseId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var expense = await _db.Expenses.FirstOrDefaultAsync(e => e.Id == expenseId && e.HouseholdId == householdId)
                      ?? throw new ApiException(HttpStatusCode.NotFound, "Expense not found.");

        if (expense.PaidByUserId != userId)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "Only payer can delete expense.");
        }

        _db.Expenses.Remove(expense);
        await _db.SaveChangesAsync();
    }

    private ExpenseDto ToExpenseDto(Expense expense)
    {
        var dto = _mapper.Map<ExpenseDto>(expense);
        dto.Splits = expense.Splits.Select(s => new ExpenseSplitDto
        {
            Id = s.Id,
            OwedByUserId = s.OwedByUserId,
            Amount = s.Amount,
            IsPaid = s.IsPaid
        }).ToList();
        return dto;
    }
}
