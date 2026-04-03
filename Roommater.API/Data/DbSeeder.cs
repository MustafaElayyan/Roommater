using Microsoft.EntityFrameworkCore;
using Roommater.API.Models;

namespace Roommater.API.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext context)
    {
        if (await context.Users.AnyAsync())
        {
            return;
        }

        var user1 = new User
        {
            Email = "alex@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password123!"),
            DisplayName = "Alex"
        };

        var user2 = new User
        {
            Email = "maya@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password123!"),
            DisplayName = "Maya"
        };

        var household = new Household
        {
            Name = "Downtown Flat",
            InviteCode = "RM123A",
            CreatedByUserId = user1.Id
        };

        user1.HouseholdId = household.Id;
        user2.HouseholdId = household.Id;

        var task = new HouseholdTask
        {
            HouseholdId = household.Id,
            Title = "Take out trash",
            Description = "Before 9 PM",
            DueDate = DateTime.UtcNow.AddDays(1),
            CreatedByUserId = user1.Id,
            AssignedToUserId = user2.Id
        };

        var houseEvent = new Event
        {
            HouseholdId = household.Id,
            Title = "Monthly cleaning",
            Description = "Deep cleaning of kitchen and bathroom",
            Date = DateTime.UtcNow.AddDays(3).Date,
            Time = new TimeSpan(17, 0, 0),
            Location = "Apartment",
            CreatedByUserId = user1.Id
        };

        var grocery = new GroceryItem
        {
            HouseholdId = household.Id,
            Name = "Milk",
            Quantity = 2,
            AddedByUserId = user1.Id
        };

        await context.Users.AddRangeAsync(user1, user2);
        await context.Households.AddAsync(household);
        await context.HouseholdTasks.AddAsync(task);
        await context.Events.AddAsync(houseEvent);
        await context.GroceryItems.AddAsync(grocery);

        await context.SaveChangesAsync();
    }
}
