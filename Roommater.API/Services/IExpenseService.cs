using Roommater.API.DTOs.Expense;

namespace Roommater.API.Services;

public interface IExpenseService
{
    Task<List<ExpenseDto>> GetExpensesAsync(Guid householdId, Guid userId, int page = 1, int pageSize = 50);
    Task<List<BalanceDto>> GetBalancesAsync(Guid householdId, Guid userId);
    Task<ExpenseDto> CreateExpenseAsync(Guid householdId, Guid userId, CreateExpenseDto dto);
    Task MarkSplitPaidAsync(Guid householdId, Guid expenseId, Guid splitId, Guid userId);
    Task DeleteExpenseAsync(Guid householdId, Guid expenseId, Guid userId);
}
