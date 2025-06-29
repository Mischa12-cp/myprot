-- Starlink Rent Devices Database Schema
-- Version: 2.0.0 with Plisio.net Integration and Email Notifications
-- MySQL 8.0+ Compatible

SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS `email_notifications`;
DROP TABLE IF EXISTS `payment_webhooks`;
DROP TABLE IF EXISTS `admin_activity_logs`;
DROP TABLE IF EXISTS `chat_messages`;
DROP TABLE IF EXISTS `chat_conversations`;
DROP TABLE IF EXISTS `push_notifications`;
DROP TABLE IF EXISTS `website_config`;
DROP TABLE IF EXISTS `payment_gateway_config`;
DROP TABLE IF EXISTS `investment_transactions`;
DROP TABLE IF EXISTS `investment_returns`;
DROP TABLE IF EXISTS `investment_portfolios`;
DROP TABLE IF EXISTS `device_investments`;
DROP TABLE IF EXISTS `investment_plans`;
DROP TABLE IF EXISTS `analytics_events`;
DROP TABLE IF EXISTS `notification_logs`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `device_maintenance`;
DROP TABLE IF EXISTS `referral_earnings`;
DROP TABLE IF EXISTS `investment_earnings`;
DROP TABLE IF EXISTS `rental_earnings`;
DROP TABLE IF EXISTS `withdrawal_requests`;
DROP TABLE IF EXISTS `telegram_sessions`;
DROP TABLE IF EXISTS `api_logs`;
DROP TABLE IF EXISTS `investments`;
DROP TABLE IF EXISTS `rentals`;
DROP TABLE IF EXISTS `referrals`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `device_plans`;
DROP TABLE IF EXISTS `devices`;
DROP TABLE IF EXISTS `admin_sessions`;
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `admin_users`;
DROP TABLE IF EXISTS `users`;

-- Drop custom types if they exist
DROP TYPE IF EXISTS `maintenance_type`;
DROP TYPE IF EXISTS `user_status`;
DROP TYPE IF EXISTS `admin_role`;
DROP TYPE IF EXISTS `admin_status`;
DROP TYPE IF EXISTS `device_status`;
DROP TYPE IF EXISTS `payment_method`;
DROP TYPE IF EXISTS `payment_status`;
DROP TYPE IF EXISTS `payment_type`;
DROP TYPE IF EXISTS `plan_type`;
DROP TYPE IF EXISTS `rental_status`;
DROP TYPE IF EXISTS `investment_status`;
DROP TYPE IF EXISTS `referral_status`;
DROP TYPE IF EXISTS `kyc_status`;
DROP TYPE IF EXISTS `maintenance_priority`;
DROP TYPE IF EXISTS `maintenance_status`;
DROP TYPE IF EXISTS `maintenance_result`;
DROP TYPE IF EXISTS `withdrawal_method`;
DROP TYPE IF EXISTS `withdrawal_status`;
DROP TYPE IF EXISTS `notification_type`;
DROP TYPE IF EXISTS `notification_status`;
DROP TYPE IF EXISTS `setting_type`;
DROP TYPE IF EXISTS `source_type`;

-- Create ENUM types
CREATE TABLE IF NOT EXISTS `enum_maintenance_type` (
    `value` ENUM('scheduled', 'emergency', 'repair', 'upgrade', 'inspection', 'replacement') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_user_status` (
    `value` ENUM('active', 'suspended', 'pending', 'banned') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_admin_role` (
    `value` ENUM('super_admin', 'admin', 'moderator', 'support') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_admin_status` (
    `value` ENUM('active', 'suspended', 'inactive') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_device_status` (
    `value` ENUM('available', 'rented', 'maintenance', 'offline', 'reserved') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_payment_method` (
    `value` ENUM('crypto', 'binance', 'card', 'bank_transfer', 'balance', 'manual') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_payment_status` (
    `value` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'expired') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_payment_type` (
    `value` ENUM('rental', 'investment', 'withdrawal', 'referral_bonus', 'deposit', 'fee', 'refund') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_plan_type` (
    `value` ENUM('basic', 'standard', 'premium', 'custom') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_rental_status` (
    `value` ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'expired') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_investment_status` (
    `value` ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'matured') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_referral_status` (
    `value` ENUM('active', 'inactive', 'suspended') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_kyc_status` (
    `value` ENUM('none', 'pending', 'approved', 'rejected') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_maintenance_priority` (
    `value` ENUM('low', 'medium', 'high', 'critical') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_maintenance_status` (
    `value` ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_maintenance_result` (
    `value` ENUM('successful', 'failed', 'partial', 'needs_followup') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_withdrawal_method` (
    `value` ENUM('crypto', 'bank_transfer', 'paypal', 'binance') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_withdrawal_status` (
    `value` ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_notification_type` (
    `value` ENUM('email', 'telegram', 'sms', 'push', 'system') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_notification_status` (
    `value` ENUM('pending', 'sent', 'delivered', 'failed', 'bounced') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_setting_type` (
    `value` ENUM('string', 'number', 'boolean', 'json', 'text') PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS `enum_source_type` (
    `value` ENUM('rental', 'investment', 'deposit') PRIMARY KEY
);

-- Users table
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `referral_code` VARCHAR(20) NOT NULL UNIQUE,
    `referred_by` INT NULL,
    `telegram_id` BIGINT NULL UNIQUE,
    `telegram_username` VARCHAR(50) NULL,
    `telegram_first_name` VARCHAR(100) NULL,
    `telegram_last_name` VARCHAR(100) NULL,
    `telegram_photo_url` TEXT NULL,
    `balance` DECIMAL(12,2) DEFAULT 0.00,
    `total_earnings` DECIMAL(12,2) DEFAULT 0.00,
    `total_invested` DECIMAL(12,2) DEFAULT 0.00,
    `total_withdrawn` DECIMAL(12,2) DEFAULT 0.00,
    `referral_earnings` DECIMAL(12,2) DEFAULT 0.00,
    `rental_earnings` DECIMAL(12,2) DEFAULT 0.00,
    `investment_earnings` DECIMAL(12,2) DEFAULT 0.00,
    `phone` VARCHAR(20) NULL,
    `country` VARCHAR(50) NULL,
    `timezone` VARCHAR(50) DEFAULT 'UTC',
    `language` VARCHAR(10) DEFAULT 'en',
    `status` ENUM('active', 'suspended', 'pending', 'banned') DEFAULT 'active',
    `email_verified` BOOLEAN DEFAULT FALSE,
    `telegram_verified` BOOLEAN DEFAULT FALSE,
    `kyc_status` ENUM('none', 'pending', 'approved', 'rejected') DEFAULT 'none',
    `kyc_documents` JSON NULL,
    `last_login` TIMESTAMP NULL,
    `last_activity` TIMESTAMP NULL,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `crypto_wallets` JSON NULL,
    `preferred_crypto` VARCHAR(10) DEFAULT 'BTC',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_users_referral_code` (`referral_code`),
    INDEX `idx_users_telegram_id` (`telegram_id`),
    INDEX `idx_users_status` (`status`),
    INDEX `idx_users_created_at` (`created_at`),
    
    FOREIGN KEY (`referred_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin users table
CREATE TABLE `admin_users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('super_admin', 'admin', 'moderator', 'support') DEFAULT 'admin',
    `permissions` JSON NULL,
    `two_factor_secret` VARCHAR(32) NULL,
    `two_factor_enabled` BOOLEAN DEFAULT FALSE,
    `status` ENUM('active', 'suspended', 'inactive') DEFAULT 'active',
    `last_login` TIMESTAMP NULL,
    `last_activity` TIMESTAMP NULL,
    `login_attempts` INT DEFAULT 0,
    `locked_until` TIMESTAMP NULL,
    `ip_address` INET NULL,
    `created_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_admin_users_role` (`role`),
    INDEX `idx_admin_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User sessions table
CREATE TABLE `user_sessions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `session_token` VARCHAR(255) NOT NULL UNIQUE,
    `device_info` TEXT NULL,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_user_sessions_user_id` (`user_id`),
    INDEX `idx_user_sessions_expires_at` (`expires_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin sessions table
CREATE TABLE `admin_sessions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `admin_id` INT NOT NULL,
    `session_token` VARCHAR(255) NOT NULL UNIQUE,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_admin_sessions_admin_id` (`admin_id`),
    INDEX `idx_admin_sessions_expires_at` (`expires_at`),
    
    FOREIGN KEY (`admin_id`) REFERENCES `admin_users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Devices table
CREATE TABLE `devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `device_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `model` VARCHAR(50) DEFAULT 'Starlink Standard',
    `serial_number` VARCHAR(100) NULL UNIQUE,
    `location` VARCHAR(100) NULL,
    `latitude` DECIMAL(10,8) NULL,
    `longitude` DECIMAL(11,8) NULL,
    `status` ENUM('available', 'rented', 'maintenance', 'offline', 'reserved') DEFAULT 'available',
    `daily_rate` DECIMAL(8,2) NOT NULL DEFAULT 15.00,
    `setup_fee` DECIMAL(8,2) DEFAULT 0.00,
    `max_speed_down` INT DEFAULT 200,
    `max_speed_up` INT DEFAULT 20,
    `uptime_percentage` DECIMAL(5,2) DEFAULT 99.00,
    `total_earnings` DECIMAL(12,2) DEFAULT 0.00,
    `total_rentals` INT DEFAULT 0,
    `specifications` JSON NULL,
    `features` JSON NULL,
    `images` JSON NULL,
    `installation_date` DATE NULL,
    `warranty_expires` DATE NULL,
    `maintenance_schedule` VARCHAR(20) DEFAULT 'monthly',
    `last_maintenance` DATE NULL,
    `next_maintenance` DATE NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_devices_device_id` (`device_id`),
    INDEX `idx_devices_status` (`status`),
    INDEX `idx_devices_location` (`location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device plans table
CREATE TABLE `device_plans` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plan_name` VARCHAR(100) NOT NULL,
    `plan_type` VARCHAR(20) NOT NULL CHECK (`plan_type` IN ('basic', 'pro', 'enterprise')),
    `daily_rate` DECIMAL(8,2) NOT NULL,
    `max_speed_mbps` INT NOT NULL,
    `generation` VARCHAR(20) NOT NULL CHECK (`generation` IN ('gen2', 'gen3', 'enterprise')),
    `minimum_days` INT DEFAULT 1,
    `setup_fee` DECIMAL(8,2) DEFAULT 0.00,
    `features` JSON NULL,
    `description` TEXT NULL,
    `is_popular` BOOLEAN DEFAULT FALSE,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_device_plans_plan_type` (`plan_type`),
    INDEX `idx_device_plans_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enhanced Payments table with Plisio.net integration
CREATE TABLE `payments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `transaction_id` VARCHAR(100) NULL UNIQUE,
    `external_id` VARCHAR(100) NULL,
    `amount` DECIMAL(12,2) NOT NULL,
    `currency` VARCHAR(10) DEFAULT 'USD',
    `crypto_currency` VARCHAR(20) NULL,
    `crypto_amount` DECIMAL(20,8) NULL,
    `exchange_rate` DECIMAL(15,8) NULL,
    `payment_method` ENUM('crypto', 'binance', 'card', 'bank_transfer', 'balance', 'manual') NOT NULL,
    `payment_provider` VARCHAR(50) NULL,
    `provider_transaction_id` VARCHAR(200) NULL,
    `provider_response` JSON NULL,
    `status` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'expired') DEFAULT 'pending',
    `type` ENUM('rental', 'investment', 'withdrawal', 'referral_bonus', 'deposit', 'fee', 'refund') NOT NULL,
    `description` TEXT NULL,
    `metadata` JSON NULL,
    `fee_amount` DECIMAL(12,2) DEFAULT 0.00,
    `net_amount` DECIMAL(12,2) NULL,
    `webhook_received` BOOLEAN DEFAULT FALSE,
    `webhook_data` JSON NULL,
    `processed_at` TIMESTAMP NULL,
    `expires_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_payments_user_id` (`user_id`),
    INDEX `idx_payments_status` (`status`),
    INDEX `idx_payments_type` (`type`),
    INDEX `idx_payments_created_at` (`created_at`),
    INDEX `idx_payments_provider` (`payment_provider`),
    INDEX `idx_payments_crypto_currency` (`crypto_currency`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment webhooks table for Plisio.net
CREATE TABLE `payment_webhooks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `provider` VARCHAR(50) NOT NULL,
    `webhook_id` VARCHAR(255) NULL,
    `event_type` VARCHAR(100) NOT NULL,
    `payment_id` INT NULL,
    `raw_data` JSON NOT NULL,
    `processed` BOOLEAN DEFAULT FALSE,
    `processing_attempts` INT DEFAULT 0,
    `last_processing_error` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    
    INDEX `idx_payment_webhooks_provider` (`provider`),
    INDEX `idx_payment_webhooks_processed` (`processed`),
    INDEX `idx_payment_webhooks_created_at` (`created_at`),
    
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Referrals table
CREATE TABLE `referrals` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `referrer_id` INT NOT NULL,
    `referred_id` INT NOT NULL,
    `level` SMALLINT NOT NULL CHECK (`level` IN (1, 2, 3)),
    `commission_rate` DECIMAL(5,2) NOT NULL,
    `total_commission_earned` DECIMAL(12,2) DEFAULT 0.00,
    `total_referral_volume` DECIMAL(12,2) DEFAULT 0.00,
    `status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    `first_earning_date` DATE NULL,
    `last_earning_date` DATE NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY `referrals_referrer_id_referred_id_key` (`referrer_id`, `referred_id`),
    INDEX `idx_referrals_referrer_id` (`referrer_id`),
    INDEX `idx_referrals_referred_id` (`referred_id`),
    INDEX `idx_referrals_level` (`level`),
    
    FOREIGN KEY (`referrer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`referred_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rentals table
CREATE TABLE `rentals` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `device_id` INT NOT NULL,
    `payment_id` INT NULL,
    `plan_type` ENUM('basic', 'standard', 'premium', 'custom') NOT NULL,
    `plan_name` VARCHAR(100) NULL,
    `rental_duration` INT NOT NULL,
    `daily_profit_rate` DECIMAL(5,2) NOT NULL,
    `total_cost` DECIMAL(12,2) NOT NULL,
    `setup_fee` DECIMAL(8,2) DEFAULT 0.00,
    `expected_daily_profit` DECIMAL(8,2) NOT NULL,
    `actual_total_profit` DECIMAL(12,2) DEFAULT 0.00,
    `total_days_active` INT DEFAULT 0,
    `performance_bonus` DECIMAL(8,2) DEFAULT 0.00,
    `status` ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'expired') DEFAULT 'pending',
    `auto_renew` BOOLEAN DEFAULT FALSE,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `actual_start_date` DATE NULL,
    `actual_end_date` DATE NULL,
    `last_profit_date` DATE NULL,
    `cancellation_reason` TEXT NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_rentals_user_id` (`user_id`),
    INDEX `idx_rentals_device_id` (`device_id`),
    INDEX `idx_rentals_status` (`status`),
    INDEX `idx_rentals_dates` (`start_date`, `end_date`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investments table
CREATE TABLE `investments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `payment_id` INT NULL,
    `plan_name` VARCHAR(100) NOT NULL,
    `plan_duration` INT NOT NULL,
    `investment_amount` DECIMAL(12,2) NOT NULL,
    `daily_rate` DECIMAL(6,4) NOT NULL,
    `expected_daily_profit` DECIMAL(8,2) NOT NULL,
    `total_earned` DECIMAL(12,2) DEFAULT 0.00,
    `total_days_active` INT DEFAULT 0,
    `compound_interest` BOOLEAN DEFAULT FALSE,
    `auto_reinvest` BOOLEAN DEFAULT FALSE,
    `reinvest_percentage` DECIMAL(5,2) DEFAULT 0.00,
    `status` ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'matured') DEFAULT 'pending',
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `actual_start_date` DATE NULL,
    `maturity_date` DATE NULL,
    `last_profit_date` DATE NULL,
    `early_withdrawal_fee` DECIMAL(5,2) DEFAULT 10.00,
    `withdrawal_allowed_after` INT DEFAULT 30,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_investments_user_id` (`user_id`),
    INDEX `idx_investments_status` (`status`),
    INDEX `idx_investments_dates` (`start_date`, `end_date`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rental earnings table
CREATE TABLE `rental_earnings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `rental_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `device_id` INT NOT NULL,
    `earning_date` DATE NOT NULL,
    `base_profit_amount` DECIMAL(8,2) NOT NULL,
    `performance_bonus` DECIMAL(8,2) DEFAULT 0.00,
    `total_profit_amount` DECIMAL(8,2) NOT NULL,
    `device_uptime` DECIMAL(5,2) DEFAULT 100.00,
    `performance_factor` DECIMAL(4,3) DEFAULT 1.000,
    `weather_factor` DECIMAL(4,3) DEFAULT 1.000,
    `network_quality` DECIMAL(5,2) DEFAULT 100.00,
    `processed` BOOLEAN DEFAULT FALSE,
    `processed_at` TIMESTAMP NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY `rental_earnings_rental_id_earning_date_key` (`rental_id`, `earning_date`),
    INDEX `idx_rental_earnings_rental_id` (`rental_id`),
    INDEX `idx_rental_earnings_user_id` (`user_id`),
    INDEX `idx_rental_earnings_earning_date` (`earning_date`),
    
    FOREIGN KEY (`rental_id`) REFERENCES `rentals`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment earnings table
CREATE TABLE `investment_earnings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `investment_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `earning_date` DATE NOT NULL,
    `base_amount` DECIMAL(12,2) NOT NULL,
    `daily_rate` DECIMAL(6,4) NOT NULL,
    `profit_amount` DECIMAL(8,2) NOT NULL,
    `compound_amount` DECIMAL(8,2) DEFAULT 0.00,
    `reinvested_amount` DECIMAL(8,2) DEFAULT 0.00,
    `paid_amount` DECIMAL(8,2) NOT NULL,
    `processed` BOOLEAN DEFAULT FALSE,
    `processed_at` TIMESTAMP NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY `investment_earnings_investment_id_earning_date_key` (`investment_id`, `earning_date`),
    INDEX `idx_investment_earnings_investment_id` (`investment_id`),
    INDEX `idx_investment_earnings_user_id` (`user_id`),
    INDEX `idx_investment_earnings_earning_date` (`earning_date`),
    
    FOREIGN KEY (`investment_id`) REFERENCES `investments`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Referral earnings table
CREATE TABLE `referral_earnings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `referral_id` INT NOT NULL,
    `referrer_id` INT NOT NULL,
    `referred_id` INT NOT NULL,
    `source_type` ENUM('rental', 'investment', 'deposit') NOT NULL,
    `source_id` INT NOT NULL,
    `level` SMALLINT NOT NULL CHECK (`level` IN (1, 2, 3)),
    `commission_rate` DECIMAL(5,2) NOT NULL,
    `base_amount` DECIMAL(12,2) NOT NULL,
    `commission_amount` DECIMAL(8,2) NOT NULL,
    `earning_date` DATE NOT NULL,
    `processed` BOOLEAN DEFAULT FALSE,
    `processed_at` TIMESTAMP NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_referral_earnings_referral_id` (`referral_id`),
    INDEX `idx_referral_earnings_referrer_id` (`referrer_id`),
    INDEX `idx_referral_earnings_earning_date` (`earning_date`),
    
    FOREIGN KEY (`referral_id`) REFERENCES `referrals`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`referrer_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`referred_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device maintenance table
CREATE TABLE `device_maintenance` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `device_id` INT NOT NULL,
    `maintenance_type` ENUM('scheduled', 'emergency', 'repair', 'upgrade', 'inspection', 'replacement') NOT NULL,
    `priority` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    `title` VARCHAR(200) NOT NULL,
    `description` TEXT NULL,
    `cost` DECIMAL(10,2) DEFAULT 0.00,
    `technician` VARCHAR(100) NULL,
    `technician_contact` VARCHAR(100) NULL,
    `vendor` VARCHAR(100) NULL,
    `parts_used` JSON NULL,
    `scheduled_date` TIMESTAMP NULL,
    `started_at` TIMESTAMP NULL,
    `completed_at` TIMESTAMP NULL,
    `estimated_duration` INT NULL,
    `actual_duration` INT NULL,
    `status` ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'postponed') DEFAULT 'scheduled',
    `result` ENUM('successful', 'failed', 'partial', 'needs_followup') NULL,
    `downtime_minutes` INT DEFAULT 0,
    `performance_impact` DECIMAL(5,2) DEFAULT 0.00,
    `before_photos` JSON NULL,
    `after_photos` JSON NULL,
    `notes` TEXT NULL,
    `next_maintenance_date` DATE NULL,
    `created_by` INT NULL,
    `updated_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_device_maintenance_device_id` (`device_id`),
    INDEX `idx_device_maintenance_status` (`status`),
    
    FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Withdrawal requests table
CREATE TABLE `withdrawal_requests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `amount` DECIMAL(12,2) NOT NULL,
    `fee_amount` DECIMAL(8,2) DEFAULT 0.00,
    `net_amount` DECIMAL(12,2) NOT NULL,
    `withdrawal_method` ENUM('crypto', 'bank_transfer', 'paypal', 'binance') NOT NULL,
    `withdrawal_address` TEXT NULL,
    `bank_details` JSON NULL,
    `status` ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') DEFAULT 'pending',
    `admin_notes` TEXT NULL,
    `user_notes` TEXT NULL,
    `processed_by` INT NULL,
    `transaction_hash` VARCHAR(200) NULL,
    `external_transaction_id` VARCHAR(200) NULL,
    `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL,
    `completed_at` TIMESTAMP NULL,
    
    INDEX `idx_withdrawal_requests_user_id` (`user_id`),
    INDEX `idx_withdrawal_requests_status` (`status`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`processed_by`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Telegram sessions table
CREATE TABLE `telegram_sessions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `telegram_id` BIGINT NOT NULL,
    `session_data` JSON NULL,
    `init_data` TEXT NULL,
    `init_data_hash` VARCHAR(64) NULL,
    `auth_date` INT NULL,
    `query_id` VARCHAR(100) NULL,
    `chat_type` VARCHAR(20) NULL,
    `chat_instance` VARCHAR(50) NULL,
    `start_param` VARCHAR(100) NULL,
    `is_premium` BOOLEAN DEFAULT FALSE,
    `language_code` VARCHAR(10) DEFAULT 'en',
    `platform` VARCHAR(20) NULL,
    `version` VARCHAR(20) NULL,
    `theme_params` JSON NULL,
    `viewport_height` INT NULL,
    `viewport_stable_height` INT NULL,
    `header_color` VARCHAR(7) NULL,
    `background_color` VARCHAR(7) NULL,
    `is_expanded` BOOLEAN DEFAULT FALSE,
    `is_closing_confirmation_enabled` BOOLEAN DEFAULT FALSE,
    `last_activity` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_telegram_sessions_user_id` (`user_id`),
    INDEX `idx_telegram_sessions_telegram_id` (`telegram_id`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- API logs table
CREATE TABLE `api_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `admin_id` INT NULL,
    `endpoint` VARCHAR(200) NOT NULL,
    `method` VARCHAR(10) NOT NULL,
    `request_data` JSON NULL,
    `response_data` JSON NULL,
    `status_code` INT NOT NULL,
    `response_time` DECIMAL(8,3) NULL,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_api_logs_user_id` (`user_id`),
    INDEX `idx_api_logs_created_at` (`created_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`admin_id`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notification logs table
CREATE TABLE `notification_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `type` ENUM('email', 'telegram', 'sms', 'push', 'system') NOT NULL,
    `channel` VARCHAR(50) NULL,
    `recipient` VARCHAR(200) NOT NULL,
    `subject` VARCHAR(200) NULL,
    `message` TEXT NOT NULL,
    `template` VARCHAR(100) NULL,
    `template_data` JSON NULL,
    `status` ENUM('pending', 'sent', 'delivered', 'failed', 'bounced') DEFAULT 'pending',
    `provider` VARCHAR(50) NULL,
    `provider_id` VARCHAR(100) NULL,
    `provider_response` JSON NULL,
    `error_message` TEXT NULL,
    `sent_at` TIMESTAMP NULL,
    `delivered_at` TIMESTAMP NULL,
    `opened_at` TIMESTAMP NULL,
    `clicked_at` TIMESTAMP NULL,
    `retry_count` INT DEFAULT 0,
    `max_retries` INT DEFAULT 3,
    `next_retry_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_notification_logs_user_id` (`user_id`),
    INDEX `idx_notification_logs_status` (`status`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enhanced System settings table
CREATE TABLE `system_settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` TEXT NOT NULL,
    `setting_type` ENUM('string', 'number', 'boolean', 'json', 'text') DEFAULT 'string',
    `category` VARCHAR(50) DEFAULT 'general',
    `description` TEXT NULL,
    `is_public` BOOLEAN DEFAULT FALSE,
    `updated_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_system_settings_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Email notifications table
CREATE TABLE `email_notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `email` VARCHAR(255) NOT NULL,
    `subject` VARCHAR(255) NOT NULL,
    `template_name` VARCHAR(100) NOT NULL,
    `template_data` JSON NULL,
    `status` VARCHAR(20) DEFAULT 'pending' CHECK (`status` IN ('pending', 'sent', 'failed', 'delivered')),
    `provider` VARCHAR(50) NULL,
    `provider_message_id` VARCHAR(255) NULL,
    `sent_at` TIMESTAMP NULL,
    `delivered_at` TIMESTAMP NULL,
    `error_message` TEXT NULL,
    `retry_count` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_email_notifications_user_id` (`user_id`),
    INDEX `idx_email_notifications_status` (`status`),
    INDEX `idx_email_notifications_created_at` (`created_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chat conversations table
CREATE TABLE `chat_conversations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `admin_id` INT NULL,
    `status` VARCHAR(20) DEFAULT 'open' CHECK (`status` IN ('open', 'closed', 'pending')),
    `priority` VARCHAR(10) DEFAULT 'medium' CHECK (`priority` IN ('low', 'medium', 'high', 'urgent')),
    `subject` VARCHAR(255) NULL,
    `last_message_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `closed_at` TIMESTAMP NULL,
    
    INDEX `idx_chat_conversations_user_id` (`user_id`),
    INDEX `idx_chat_conversations_status` (`status`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`admin_id`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Chat messages table
CREATE TABLE `chat_messages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `conversation_id` INT NULL,
    `sender_type` VARCHAR(10) NOT NULL CHECK (`sender_type` IN ('user', 'admin', 'system')),
    `sender_id` INT NULL,
    `message` TEXT NOT NULL,
    `message_type` VARCHAR(20) DEFAULT 'text' CHECK (`message_type` IN ('text', 'image', 'file', 'system')),
    `attachments` JSON NULL,
    `is_read` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_chat_messages_conversation_id` (`conversation_id`),
    
    FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Analytics events table
CREATE TABLE `analytics_events` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `event_type` VARCHAR(50) NOT NULL,
    `event_name` VARCHAR(100) NOT NULL,
    `properties` JSON NULL,
    `session_id` VARCHAR(100) NULL,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `referrer` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_analytics_events_user_id` (`user_id`),
    INDEX `idx_analytics_events_event_type` (`event_type`),
    INDEX `idx_analytics_events_created_at` (`created_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Push notifications table
CREATE TABLE `push_notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `title` VARCHAR(255) NOT NULL,
    `body` TEXT NOT NULL,
    `data` JSON NULL,
    `push_token` VARCHAR(500) NULL,
    `status` VARCHAR(20) DEFAULT 'pending' CHECK (`status` IN ('pending', 'sent', 'failed', 'delivered')),
    `platform` VARCHAR(20) NULL CHECK (`platform` IN ('web', 'android', 'ios')),
    `sent_at` TIMESTAMP NULL,
    `error_message` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_push_notifications_user_id` (`user_id`),
    INDEX `idx_push_notifications_status` (`status`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Website configuration table
CREATE TABLE `website_config` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `section` VARCHAR(50) NOT NULL,
    `key` VARCHAR(100) NOT NULL,
    `value` JSON NOT NULL,
    `description` TEXT NULL,
    `updated_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY `website_config_section_key_key` (`section`, `key`),
    
    FOREIGN KEY (`updated_by`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment gateway configuration table
CREATE TABLE `payment_gateway_config` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `provider` VARCHAR(50) NOT NULL UNIQUE,
    `is_enabled` BOOLEAN DEFAULT FALSE,
    `is_sandbox` BOOLEAN DEFAULT TRUE,
    `config_data` JSON NOT NULL,
    `supported_currencies` TEXT NULL,
    `webhook_url` VARCHAR(500) NULL,
    `updated_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`updated_by`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment plans table
CREATE TABLE `investment_plans` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `device_id` INT NULL,
    `target_amount` DECIMAL(12,2) NOT NULL,
    `raised_amount` DECIMAL(12,2) DEFAULT 0,
    `min_investment` DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    `max_investment` DECIMAL(10,2) NULL,
    `expected_daily_return` DECIMAL(5,4) NOT NULL,
    `investment_period_days` INT NOT NULL DEFAULT 30,
    `status` VARCHAR(20) DEFAULT 'active' CHECK (`status` IN ('active', 'funded', 'completed', 'cancelled')),
    `start_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `end_date` TIMESTAMP NULL,
    `profit_sharing_percentage` DECIMAL(5,2) NOT NULL DEFAULT 80.00,
    `image_url` TEXT NULL,
    `location` VARCHAR(255) NULL,
    `risk_level` VARCHAR(10) DEFAULT 'medium' CHECK (`risk_level` IN ('low', 'medium', 'high')),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_investment_plans_status` (`status`),
    INDEX `idx_investment_plans_device_id` (`device_id`),
    
    FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device investments table
CREATE TABLE `device_investments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `investment_plan_id` INT NOT NULL,
    `amount` DECIMAL(10,2) NOT NULL,
    `investment_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `maturity_date` TIMESTAMP NOT NULL,
    `status` VARCHAR(20) DEFAULT 'active' CHECK (`status` IN ('active', 'matured', 'withdrawn', 'cancelled')),
    `total_returns` DECIMAL(10,2) DEFAULT 0,
    `last_return_date` TIMESTAMP NULL,
    `payment_id` INT NULL,
    `early_withdrawal_fee` DECIMAL(5,2) DEFAULT 10.00,
    `auto_reinvest` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX `idx_device_investments_user_id` (`user_id`),
    INDEX `idx_device_investments_plan_id` (`investment_plan_id`),
    INDEX `idx_device_investments_status` (`status`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`investment_plan_id`) REFERENCES `investment_plans`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment returns table
CREATE TABLE `investment_returns` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `investment_id` INT NOT NULL,
    `return_date` DATE NOT NULL,
    `return_amount` DECIMAL(8,4) NOT NULL,
    `rental_revenue` DECIMAL(10,2) NULL,
    `investor_share` DECIMAL(10,2) NULL,
    `return_percentage` DECIMAL(5,4) NULL,
    `status` VARCHAR(20) DEFAULT 'pending' CHECK (`status` IN ('pending', 'paid', 'failed')),
    `payment_processed_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_investment_returns_investment_id` (`investment_id`),
    INDEX `idx_investment_returns_date` (`return_date`),
    
    FOREIGN KEY (`investment_id`) REFERENCES `device_investments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment transactions table
CREATE TABLE `investment_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `investment_id` INT NULL,
    `transaction_type` VARCHAR(20) NOT NULL CHECK (`transaction_type` IN ('investment', 'return', 'withdrawal', 'bonus', 'fee')),
    `amount` DECIMAL(10,2) NOT NULL,
    `description` TEXT NULL,
    `reference_id` VARCHAR(255) NULL,
    `status` VARCHAR(20) DEFAULT 'completed' CHECK (`status` IN ('pending', 'completed', 'failed', 'cancelled')),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_investment_transactions_user_id` (`user_id`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`investment_id`) REFERENCES `device_investments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment portfolios table
CREATE TABLE `investment_portfolios` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `total_invested` DECIMAL(12,2) DEFAULT 0,
    `total_returns` DECIMAL(12,2) DEFAULT 0,
    `active_investments` INT DEFAULT 0,
    `total_profit` DECIMAL(12,2) DEFAULT 0,
    `average_daily_return` DECIMAL(5,4) DEFAULT 0,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin activity logs table
CREATE TABLE `admin_activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `admin_id` INT NULL,
    `action` VARCHAR(100) NOT NULL,
    `target_type` VARCHAR(50) NULL,
    `target_id` INT NULL,
    `details` JSON NULL,
    `ip_address` INET NULL,
    `user_agent` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX `idx_admin_activity_logs_admin_id` (`admin_id`),
    INDEX `idx_admin_activity_logs_created_at` (`created_at`),
    
    FOREIGN KEY (`admin_id`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create triggers for automatic updates
DELIMITER $$

CREATE TRIGGER `trigger_users_updated_at`
    BEFORE UPDATE ON `users`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_admin_users_updated_at`
    BEFORE UPDATE ON `admin_users`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_devices_updated_at`
    BEFORE UPDATE ON `devices`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_payments_updated_at`
    BEFORE UPDATE ON `payments`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_referrals_updated_at`
    BEFORE UPDATE ON `referrals`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_rentals_updated_at`
    BEFORE UPDATE ON `rentals`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_investments_updated_at`
    BEFORE UPDATE ON `investments`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_device_maintenance_updated_at`
    BEFORE UPDATE ON `device_maintenance`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_telegram_sessions_updated_at`
    BEFORE UPDATE ON `telegram_sessions`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_notification_logs_updated_at`
    BEFORE UPDATE ON `notification_logs`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_system_settings_updated_at`
    BEFORE UPDATE ON `system_settings`
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Auto-generate referral code trigger
CREATE TRIGGER `trigger_auto_referral_code`
    BEFORE INSERT ON `users`
    FOR EACH ROW
BEGIN
    IF NEW.referral_code IS NULL OR NEW.referral_code = '' THEN
        SET NEW.referral_code = UPPER(SUBSTRING(MD5(CONCAT(UNIX_TIMESTAMP(), RAND())), 1, 10));
    END IF;
END$$

-- Create referral relationships trigger
CREATE TRIGGER `trigger_create_referral_relationships`
    AFTER INSERT ON `users`
    FOR EACH ROW
BEGIN
    DECLARE level1_id INT DEFAULT NULL;
    DECLARE level2_id INT DEFAULT NULL;
    
    IF NEW.referred_by IS NOT NULL THEN
        -- Level 1 referral
        INSERT INTO referrals (referrer_id, referred_id, level, commission_rate, status)
        VALUES (NEW.referred_by, NEW.id, 1, 7.00, 'active');
        
        -- Level 2 referral
        SELECT referred_by INTO level1_id FROM users WHERE id = NEW.referred_by;
        IF level1_id IS NOT NULL THEN
            INSERT INTO referrals (referrer_id, referred_id, level, commission_rate, status)
            VALUES (level1_id, NEW.id, 2, 5.00, 'active');
            
            -- Level 3 referral
            SELECT referred_by INTO level2_id FROM users WHERE id = level1_id;
            IF level2_id IS NOT NULL THEN
                INSERT INTO referrals (referrer_id, referred_id, level, commission_rate, status)
                VALUES (level2_id, NEW.id, 3, 3.00, 'active');
            END IF;
        END IF;
    END IF;
END$$

DELIMITER ;

-- Insert default system settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`) VALUES
('site_name', 'Starlink Rent', 'string', 'general', 'Website name'),
('site_url', 'http://localhost', 'string', 'general', 'Website URL'),
('admin_email', 'admin@starlink-rent.com', 'string', 'general', 'Administrator email'),
('min_deposit', '50', 'number', 'payments', 'Minimum deposit amount'),
('max_deposit', '10000', 'number', 'payments', 'Maximum deposit amount'),
('min_withdrawal', '20', 'number', 'payments', 'Minimum withdrawal amount'),
('withdrawal_fee', '2.0', 'number', 'payments', 'Withdrawal fee percentage'),
('plisio_api_key', '', 'string', 'payments', 'Plisio.net API key for crypto payments'),
('plisio_webhook_url', '', 'string', 'payments', 'Plisio webhook URL'),
('binance_api_key', '', 'string', 'payments', 'Binance API key'),
('binance_secret', '', 'string', 'payments', 'Binance API secret'),
('telegram_bot_token', '', 'string', 'telegram', 'Telegram bot token'),
('smtp_host', 'smtp.gmail.com', 'string', 'email', 'SMTP server host'),
('smtp_port', '587', 'number', 'email', 'SMTP server port'),
('smtp_username', '', 'string', 'email', 'SMTP username'),
('smtp_password', '', 'string', 'email', 'SMTP password'),
('smtp_secure', 'tls', 'string', 'email', 'SMTP security (tls/ssl)'),
('email_from', 'noreply@starlink-rent.com', 'string', 'email', 'From email address'),
('email_from_name', 'Starlink Rent', 'string', 'email', 'From name'),
('email_notifications_enabled', '1', 'boolean', 'email', 'Enable email notifications'),
('welcome_email_enabled', '1', 'boolean', 'email', 'Enable welcome emails'),
('deposit_email_enabled', '1', 'boolean', 'email', 'Enable deposit confirmation emails'),
('withdrawal_email_enabled', '1', 'boolean', 'email', 'Enable withdrawal notification emails'),
('daily_earnings_email_enabled', '0', 'boolean', 'email', 'Enable daily earnings emails'),
('referral_email_enabled', '1', 'boolean', 'email', 'Enable referral bonus emails');

-- Insert sample devices
INSERT INTO `devices` (`device_id`, `name`, `model`, `location`, `status`, `daily_rate`, `max_speed_down`, `max_speed_up`, `uptime_percentage`) VALUES
('SL001', 'Starlink Terminal Alpha', 'Starlink Standard', 'New York, USA', 'available', 15.00, 200, 20, 99.5),
('SL002', 'Starlink Terminal Beta', 'Starlink Standard', 'London, UK', 'available', 18.00, 250, 25, 99.2),
('SL003', 'Starlink Terminal Gamma', 'Starlink Premium', 'Tokyo, Japan', 'available', 25.00, 300, 30, 99.8),
('SL004', 'Starlink Terminal Delta', 'Starlink Standard', 'Sydney, Australia', 'available', 20.00, 220, 22, 99.1),
('SL005', 'Starlink Terminal Epsilon', 'Starlink Premium', 'Toronto, Canada', 'available', 22.00, 280, 28, 99.6);

-- Insert sample device plans
INSERT INTO `device_plans` (`plan_name`, `plan_type`, `daily_rate`, `max_speed_mbps`, `generation`, `minimum_days`, `features`, `description`, `is_popular`) VALUES
('Basic Starlink', 'basic', 15.00, 200, 'gen2', 30, '["Standard speeds", "Basic support", "99% uptime"]', 'Perfect for getting started with Starlink rentals', FALSE),
('Pro Starlink', 'pro', 25.00, 300, 'gen3', 30, '["High speeds", "Priority support", "99.5% uptime", "Performance monitoring"]', 'Best value for serious investors', TRUE),
('Enterprise Starlink', 'enterprise', 40.00, 500, 'enterprise', 30, '["Ultra-high speeds", "24/7 VIP support", "99.9% uptime", "Advanced analytics", "Backup systems"]', 'Maximum performance and reliability', FALSE);

-- Insert default admin user (password: admin123)
INSERT INTO `admin_users` (`username`, `email`, `password_hash`, `role`, `status`) VALUES
('admin', 'admin@starlink-rent.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'active');

-- Insert sample payment gateway configurations
INSERT INTO `payment_gateway_config` (`provider`, `is_enabled`, `is_sandbox`, `config_data`, `supported_currencies`) VALUES
('plisio', TRUE, FALSE, '{"api_key": "", "webhook_secret": ""}', 'BTC,ETH,USDT,USDC,LTC,BCH,DOGE,TRX'),
('binance', FALSE, TRUE, '{"api_key": "", "secret": ""}', 'BTC,ETH,USDT,USDC,BNB');

-- Insert website configuration
INSERT INTO `website_config` (`section`, `key`, `value`, `description`) VALUES
('general', 'maintenance_mode', 'false', 'Enable maintenance mode'),
('general', 'registration_enabled', 'true', 'Allow new user registrations'),
('general', 'kyc_required', 'false', 'Require KYC verification'),
('payments', 'crypto_enabled', 'true', 'Enable cryptocurrency payments'),
('payments', 'fiat_enabled', 'true', 'Enable fiat payments'),
('referrals', 'max_levels', '3', 'Maximum referral levels'),
('referrals', 'level1_rate', '7.0', 'Level 1 commission rate'),
('referrals', 'level2_rate', '5.0', 'Level 2 commission rate'),
('referrals', 'level3_rate', '3.0', 'Level 3 commission rate');

SET FOREIGN_KEY_CHECKS = 1;

-- Create indexes for better performance
CREATE INDEX `idx_payments_crypto_currency` ON `payments` (`crypto_currency`);
CREATE INDEX `idx_payments_provider` ON `payments` (`payment_provider`);
CREATE INDEX `idx_payment_webhooks_created_at` ON `payment_webhooks` (`created_at`);
CREATE INDEX `idx_email_notifications_created_at` ON `email_notifications` (`created_at`);

-- Grant permissions (adjust as needed for your setup)
-- GRANT ALL PRIVILEGES ON starlink_rent.* TO 'starlink_user'@'localhost' IDENTIFIED BY 'secure_password';
-- FLUSH PRIVILEGES;

-- Database schema completed successfully
-- Version: 2.0.0 with Plisio.net Integration and Email Notifications
-- Features: Cryptocurrency payments, SMTP emails, enhanced admin panel, comprehensive logging