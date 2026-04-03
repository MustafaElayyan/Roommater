using AutoMapper;
using Roommater.API.DTOs.Chat;
using Roommater.API.DTOs.Event;
using Roommater.API.DTOs.Expense;
using Roommater.API.DTOs.Grocery;
using Roommater.API.DTOs.Household;
using Roommater.API.DTOs.Listing;
using Roommater.API.DTOs.Notification;
using Roommater.API.DTOs.Task;
using Roommater.API.DTOs.User;
using Roommater.API.Models;

namespace Roommater.API.Mappings;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<User, UserDto>().ForMember(dest => dest.Uid, opt => opt.MapFrom(src => src.Id));
        CreateMap<Household, HouseholdDto>();
        CreateMap<HouseholdTask, TaskDto>();
        CreateMap<Event, EventDto>();
        CreateMap<GroceryItem, GroceryDto>();
        CreateMap<Expense, ExpenseDto>();
        CreateMap<Message, MessageDto>();
        CreateMap<Chat, ChatDto>();
        CreateMap<Listing, ListingDto>();
        CreateMap<Notification, NotificationDto>();
    }
}
