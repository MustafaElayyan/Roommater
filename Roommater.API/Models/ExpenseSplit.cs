namespace Roommater.API.Models;

public class ExpenseSplit
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ExpenseId { get; set; }
    public Expense? Expense { get; set; }

    public Guid OwedByUserId { get; set; }
    public User? OwedByUser { get; set; }

    public decimal Amount { get; set; }

    public bool IsPaid { get; set; }
}
