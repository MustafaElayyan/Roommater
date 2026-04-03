using Roommater.API.DTOs.Task;

namespace Roommater.API.Services;

public interface ITaskService
{
    Task<List<TaskDto>> GetTasksAsync(Guid householdId, Guid userId, bool myTasks = false, int page = 1, int pageSize = 50);
    Task<TaskDto> CreateTaskAsync(Guid householdId, Guid userId, CreateTaskDto dto);
    Task<TaskDto> UpdateTaskAsync(Guid householdId, Guid taskId, Guid userId, UpdateTaskDto dto);
    Task DeleteTaskAsync(Guid householdId, Guid taskId, Guid userId);
}
