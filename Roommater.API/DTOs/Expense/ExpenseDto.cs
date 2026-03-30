namespace Roommater.API.DTOs.Expense;

public class ExpenseDto
{
    public Guid Id { get; set; }
    public Guid HouseholdId { get; set; }
    public string Title { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "JOD";
    public string Category { get; set; } = "Household";
    public Guid PaidByUserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<ExpenseSplitDto> Splits { get; set; } = new();
}

public class ExpenseSplitDto
{
    public Guid Id { get; set; }
    public Guid OwedByUserId { get; set; }
    public decimal Amount { get; set; }
    public bool IsPaid { get; set; }
}
