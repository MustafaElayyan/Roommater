using Roommater.API.DTOs.Chat;

namespace Roommater.API.Services;

public interface IChatService
{
    Task<List<ChatDto>> GetChatsAsync(Guid userId, Guid? targetUserId = null, int page = 1, int pageSize = 50);
    Task<List<MessageDto>> GetMessagesAsync(Guid chatId, Guid userId, int page = 1, int pageSize = 100);
    Task<MessageDto> SendMessageAsync(Guid chatId, Guid userId, CreateMessageDto dto);
    Task<ChatDto> CreateOrGetChatAsync(Guid userId, CreateChatDto dto);
}
