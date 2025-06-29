-- Starlink Rent Devices - Complete Database Schema
-- Version: 2.0.0 with Plisio.net Integration
-- Features: Device Rental, Investment Plans, 3-Level Referrals, Crypto Payments

SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS `referral_earnings`;
DROP TABLE IF EXISTS `investment_earnings`;
DROP TABLE IF EXISTS `rental_earnings`;
DROP TABLE IF EXISTS `device_maintenance`;
DROP TABLE IF EXISTS `withdrawal_requests`;
DROP TABLE IF EXISTS `telegram_sessions`;
DROP TABLE IF EXISTS `api_logs`;
DROP TABLE IF EXISTS `notification_logs`;
DROP TABLE IF EXISTS `system_settings`;
DROP TABLE IF EXISTS `referrals`;
DROP TABLE IF EXISTS `investments`;
DROP TABLE IF EXISTS `rentals`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `payment_webhooks`;
DROP TABLE IF EXISTS `devices`;
DROP TABLE IF EXISTS `device_plans`;
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `admin_sessions`;
DROP TABLE IF EXISTS `admin_users`;
DROP TABLE IF EXISTS `email_notifications`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- Users table
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `referral_code` varchar(20) NOT NULL,
  `referred_by` int(11) DEFAULT NULL,
  `telegram_id` bigint(20) DEFAULT NULL,
  `telegram_username` varchar(50) DEFAULT NULL,
  `telegram_first_name` varchar(100) DEFAULT NULL,
  `telegram_last_name` varchar(100) DEFAULT NULL,
  `telegram_photo_url` text DEFAULT NULL,
  `balance` decimal(12,2) DEFAULT 0.00,
  `total_earnings` decimal(12,2) DEFAULT 0.00,
  `total_invested` decimal(12,2) DEFAULT 0.00,
  `total_withdrawn` decimal(12,2) DEFAULT 0.00,
  `referral_earnings` decimal(12,2) DEFAULT 0.00,
  `rental_earnings` decimal(12,2) DEFAULT 0.00,
  `investment_earnings` decimal(12,2) DEFAULT 0.00,
  `phone` varchar(20) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'UTC',
  `language` varchar(10) DEFAULT 'en',
  `status` enum('active','suspended','pending','banned') DEFAULT 'active',
  `email_verified` tinyint(1) DEFAULT 0,
  `telegram_verified` tinyint(1) DEFAULT 0,
  `kyc_status` enum('none','pending','approved','rejected') DEFAULT 'none',
  `kyc_documents` json DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `last_activity` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `crypto_wallets` json DEFAULT NULL,
  `preferred_crypto` varchar(10) DEFAULT 'BTC',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `referral_code` (`referral_code`),
  UNIQUE KEY `telegram_id` (`telegram_id`),
  KEY `idx_users_status` (`status`),
  KEY `idx_users_referral_code` (`referral_code`),
  KEY `idx_users_telegram_id` (`telegram_id`),
  KEY `idx_users_created_at` (`created_at`),
  KEY `referred_by` (`referred_by`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`referred_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin users table
CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('super_admin','admin','moderator','support') DEFAULT 'admin',
  `permissions` json DEFAULT NULL,
  `two_factor_secret` varchar(32) DEFAULT NULL,
  `two_factor_enabled` tinyint(1) DEFAULT 0,
  `status` enum('active','suspended','inactive') DEFAULT 'active',
  `last_login` timestamp NULL DEFAULT NULL,
  `last_activity` timestamp NULL DEFAULT NULL,
  `login_attempts` int(11) DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_admin_users_role` (`role`),
  KEY `idx_admin_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User sessions table
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `device_info` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token` (`session_token`),
  KEY `idx_user_sessions_user_id` (`user_id`),
  KEY `idx_user_sessions_expires_at` (`expires_at`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin sessions table
CREATE TABLE `admin_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token` (`session_token`),
  KEY `idx_admin_sessions_admin_id` (`admin_id`),
  KEY `idx_admin_sessions_expires_at` (`expires_at`),
  CONSTRAINT `admin_sessions_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Devices table
CREATE TABLE `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `model` varchar(50) DEFAULT 'Starlink Standard',
  `serial_number` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `status` enum('available','rented','maintenance','offline','reserved') DEFAULT 'available',
  `daily_rate` decimal(8,2) NOT NULL DEFAULT 15.00,
  `setup_fee` decimal(8,2) DEFAULT 0.00,
  `max_speed_down` int(11) DEFAULT 200,
  `max_speed_up` int(11) DEFAULT 20,
  `uptime_percentage` decimal(5,2) DEFAULT 99.00,
  `total_earnings` decimal(12,2) DEFAULT 0.00,
  `total_rentals` int(11) DEFAULT 0,
  `specifications` json DEFAULT NULL,
  `features` json DEFAULT NULL,
  `images` json DEFAULT NULL,
  `installation_date` date DEFAULT NULL,
  `warranty_expires` date DEFAULT NULL,
  `maintenance_schedule` varchar(20) DEFAULT 'monthly',
  `last_maintenance` date DEFAULT NULL,
  `next_maintenance` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_id` (`device_id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `idx_devices_device_id` (`device_id`),
  KEY `idx_devices_status` (`status`),
  KEY `idx_devices_location` (`location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device plans table
CREATE TABLE `device_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_name` varchar(100) NOT NULL,
  `plan_type` varchar(20) NOT NULL CHECK (`plan_type` IN ('basic','pro','enterprise')),
  `daily_rate` decimal(8,2) NOT NULL,
  `max_speed_mbps` int(11) NOT NULL,
  `generation` varchar(20) NOT NULL CHECK (`generation` IN ('gen2','gen3','enterprise')),
  `minimum_days` int(11) DEFAULT 1,
  `setup_fee` decimal(8,2) DEFAULT 0.00,
  `features` json DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_popular` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_plans_plan_type` (`plan_type`),
  KEY `idx_device_plans_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payments table with Plisio integration
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `external_id` varchar(100) DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `crypto_currency` varchar(20) DEFAULT NULL,
  `crypto_amount` decimal(20,8) DEFAULT NULL,
  `exchange_rate` decimal(15,8) DEFAULT NULL,
  `payment_method` enum('crypto','binance','card','bank_transfer','balance','manual') NOT NULL,
  `payment_provider` varchar(50) DEFAULT NULL,
  `provider_transaction_id` varchar(200) DEFAULT NULL,
  `provider_response` json DEFAULT NULL,
  `status` enum('pending','processing','completed','failed','cancelled','refunded','expired') DEFAULT 'pending',
  `type` enum('rental','investment','withdrawal','referral_bonus','deposit','fee','refund') NOT NULL,
  `description` text DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `fee_amount` decimal(12,2) DEFAULT 0.00,
  `net_amount` decimal(12,2) DEFAULT NULL,
  `webhook_received` tinyint(1) DEFAULT 0,
  `webhook_data` json DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `idx_payments_user_id` (`user_id`),
  KEY `idx_payments_status` (`status`),
  KEY `idx_payments_type` (`type`),
  KEY `idx_payments_created_at` (`created_at`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment webhooks table for Plisio
CREATE TABLE `payment_webhooks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider` varchar(50) NOT NULL,
  `webhook_id` varchar(255) DEFAULT NULL,
  `event_type` varchar(100) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `raw_data` json NOT NULL,
  `processed` tinyint(1) DEFAULT 0,
  `processing_attempts` int(11) DEFAULT 0,
  `last_processing_error` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_payment_webhooks_provider` (`provider`),
  KEY `idx_payment_webhooks_processed` (`processed`),
  CONSTRAINT `payment_webhooks_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rentals table
CREATE TABLE `rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `plan_type` enum('basic','standard','premium','custom') NOT NULL,
  `plan_name` varchar(100) DEFAULT NULL,
  `rental_duration` int(11) NOT NULL,
  `daily_profit_rate` decimal(5,2) NOT NULL,
  `total_cost` decimal(12,2) NOT NULL,
  `setup_fee` decimal(8,2) DEFAULT 0.00,
  `expected_daily_profit` decimal(8,2) NOT NULL,
  `actual_total_profit` decimal(12,2) DEFAULT 0.00,
  `total_days_active` int(11) DEFAULT 0,
  `performance_bonus` decimal(8,2) DEFAULT 0.00,
  `status` enum('pending','active','completed','cancelled','suspended','expired') DEFAULT 'pending',
  `auto_renew` tinyint(1) DEFAULT 0,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `actual_start_date` date DEFAULT NULL,
  `actual_end_date` date DEFAULT NULL,
  `last_profit_date` date DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rentals_user_id` (`user_id`),
  KEY `idx_rentals_device_id` (`device_id`),
  KEY `idx_rentals_status` (`status`),
  KEY `idx_rentals_dates` (`start_date`,`end_date`),
  CONSTRAINT `rentals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rentals_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rentals_ibfk_3` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investments table
CREATE TABLE `investments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `plan_name` varchar(100) NOT NULL,
  `plan_duration` int(11) NOT NULL,
  `investment_amount` decimal(12,2) NOT NULL,
  `daily_rate` decimal(6,4) NOT NULL,
  `expected_daily_profit` decimal(8,2) NOT NULL,
  `total_earned` decimal(12,2) DEFAULT 0.00,
  `total_days_active` int(11) DEFAULT 0,
  `compound_interest` tinyint(1) DEFAULT 0,
  `auto_reinvest` tinyint(1) DEFAULT 0,
  `reinvest_percentage` decimal(5,2) DEFAULT 0.00,
  `status` enum('pending','active','completed','cancelled','suspended','matured') DEFAULT 'pending',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `actual_start_date` date DEFAULT NULL,
  `maturity_date` date DEFAULT NULL,
  `last_profit_date` date DEFAULT NULL,
  `early_withdrawal_fee` decimal(5,2) DEFAULT 10.00,
  `withdrawal_allowed_after` int(11) DEFAULT 30,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_investments_user_id` (`user_id`),
  KEY `idx_investments_status` (`status`),
  KEY `idx_investments_dates` (`start_date`,`end_date`),
  CONSTRAINT `investments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `investments_ibfk_2` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Referrals table
CREATE TABLE `referrals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `referrer_id` int(11) NOT NULL,
  `referred_id` int(11) NOT NULL,
  `level` smallint(6) NOT NULL CHECK (`level` IN (1,2,3)),
  `commission_rate` decimal(5,2) NOT NULL,
  `total_commission_earned` decimal(12,2) DEFAULT 0.00,
  `total_referral_volume` decimal(12,2) DEFAULT 0.00,
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `first_earning_date` date DEFAULT NULL,
  `last_earning_date` date DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `referrer_id_referred_id` (`referrer_id`,`referred_id`),
  KEY `idx_referrals_referrer_id` (`referrer_id`),
  KEY `idx_referrals_referred_id` (`referred_id`),
  KEY `idx_referrals_level` (`level`),
  CONSTRAINT `referrals_ibfk_1` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referrals_ibfk_2` FOREIGN KEY (`referred_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rental earnings table
CREATE TABLE `rental_earnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rental_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL,
  `earning_date` date NOT NULL,
  `base_profit_amount` decimal(8,2) NOT NULL,
  `performance_bonus` decimal(8,2) DEFAULT 0.00,
  `total_profit_amount` decimal(8,2) NOT NULL,
  `device_uptime` decimal(5,2) DEFAULT 100.00,
  `performance_factor` decimal(4,3) DEFAULT 1.000,
  `weather_factor` decimal(4,3) DEFAULT 1.000,
  `network_quality` decimal(5,2) DEFAULT 100.00,
  `processed` tinyint(1) DEFAULT 0,
  `processed_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rental_id_earning_date` (`rental_id`,`earning_date`),
  KEY `idx_rental_earnings_rental_id` (`rental_id`),
  KEY `idx_rental_earnings_user_id` (`user_id`),
  KEY `idx_rental_earnings_earning_date` (`earning_date`),
  CONSTRAINT `rental_earnings_ibfk_1` FOREIGN KEY (`rental_id`) REFERENCES `rentals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rental_earnings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rental_earnings_ibfk_3` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Investment earnings table
CREATE TABLE `investment_earnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `investment_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `earning_date` date NOT NULL,
  `base_amount` decimal(12,2) NOT NULL,
  `daily_rate` decimal(6,4) NOT NULL,
  `profit_amount` decimal(8,2) NOT NULL,
  `compound_amount` decimal(8,2) DEFAULT 0.00,
  `reinvested_amount` decimal(8,2) DEFAULT 0.00,
  `paid_amount` decimal(8,2) NOT NULL,
  `processed` tinyint(1) DEFAULT 0,
  `processed_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `investment_id_earning_date` (`investment_id`,`earning_date`),
  KEY `idx_investment_earnings_investment_id` (`investment_id`),
  KEY `idx_investment_earnings_user_id` (`user_id`),
  KEY `idx_investment_earnings_earning_date` (`earning_date`),
  CONSTRAINT `investment_earnings_ibfk_1` FOREIGN KEY (`investment_id`) REFERENCES `investments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `investment_earnings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Referral earnings table
CREATE TABLE `referral_earnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `referral_id` int(11) NOT NULL,
  `referrer_id` int(11) NOT NULL,
  `referred_id` int(11) NOT NULL,
  `source_type` enum('rental','investment','deposit') NOT NULL,
  `source_id` int(11) NOT NULL,
  `level` smallint(6) NOT NULL CHECK (`level` IN (1,2,3)),
  `commission_rate` decimal(5,2) NOT NULL,
  `base_amount` decimal(12,2) NOT NULL,
  `commission_amount` decimal(8,2) NOT NULL,
  `earning_date` date NOT NULL,
  `processed` tinyint(1) DEFAULT 0,
  `processed_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_referral_earnings_referral_id` (`referral_id`),
  KEY `idx_referral_earnings_referrer_id` (`referrer_id`),
  KEY `idx_referral_earnings_earning_date` (`earning_date`),
  CONSTRAINT `referral_earnings_ibfk_1` FOREIGN KEY (`referral_id`) REFERENCES `referrals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referral_earnings_ibfk_2` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referral_earnings_ibfk_3` FOREIGN KEY (`referred_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device maintenance table
CREATE TABLE `device_maintenance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_id` int(11) NOT NULL,
  `maintenance_type` enum('scheduled','emergency','repair','upgrade','inspection','replacement') NOT NULL,
  `priority` enum('low','medium','high','critical') DEFAULT 'medium',
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT 0.00,
  `technician` varchar(100) DEFAULT NULL,
  `technician_contact` varchar(100) DEFAULT NULL,
  `vendor` varchar(100) DEFAULT NULL,
  `parts_used` json DEFAULT NULL,
  `scheduled_date` timestamp NULL DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `estimated_duration` int(11) DEFAULT NULL,
  `actual_duration` int(11) DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled','postponed') DEFAULT 'scheduled',
  `result` enum('successful','failed','partial','needs_followup') DEFAULT NULL,
  `downtime_minutes` int(11) DEFAULT 0,
  `performance_impact` decimal(5,2) DEFAULT 0.00,
  `before_photos` json DEFAULT NULL,
  `after_photos` json DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `next_maintenance_date` date DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_maintenance_device_id` (`device_id`),
  KEY `idx_device_maintenance_status` (`status`),
  CONSTRAINT `device_maintenance_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Withdrawal requests table
CREATE TABLE `withdrawal_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `fee_amount` decimal(8,2) DEFAULT 0.00,
  `net_amount` decimal(12,2) NOT NULL,
  `withdrawal_method` enum('crypto','bank_transfer','paypal','binance') NOT NULL,
  `withdrawal_address` text DEFAULT NULL,
  `bank_details` json DEFAULT NULL,
  `status` enum('pending','approved','processing','completed','rejected','cancelled') DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `user_notes` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `transaction_hash` varchar(200) DEFAULT NULL,
  `external_transaction_id` varchar(200) DEFAULT NULL,
  `requested_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_withdrawal_requests_user_id` (`user_id`),
  KEY `idx_withdrawal_requests_status` (`status`),
  CONSTRAINT `withdrawal_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `withdrawal_requests_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Telegram sessions table
CREATE TABLE `telegram_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `telegram_id` bigint(20) NOT NULL,
  `session_data` json DEFAULT NULL,
  `init_data` text DEFAULT NULL,
  `init_data_hash` varchar(64) DEFAULT NULL,
  `auth_date` int(11) DEFAULT NULL,
  `query_id` varchar(100) DEFAULT NULL,
  `chat_type` varchar(20) DEFAULT NULL,
  `chat_instance` varchar(50) DEFAULT NULL,
  `start_param` varchar(100) DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT 0,
  `language_code` varchar(10) DEFAULT 'en',
  `platform` varchar(20) DEFAULT NULL,
  `version` varchar(20) DEFAULT NULL,
  `theme_params` json DEFAULT NULL,
  `viewport_height` int(11) DEFAULT NULL,
  `viewport_stable_height` int(11) DEFAULT NULL,
  `header_color` varchar(7) DEFAULT NULL,
  `background_color` varchar(7) DEFAULT NULL,
  `is_expanded` tinyint(1) DEFAULT 0,
  `is_closing_confirmation_enabled` tinyint(1) DEFAULT 0,
  `last_activity` timestamp DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_telegram_sessions_telegram_id` (`telegram_id`),
  KEY `idx_telegram_sessions_user_id` (`user_id`),
  CONSTRAINT `telegram_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- API logs table
CREATE TABLE `api_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `endpoint` varchar(200) NOT NULL,
  `method` varchar(10) NOT NULL,
  `request_data` json DEFAULT NULL,
  `response_data` json DEFAULT NULL,
  `status_code` int(11) NOT NULL,
  `response_time` decimal(8,3) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_api_logs_user_id` (`user_id`),
  KEY `idx_api_logs_created_at` (`created_at`),
  CONSTRAINT `api_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `api_logs_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notification logs table
CREATE TABLE `notification_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `type` enum('email','telegram','sms','push','system') NOT NULL,
  `channel` varchar(50) DEFAULT NULL,
  `recipient` varchar(200) NOT NULL,
  `subject` varchar(200) DEFAULT NULL,
  `message` text NOT NULL,
  `template` varchar(100) DEFAULT NULL,
  `template_data` json DEFAULT NULL,
  `status` enum('pending','sent','delivered','failed','bounced') DEFAULT 'pending',
  `provider` varchar(50) DEFAULT NULL,
  `provider_id` varchar(100) DEFAULT NULL,
  `provider_response` json DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `opened_at` timestamp NULL DEFAULT NULL,
  `clicked_at` timestamp NULL DEFAULT NULL,
  `retry_count` int(11) DEFAULT 0,
  `max_retries` int(11) DEFAULT 3,
  `next_retry_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notification_logs_user_id` (`user_id`),
  KEY `idx_notification_logs_status` (`status`),
  CONSTRAINT `notification_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Email notifications table
CREATE TABLE `email_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `template_name` varchar(100) NOT NULL,
  `template_data` json DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending' CHECK (`status` IN ('pending','sent','failed','delivered')),
  `provider` varchar(50) DEFAULT NULL,
  `provider_message_id` varchar(255) DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `retry_count` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_notifications_user_id` (`user_id`),
  KEY `idx_email_notifications_status` (`status`),
  CONSTRAINT `email_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- System settings table
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','number','boolean','json','text') DEFAULT 'string',
  `category` varchar(50) DEFAULT 'general',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_system_settings_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin user
INSERT INTO `admin_users` (`username`, `email`, `password_hash`, `role`, `status`, `created_at`) VALUES
('admin', 'admin@starlink-rent.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'active', NOW());

-- Insert sample devices
INSERT INTO `devices` (`device_id`, `name`, `model`, `location`, `latitude`, `longitude`, `status`, `daily_rate`, `max_speed_down`, `max_speed_up`, `uptime_percentage`, `created_at`) VALUES
('SL001', 'Starlink Alpha', 'Starlink Standard', 'New York, USA', 40.7128, -74.0060, 'available', 15.00, 200, 20, 99.50, NOW()),
('SL002', 'Starlink Beta', 'Starlink Standard', 'London, UK', 51.5074, -0.1278, 'available', 18.00, 250, 25, 99.80, NOW()),
('SL003', 'Starlink Gamma', 'Starlink Premium', 'Tokyo, Japan', 35.6762, 139.6503, 'available', 25.00, 300, 30, 99.90, NOW()),
('SL004', 'Starlink Delta', 'Starlink Standard', 'Sydney, Australia', -33.8688, 151.2093, 'available', 20.00, 220, 22, 99.60, NOW()),
('SL005', 'Starlink Epsilon', 'Starlink Premium', 'Berlin, Germany', 52.5200, 13.4050, 'available', 22.00, 280, 28, 99.70, NOW());

-- Insert device plans
INSERT INTO `device_plans` (`plan_name`, `plan_type`, `daily_rate`, `max_speed_mbps`, `generation`, `minimum_days`, `setup_fee`, `features`, `description`, `is_popular`, `is_active`) VALUES
('Basic Starlink', 'basic', 15.00, 200, 'gen2', 30, 0.00, '["Standard speeds", "Basic support", "99% uptime guarantee"]', 'Perfect for getting started with satellite internet rental', 0, 1),
('Pro Starlink', 'pro', 25.00, 300, 'gen3', 30, 0.00, '["High speeds", "Priority support", "99.5% uptime guarantee", "Performance monitoring"]', 'Best value for serious investors', 1, 1),
('Enterprise Starlink', 'enterprise', 50.00, 500, 'enterprise', 30, 0.00, '["Ultra-high speeds", "24/7 VIP support", "99.9% uptime guarantee", "Advanced analytics", "Backup systems"]', 'Maximum performance and reliability', 0, 1);

-- Insert system settings for Plisio and email
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`, `is_public`) VALUES
('site_name', 'Starlink Rent', 'string', 'general', 'Website name', 1),
('site_url', 'https://starlink-rent.com', 'string', 'general', 'Website URL', 1),
('plisio_api_key', '', 'string', 'payments', 'Plisio.net API key for crypto payments', 0),
('plisio_webhook_url', '', 'string', 'payments', 'Plisio webhook URL', 0),
('binance_api_key', '', 'string', 'payments', 'Binance API key', 0),
('binance_secret', '', 'string', 'payments', 'Binance API secret', 0),
('min_deposit', '50', 'number', 'payments', 'Minimum deposit amount', 1),
('max_deposit', '10000', 'number', 'payments', 'Maximum deposit amount', 1),
('min_withdrawal', '20', 'number', 'payments', 'Minimum withdrawal amount', 1),
('withdrawal_fee', '2.0', 'number', 'payments', 'Withdrawal fee percentage', 1),
('smtp_host', '', 'string', 'email', 'SMTP server host', 0),
('smtp_port', '587', 'number', 'email', 'SMTP server port', 0),
('smtp_username', '', 'string', 'email', 'SMTP username', 0),
('smtp_password', '', 'string', 'email', 'SMTP password', 0),
('smtp_secure', 'tls', 'string', 'email', 'SMTP security (tls/ssl)', 0),
('email_from', 'noreply@starlink-rent.com', 'string', 'email', 'From email address', 0),
('email_from_name', 'Starlink Rent', 'string', 'email', 'From name', 0),
('email_notifications_enabled', '1', 'boolean', 'email', 'Enable email notifications', 0),
('welcome_email_enabled', '1', 'boolean', 'email', 'Enable welcome emails', 0),
('deposit_email_enabled', '1', 'boolean', 'email', 'Enable deposit confirmation emails', 0),
('withdrawal_email_enabled', '1', 'boolean', 'email', 'Enable withdrawal notification emails', 0),
('daily_earnings_email_enabled', '0', 'boolean', 'email', 'Enable daily earnings emails', 0),
('referral_email_enabled', '1', 'boolean', 'email', 'Enable referral bonus emails', 0),
('telegram_bot_token', '', 'string', 'telegram', 'Telegram bot token', 0),
('referral_level1_rate', '7.0', 'number', 'referrals', 'Level 1 referral commission rate', 1),
('referral_level2_rate', '5.0', 'number', 'referrals', 'Level 2 referral commission rate', 1),
('referral_level3_rate', '3.0', 'number', 'referrals', 'Level 3 referral commission rate', 1);

-- Create triggers for automatic timestamp updates
DELIMITER $$

CREATE TRIGGER `update_users_timestamp` BEFORE UPDATE ON `users`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_admin_users_timestamp` BEFORE UPDATE ON `admin_users`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_devices_timestamp` BEFORE UPDATE ON `devices`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_device_plans_timestamp` BEFORE UPDATE ON `device_plans`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_payments_timestamp` BEFORE UPDATE ON `payments`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_rentals_timestamp` BEFORE UPDATE ON `rentals`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_investments_timestamp` BEFORE UPDATE ON `investments`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_referrals_timestamp` BEFORE UPDATE ON `referrals`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_device_maintenance_timestamp` BEFORE UPDATE ON `device_maintenance`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_telegram_sessions_timestamp` BEFORE UPDATE ON `telegram_sessions`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_notification_logs_timestamp` BEFORE UPDATE ON `notification_logs`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `update_system_settings_timestamp` BEFORE UPDATE ON `system_settings`
FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Database schema creation completed
-- Default admin login: username = admin, password = admin123
-- Remember to change the default admin password after installation!