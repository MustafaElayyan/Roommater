-- =============================================================================
-- Roommater – MySQL Database Schema
-- =============================================================================
-- Generated from the Roommater PRD and existing Flutter entity definitions.
-- Engine : InnoDB (for FK & transaction support)
-- Charset: utf8mb4 (full Unicode including emoji)
-- Key type: BIGINT UNSIGNED AUTO_INCREMENT (consistent across all tables)
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------------
-- 1. USERS
-- Core identity table. Every person who signs up (email/password or Google)
-- has exactly one row here.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uid`           VARCHAR(128)    NOT NULL COMMENT 'Firebase/external auth UID',
    `email`         VARCHAR(255)    NOT NULL,
    `password_hash` VARCHAR(255)    NULL     COMMENT 'NULL when using OAuth-only login',
    `google_uid`    VARCHAR(128)    NULL     COMMENT 'Google OAuth UID (nullable)',
    `display_name`  VARCHAR(100)    NULL,
    `photo_url`     VARCHAR(512)    NULL,
    `household_id`  BIGINT UNSIGNED NULL     COMMENT 'Current household (at most one)',
    `joined_household_at` DATETIME NULL     COMMENT 'When user joined current household',
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_users_uid`   (`uid`),
    UNIQUE KEY `uk_users_email` (`email`),
    INDEX `idx_users_household` (`household_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Registered Roommater users';

-- ---------------------------------------------------------------------------
-- 2. PROFILES
-- Extended profile information that goes beyond basic auth fields.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `profiles` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       BIGINT UNSIGNED NOT NULL,
    `bio`           TEXT            NULL,
    `age`           TINYINT UNSIGNED NULL,
    `occupation`    VARCHAR(100)    NULL,
    `location`      VARCHAR(255)    NULL,
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_profiles_user` (`user_id`),
    CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Extended user profiles (bio, age, occupation, location)';

-- ---------------------------------------------------------------------------
-- 3. HOUSEHOLDS
-- A household groups up to 8 roommates who share tasks, groceries, etc.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `households` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`          VARCHAR(100)    NOT NULL,
    `admin_user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Household creator / current admin',
    `max_members`   TINYINT UNSIGNED NOT NULL DEFAULT 8,
    `created_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_households_name` (`name`),
    INDEX `idx_households_admin` (`admin_user_id`),
    CONSTRAINT `fk_households_admin` FOREIGN KEY (`admin_user_id`)
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Households group roommates together (max 8 per household)';

-- Add FK from users → households now that both tables exist
ALTER TABLE `users`
    ADD CONSTRAINT `fk_users_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- ---------------------------------------------------------------------------
-- 4. JOIN REQUESTS
-- A user requests to join a household; the admin accepts or rejects.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `join_requests` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `requesting_user_id` BIGINT UNSIGNED NOT NULL,
    `household_id`      BIGINT UNSIGNED NOT NULL,
    `status`            ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
    `requested_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `responded_at`      DATETIME NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_join_requests_household` (`household_id`, `status`),
    INDEX `idx_join_requests_user` (`requesting_user_id`),
    CONSTRAINT `fk_join_requests_user` FOREIGN KEY (`requesting_user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_join_requests_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Requests from users wanting to join a household';

-- ---------------------------------------------------------------------------
-- 5. TASKS (Chores)
-- Household tasks/chores that can be one-time or recurring.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tasks` (
    `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `household_id`    BIGINT UNSIGNED NOT NULL,
    `title`           VARCHAR(200)    NOT NULL,
    `description`     TEXT            NULL,
    `due_date`        DATETIME        NOT NULL,
    `recurrence`      ENUM('none','daily','weekly','custom') NOT NULL DEFAULT 'none',
    `recurrence_days` VARCHAR(50)     NULL     COMMENT 'e.g. "Mon,Wed,Fri" when recurrence=custom',
    `status`          ENUM('active','completed','overdue') NOT NULL DEFAULT 'active',
    `created_by`      BIGINT UNSIGNED NOT NULL,
    `completed_at`    DATETIME        NULL,
    `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_tasks_household_status` (`household_id`, `status`),
    INDEX `idx_tasks_due` (`due_date`),
    CONSTRAINT `fk_tasks_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_tasks_creator` FOREIGN KEY (`created_by`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Household tasks/chores with optional recurrence';

-- ---------------------------------------------------------------------------
-- 6. TASK ASSIGNMENTS (many-to-many)
-- A task can be assigned to one or more roommates.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `task_assignments` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `task_id`      BIGINT UNSIGNED NOT NULL,
    `user_id`      BIGINT UNSIGNED NOT NULL,
    `completed`    BOOLEAN         NOT NULL DEFAULT FALSE,
    `completed_at` DATETIME        NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_task_assignments` (`task_id`, `user_id`),
    INDEX `idx_task_assignments_user` (`user_id`),
    CONSTRAINT `fk_task_assignments_task` FOREIGN KEY (`task_id`)
        REFERENCES `tasks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_task_assignments_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Junction table: assigns tasks to one or more roommates';

-- ---------------------------------------------------------------------------
-- 7. STREAKS
-- Tracks per-user task completion streaks.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `streaks` (
    `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`             BIGINT UNSIGNED NOT NULL,
    `current_streak`      INT UNSIGNED    NOT NULL DEFAULT 0,
    `longest_streak`      INT UNSIGNED    NOT NULL DEFAULT 0,
    `last_completed_date` DATE            NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_streaks_user` (`user_id`),
    CONSTRAINT `fk_streaks_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-user task completion streak tracking';

-- ---------------------------------------------------------------------------
-- 8. GROCERY ITEMS (Shared Supplies List)
-- Household shared grocery/supplies list.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `grocery_items` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `household_id` BIGINT UNSIGNED NOT NULL,
    `item_name`    VARCHAR(200)    NOT NULL,
    `quantity`     VARCHAR(50)     NULL     COMMENT 'Free-text quantity e.g. "2 kg", "1 pack"',
    `status`       ENUM('active','bought') NOT NULL DEFAULT 'active',
    `added_by`     BIGINT UNSIGNED NOT NULL,
    `bought_by`    BIGINT UNSIGNED NULL,
    `bought_at`    DATETIME        NULL,
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_grocery_household_status` (`household_id`, `status`),
    CONSTRAINT `fk_grocery_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_grocery_added_by` FOREIGN KEY (`added_by`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_grocery_bought_by` FOREIGN KEY (`bought_by`)
        REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Shared grocery/supply items within a household';

-- ---------------------------------------------------------------------------
-- 9. EXPENSES
-- Tracks money spent by any roommate on behalf of the household.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `expenses` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `household_id` BIGINT UNSIGNED NOT NULL,
    `title`        VARCHAR(200)    NOT NULL,
    `amount`       DECIMAL(10,2)   NOT NULL,
    `category`     VARCHAR(100)    NULL     COMMENT 'Free-text category e.g. "Rent", "Utilities"',
    `payer_id`     BIGINT UNSIGNED NOT NULL COMMENT 'The user who paid',
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_expenses_household` (`household_id`),
    INDEX `idx_expenses_payer` (`payer_id`),
    CONSTRAINT `fk_expenses_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_expenses_payer` FOREIGN KEY (`payer_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Expenses logged by roommates for the household';

-- ---------------------------------------------------------------------------
-- 10. EXPENSE SPLITS
-- How an expense is divided among selected household members.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `expense_splits` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `expense_id`        BIGINT UNSIGNED NOT NULL,
    `user_id`           BIGINT UNSIGNED NOT NULL,
    `share_amount`      DECIMAL(10,2)   NOT NULL,
    `is_settled`        BOOLEAN         NOT NULL DEFAULT FALSE,
    `settled_at`        DATETIME        NULL,
    `confirmed_by_payer` BOOLEAN        NOT NULL DEFAULT FALSE,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_expense_splits` (`expense_id`, `user_id`),
    INDEX `idx_expense_splits_user` (`user_id`),
    CONSTRAINT `fk_expense_splits_expense` FOREIGN KEY (`expense_id`)
        REFERENCES `expenses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_expense_splits_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-member share of each expense';

-- ---------------------------------------------------------------------------
-- 11. EVENTS
-- Household calendar events (meetings, dinners, quiet hours, etc.).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `events` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `household_id` BIGINT UNSIGNED NOT NULL,
    `title`        VARCHAR(200)    NOT NULL,
    `description`  TEXT            NULL,
    `event_date`   DATE            NOT NULL,
    `event_time`   TIME            NULL,
    `location`     VARCHAR(255)    NULL,
    `event_type`   ENUM('meeting','dinner','party','quiet_hours','other') NOT NULL DEFAULT 'other',
    `created_by`   BIGINT UNSIGNED NOT NULL,
    `created_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_events_household_date` (`household_id`, `event_date`),
    CONSTRAINT `fk_events_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_events_creator` FOREIGN KEY (`created_by`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Household calendar events';

-- ---------------------------------------------------------------------------
-- 12. RSVPS
-- Each member can RSVP to a household event.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `rsvps` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `event_id`     BIGINT UNSIGNED NOT NULL,
    `user_id`      BIGINT UNSIGNED NOT NULL,
    `response`     ENUM('yes','no','maybe') NOT NULL DEFAULT 'maybe',
    `responded_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_rsvps_event_user` (`event_id`, `user_id`),
    INDEX `idx_rsvps_user` (`user_id`),
    CONSTRAINT `fk_rsvps_event` FOREIGN KEY (`event_id`)
        REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_rsvps_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='RSVP responses for household events';

-- ---------------------------------------------------------------------------
-- 13. ROOMMATE LISTINGS
-- Users can post room/roommate listings visible to all app users.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `listings` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `owner_id`     BIGINT UNSIGNED NOT NULL,
    `title`        VARCHAR(200)    NOT NULL,
    `description`  TEXT            NOT NULL,
    `rent`         DECIMAL(10,2)   NOT NULL,
    `location`     VARCHAR(255)    NOT NULL,
    `is_available` BOOLEAN         NOT NULL DEFAULT TRUE,
    `posted_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_listings_owner` (`owner_id`),
    INDEX `idx_listings_available` (`is_available`, `posted_at`),
    CONSTRAINT `fk_listings_owner` FOREIGN KEY (`owner_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Roommate / room-for-rent listings';

-- ---------------------------------------------------------------------------
-- 14. LISTING IMAGES
-- Each listing can have multiple images (normalized from the imageUrls list).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `listing_images` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `listing_id` BIGINT UNSIGNED NOT NULL,
    `image_url`  VARCHAR(512)    NOT NULL,
    `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `idx_listing_images_listing` (`listing_id`),
    CONSTRAINT `fk_listing_images_listing` FOREIGN KEY (`listing_id`)
        REFERENCES `listings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Images associated with a roommate listing';

-- ---------------------------------------------------------------------------
-- 15. CHATS
-- A conversation between two users.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `chats` (
    `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `last_message`    TEXT            NULL,
    `last_message_at` DATETIME        NULL,
    `created_at`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Chat conversations';

-- ---------------------------------------------------------------------------
-- 16. CHAT PARTICIPANTS
-- Links users to chats (supports 1-to-1 and group chats).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat_participants` (
    `id`      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `chat_id` BIGINT UNSIGNED NOT NULL,
    `user_id` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_chat_participants` (`chat_id`, `user_id`),
    INDEX `idx_chat_participants_user` (`user_id`),
    CONSTRAINT `fk_chat_participants_chat` FOREIGN KEY (`chat_id`)
        REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_chat_participants_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Links users to chat conversations';

-- ---------------------------------------------------------------------------
-- 17. MESSAGES
-- Individual messages within a chat conversation.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `messages` (
    `id`        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `chat_id`   BIGINT UNSIGNED NOT NULL,
    `sender_id` BIGINT UNSIGNED NOT NULL,
    `text`      TEXT            NOT NULL,
    `sent_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_messages_chat_sent` (`chat_id`, `sent_at`),
    CONSTRAINT `fk_messages_chat` FOREIGN KEY (`chat_id`)
        REFERENCES `chats` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Chat messages';

-- ---------------------------------------------------------------------------
-- 18. NOTIFICATIONS
-- In-app notifications for all Roommater events.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
    `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `recipient_user_id` BIGINT UNSIGNED NOT NULL,
    `household_id`     BIGINT UNSIGNED NULL,
    `type`             ENUM(
                           'task_assigned','task_overdue',
                           'event_created','event_reminder','rsvp_update',
                           'join_request','join_response',
                           'grocery_update',
                           'expense_logged','expense_settled',
                           'member_left','member_removed',
                           'message_received'
                       ) NOT NULL,
    `title`            VARCHAR(200) NOT NULL,
    `body`             TEXT         NULL,
    `is_read`          BOOLEAN      NOT NULL DEFAULT FALSE,
    `reference_id`     BIGINT UNSIGNED NULL COMMENT 'ID of the related entity',
    `reference_type`   VARCHAR(50)     NULL COMMENT 'task | event | expense | grocery | household | chat',
    `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_notifications_recipient` (`recipient_user_id`, `is_read`),
    INDEX `idx_notifications_household` (`household_id`),
    CONSTRAINT `fk_notifications_recipient` FOREIGN KEY (`recipient_user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_notifications_household` FOREIGN KEY (`household_id`)
        REFERENCES `households` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='In-app notifications for Roommater events';

-- ---------------------------------------------------------------------------
-- 19. USER SETTINGS
-- User preferences stored server-side.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_settings` (
    `id`                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`               BIGINT UNSIGNED NOT NULL,
    `is_dark_mode`          BOOLEAN         NOT NULL DEFAULT FALSE,
    `notifications_enabled` BOOLEAN         NOT NULL DEFAULT TRUE,
    `locale`                VARCHAR(10)     NOT NULL DEFAULT 'en',
    `updated_at`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_settings_user` (`user_id`),
    CONSTRAINT `fk_user_settings_user` FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-user app settings and preferences';

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- End of schema
-- =============================================================================
