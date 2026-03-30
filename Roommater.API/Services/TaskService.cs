using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Task;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class TaskService : ITaskService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public TaskService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<TaskDto>> GetTasksAsync(Guid householdId, Guid userId, bool myTasks = false, int page = 1, int pageSize = 50)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var query = _db.HouseholdTasks.Where(t => t.HouseholdId == householdId);
        if (myTasks)
        {
            query = query.Where(t => t.AssignedToUserId == userId);
        }

        var tasks = await query
            .OrderBy(t => t.IsCompleted)
            .ThenBy(t => t.DueDate)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return tasks.Select(_mapper.Map<TaskDto>).ToList();
    }

    public async Task<TaskDto> CreateTaskAsync(Guid householdId, Guid userId, CreateTaskDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        if (dto.AssignedToUserId.HasValue)
        {
            var assigneeInHousehold = await _db.Users.AnyAsync(u => u.Id == dto.AssignedToUserId && u.HouseholdId == householdId);
            if (!assigneeInHousehold)
            {
                throw new ApiException(HttpStatusCode.BadRequest, "Assigned user must belong to the same household.");
            }
        }

        var task = new HouseholdTask
        {
            HouseholdId = householdId,
            Title = dto.Title.Trim(),
            Description = dto.Description?.Trim(),
            DueDate = dto.DueDate,
            CreatedByUserId = userId,
            AssignedToUserId = dto.AssignedToUserId
        };

        _db.HouseholdTasks.Add(task);
        await _db.SaveChangesAsync();

        return _mapper.Map<TaskDto>(task);
    }

    public async Task<TaskDto> UpdateTaskAsync(Guid householdId, Guid taskId, Guid userId, UpdateTaskDto dto)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var task = await _db.HouseholdTasks.FirstOrDefaultAsync(t => t.Id == taskId && t.HouseholdId == householdId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "Task not found.");

        if (dto.AssignedToUserId.HasValue)
        {
            var assigneeInHousehold = await _db.Users.AnyAsync(u => u.Id == dto.AssignedToUserId && u.HouseholdId == householdId);
            if (!assigneeInHousehold)
            {
                throw new ApiException(HttpStatusCode.BadRequest, "Assigned user must belong to the same household.");
            }
        }

        task.Title = dto.Title.Trim();
        task.Description = dto.Description?.Trim();
        task.IsCompleted = dto.IsCompleted;
        task.DueDate = dto.DueDate;
        task.AssignedToUserId = dto.AssignedToUserId;

        await _db.SaveChangesAsync();

        return _mapper.Map<TaskDto>(task);
    }

    public async Task DeleteTaskAsync(Guid householdId, Guid taskId, Guid userId)
    {
        await ServiceGuards.EnsureHouseholdMemberAsync(_db, householdId, userId);

        var task = await _db.HouseholdTasks.FirstOrDefaultAsync(t => t.Id == taskId && t.HouseholdId == householdId)
                   ?? throw new ApiException(HttpStatusCode.NotFound, "Task not found.");

        _db.HouseholdTasks.Remove(task);
        await _db.SaveChangesAsync();
    }
}
