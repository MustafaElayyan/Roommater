using System.ComponentModel.DataAnnotations;
using Roommater.API.Models;

namespace Roommater.API.DTOs.Event;

public class RsvpDto
{
    [Required]
    public EventRsvpStatus Status { get; set; }
}
