using System.Net;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Roommater.API.Data;
using Roommater.API.DTOs.Chat;
using Roommater.API.Middleware;
using Roommater.API.Models;

namespace Roommater.API.Services;

public class ChatService : IChatService
{
    private readonly AppDbContext _db;
    private readonly IMapper _mapper;

    public ChatService(AppDbContext db, IMapper mapper)
    {
        _db = db;
        _mapper = mapper;
    }

    public async Task<List<ChatDto>> GetChatsAsync(Guid userId, Guid? targetUserId = null, int page = 1, int pageSize = 50)
    {
        var query = _db.Chats
            .Include(c => c.Participants)
            .Include(c => c.Messages.OrderByDescending(m => m.SentAt).Take(1))
            .Where(c => c.Participants.Any(p => p.UserId == userId));

        if (targetUserId.HasValue)
        {
            query = query.Where(c => c.Participants.Any(p => p.UserId == targetUserId.Value));
        }

        var chats = await query
            .OrderByDescending(c => c.CreatedAt)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 100))
            .Take(Math.Clamp(pageSize, 1, 100))
            .ToListAsync();

        return chats.Select(c =>
        {
            var lastMsg = c.Messages.FirstOrDefault();
            return new ChatDto
            {
                Id = c.Id,
                CreatedAt = c.CreatedAt,
                ParticipantIds = c.Participants.Select(p => p.UserId).ToList(),
                LastMessage = lastMsg?.Text,
                LastMessageAt = lastMsg?.SentAt
            };
        }).ToList();
    }

    public async Task<List<MessageDto>> GetMessagesAsync(Guid chatId, Guid userId, int page = 1, int pageSize = 100)
    {
        var inChat = await _db.ChatParticipants.AnyAsync(cp => cp.ChatId == chatId && cp.UserId == userId);
        if (!inChat)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "You are not part of this chat.");
        }

        var messages = await _db.Messages
            .Where(m => m.ChatId == chatId)
            .OrderBy(m => m.SentAt)
            .Skip((Math.Max(page, 1) - 1) * Math.Clamp(pageSize, 1, 200))
            .Take(Math.Clamp(pageSize, 1, 200))
            .ToListAsync();

        return messages.Select(_mapper.Map<MessageDto>).ToList();
    }

    public async Task<MessageDto> SendMessageAsync(Guid chatId, Guid userId, CreateMessageDto dto)
    {
        var inChat = await _db.ChatParticipants.AnyAsync(cp => cp.ChatId == chatId && cp.UserId == userId);
        if (!inChat)
        {
            throw new ApiException(HttpStatusCode.Forbidden, "You are not part of this chat.");
        }

        var message = new Message
        {
            ChatId = chatId,
            SenderId = userId,
            Text = dto.Text.Trim(),
            SentAt = DateTime.UtcNow
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();

        return _mapper.Map<MessageDto>(message);
    }

    public async Task<ChatDto> CreateOrGetChatAsync(Guid userId, CreateChatDto dto)
    {
        var participantIds = dto.ParticipantIds.Distinct().ToList();
        if (!participantIds.Contains(userId))
        {
            participantIds.Add(userId);
        }

        if (participantIds.Count < 2)
        {
            throw new ApiException(HttpStatusCode.BadRequest, "At least two participants are required.");
        }

        var existingChats = await _db.Chats
            .Include(c => c.Participants)
            .Where(c => c.Participants.Count == participantIds.Count)
            .ToListAsync();

        var existing = existingChats.FirstOrDefault(c =>
            c.Participants.Select(p => p.UserId).OrderBy(x => x).SequenceEqual(participantIds.OrderBy(x => x)));

        if (existing is not null)
        {
            return new ChatDto
            {
                Id = existing.Id,
                CreatedAt = existing.CreatedAt,
                ParticipantIds = existing.Participants.Select(p => p.UserId).ToList()
            };
        }

        var usersCount = await _db.Users.CountAsync(u => participantIds.Contains(u.Id));
        if (usersCount != participantIds.Count)
        {
            throw new ApiException(HttpStatusCode.BadRequest, "One or more participants do not exist.");
        }

        var chat = new Chat
        {
            Participants = participantIds.Select(id => new ChatParticipant { UserId = id }).ToList()
        };

        _db.Chats.Add(chat);
        await _db.SaveChangesAsync();

        return new ChatDto
        {
            Id = chat.Id,
            CreatedAt = chat.CreatedAt,
            ParticipantIds = participantIds
        };
    }
}
