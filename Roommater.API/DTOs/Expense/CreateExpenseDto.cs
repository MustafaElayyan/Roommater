using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Expense;

public class CreateExpenseDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Range(0.01, 1000000)]
    public decimal Amount { get; set; }

    [MaxLength(80)]
    public string Category { get; set; } = "Household";

    [MaxLength(10)]
    public string Currency { get; set; } = "JOD";

    [Required]
    public List<CreateExpenseSplitDto> Splits { get; set; } = new();
}

public class CreateExpenseSplitDto
{
    [Required]
    public Guid OwedByUserId { get; set; }

    [Range(0.01, 1000000)]
    public decimal Amount { get; set; }
}
