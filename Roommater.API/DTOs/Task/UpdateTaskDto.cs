using System.ComponentModel.DataAnnotations;

namespace Roommater.API.DTOs.Task;

public class UpdateTaskDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Description { get; set; }

    public bool IsCompleted { get; set; }

    public DateTime? DueDate { get; set; }

    public Guid? AssignedToUserId { get; set; }
}
