namespace Roommater.API.DTOs.Expense;

public class BalanceDto
{
    public Guid FromUserId { get; set; }
    public Guid ToUserId { get; set; }
    public decimal Amount { get; set; }
}
