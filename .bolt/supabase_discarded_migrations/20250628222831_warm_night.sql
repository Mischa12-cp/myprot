-- Starlink Rent Devices - Complete Database Schema
-- Version: 2.0.0
-- Compatible with MySQL 8.0+

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Database creation
CREATE DATABASE IF NOT EXISTS `starlink_rent` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `starlink_rent`;

-- --------------------------------------------------------
-- Table structure for table `admin_users`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_admin_users_role` (`role`),
  KEY `idx_admin_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `admin_sessions`
-- --------------------------------------------------------

CREATE TABLE `admin_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token` (`session_token`),
  KEY `idx_admin_sessions_admin_id` (`admin_id`),
  KEY `idx_admin_sessions_expires_at` (`expires_at`),
  CONSTRAINT `admin_sessions_admin_id_fkey` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `referral_code` (`referral_code`),
  UNIQUE KEY `telegram_id` (`telegram_id`),
  KEY `idx_users_referral_code` (`referral_code`),
  KEY `idx_users_status` (`status`),
  KEY `idx_users_created_at` (`created_at`),
  KEY `idx_users_telegram_id` (`telegram_id`),
  CONSTRAINT `users_referred_by_fkey` FOREIGN KEY (`referred_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_sessions`
-- --------------------------------------------------------

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `device_info` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `session_token` (`session_token`),
  KEY `idx_user_sessions_user_id` (`user_id`),
  KEY `idx_user_sessions_expires_at` (`expires_at`),
  CONSTRAINT `user_sessions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `devices`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `device_id` (`device_id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `idx_devices_device_id` (`device_id`),
  KEY `idx_devices_status` (`status`),
  KEY `idx_devices_location` (`location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `device_plans`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_plans_plan_type` (`plan_type`),
  KEY `idx_device_plans_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `payments`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id` (`transaction_id`),
  KEY `idx_payments_user_id` (`user_id`),
  KEY `idx_payments_status` (`status`),
  KEY `idx_payments_type` (`type`),
  KEY `idx_payments_created_at` (`created_at`),
  CONSTRAINT `payments_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `payment_webhooks`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_payment_webhooks_provider` (`provider`),
  KEY `idx_payment_webhooks_processed` (`processed`),
  CONSTRAINT `payment_webhooks_payment_id_fkey` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `referrals`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `referrals_referrer_id_referred_id_key` (`referrer_id`,`referred_id`),
  KEY `idx_referrals_referrer_id` (`referrer_id`),
  KEY `idx_referrals_referred_id` (`referred_id`),
  KEY `idx_referrals_level` (`level`),
  CONSTRAINT `referrals_referred_id_fkey` FOREIGN KEY (`referred_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referrals_referrer_id_fkey` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `rentals`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rentals_user_id` (`user_id`),
  KEY `idx_rentals_device_id` (`device_id`),
  KEY `idx_rentals_status` (`status`),
  KEY `idx_rentals_dates` (`start_date`,`end_date`),
  CONSTRAINT `rentals_device_id_fkey` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rentals_payment_id_fkey` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `rentals_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `rental_earnings`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rental_earnings_rental_id_earning_date_key` (`rental_id`,`earning_date`),
  KEY `idx_rental_earnings_rental_id` (`rental_id`),
  KEY `idx_rental_earnings_user_id` (`user_id`),
  KEY `idx_rental_earnings_earning_date` (`earning_date`),
  CONSTRAINT `rental_earnings_device_id_fkey` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rental_earnings_rental_id_fkey` FOREIGN KEY (`rental_id`) REFERENCES `rentals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rental_earnings_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `investments`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_investments_user_id` (`user_id`),
  KEY `idx_investments_status` (`status`),
  KEY `idx_investments_dates` (`start_date`,`end_date`),
  CONSTRAINT `investments_payment_id_fkey` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `investments_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `investment_earnings`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `investment_earnings_investment_id_earning_date_key` (`investment_id`,`earning_date`),
  KEY `idx_investment_earnings_investment_id` (`investment_id`),
  KEY `idx_investment_earnings_user_id` (`user_id`),
  KEY `idx_investment_earnings_earning_date` (`earning_date`),
  CONSTRAINT `investment_earnings_investment_id_fkey` FOREIGN KEY (`investment_id`) REFERENCES `investments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `investment_earnings_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `referral_earnings`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_referral_earnings_referral_id` (`referral_id`),
  KEY `idx_referral_earnings_referrer_id` (`referrer_id`),
  KEY `idx_referral_earnings_earning_date` (`earning_date`),
  CONSTRAINT `referral_earnings_referral_id_fkey` FOREIGN KEY (`referral_id`) REFERENCES `referrals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referral_earnings_referred_id_fkey` FOREIGN KEY (`referred_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `referral_earnings_referrer_id_fkey` FOREIGN KEY (`referrer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `withdrawal_requests`
-- --------------------------------------------------------

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
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_withdrawal_requests_user_id` (`user_id`),
  KEY `idx_withdrawal_requests_status` (`status`),
  CONSTRAINT `withdrawal_requests_processed_by_fkey` FOREIGN KEY (`processed_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `withdrawal_requests_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `device_maintenance`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_maintenance_device_id` (`device_id`),
  KEY `idx_device_maintenance_status` (`status`),
  CONSTRAINT `device_maintenance_device_id_fkey` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `telegram_sessions`
-- --------------------------------------------------------

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
  `last_activity` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_telegram_sessions_telegram_id` (`telegram_id`),
  KEY `idx_telegram_sessions_user_id` (`user_id`),
  CONSTRAINT `telegram_sessions_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `system_settings`
-- --------------------------------------------------------

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','number','boolean','json','text') DEFAULT 'string',
  `category` varchar(50) DEFAULT 'general',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_system_settings_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `api_logs`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_api_logs_user_id` (`user_id`),
  KEY `idx_api_logs_created_at` (`created_at`),
  CONSTRAINT `api_logs_admin_id_fkey` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `api_logs_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `notification_logs`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notification_logs_user_id` (`user_id`),
  KEY `idx_notification_logs_status` (`status`),
  CONSTRAINT `notification_logs_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `email_notifications`
-- --------------------------------------------------------

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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_notifications_user_id` (`user_id`),
  KEY `idx_email_notifications_status` (`status`),
  CONSTRAINT `email_notifications_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `admin_activity_logs`
-- --------------------------------------------------------

CREATE TABLE `admin_activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `target_type` varchar(50) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `details` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_activity_logs_admin_id` (`admin_id`),
  KEY `idx_admin_activity_logs_created_at` (`created_at`),
  CONSTRAINT `admin_activity_logs_admin_id_fkey` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Sample Data Insertion
-- --------------------------------------------------------

-- Insert default admin user (password: admin123)
INSERT INTO `admin_users` (`username`, `email`, `password_hash`, `role`, `status`) VALUES
('admin', 'admin@starlink-rent.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'active');

-- Insert sample devices
INSERT INTO `devices` (`device_id`, `name`, `model`, `location`, `status`, `daily_rate`, `max_speed_down`, `max_speed_up`, `uptime_percentage`) VALUES
('SL001', 'Starlink Terminal Alpha', 'Starlink Standard', 'New York, USA', 'available', 15.00, 200, 20, 99.50),
('SL002', 'Starlink Terminal Beta', 'Starlink Standard', 'Los Angeles, USA', 'available', 15.00, 200, 20, 99.20),
('SL003', 'Starlink Terminal Gamma', 'Starlink Premium', 'London, UK', 'available', 25.00, 300, 30, 99.80),
('SL004', 'Starlink Terminal Delta', 'Starlink Premium', 'Tokyo, Japan', 'available', 25.00, 300, 30, 99.60),
('SL005', 'Starlink Terminal Epsilon', 'Starlink Enterprise', 'Sydney, Australia', 'available', 40.00, 500, 50, 99.90);

-- Insert device plans
INSERT INTO `device_plans` (`plan_name`, `plan_type`, `daily_rate`, `max_speed_mbps`, `generation`, `minimum_days`, `features`, `description`, `is_popular`) VALUES
('Basic Starlink', 'basic', 15.00, 200, 'gen2', 30, '["Standard speeds", "Basic support", "99% uptime guarantee"]', 'Perfect for getting started with satellite internet rental', 0),
('Pro Starlink', 'pro', 25.00, 300, 'gen3', 30, '["High speeds", "Priority support", "Advanced monitoring", "99.5% uptime guarantee"]', 'Best value for serious investors', 1),
('Enterprise Starlink', 'enterprise', 40.00, 500, 'enterprise', 30, '["Ultra-high speeds", "24/7 VIP support", "Real-time analytics", "99.9% uptime guarantee", "Backup systems"]', 'Maximum performance and reliability', 0);

-- Insert system settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`) VALUES
('site_name', 'Starlink Rent', 'string', 'general', 'Website name'),
('min_deposit', '50', 'number', 'payments', 'Minimum deposit amount in USD'),
('max_deposit', '10000', 'number', 'payments', 'Maximum deposit amount in USD'),
('min_withdrawal', '20', 'number', 'payments', 'Minimum withdrawal amount in USD'),
('withdrawal_fee', '2.0', 'number', 'payments', 'Withdrawal fee percentage'),
('referral_level1_rate', '7.0', 'number', 'referrals', 'Level 1 referral commission rate'),
('referral_level2_rate', '5.0', 'number', 'referrals', 'Level 2 referral commission rate'),
('referral_level3_rate', '3.0', 'number', 'referrals', 'Level 3 referral commission rate'),
('email_notifications_enabled', '1', 'boolean', 'email', 'Enable email notifications'),
('welcome_email_enabled', '1', 'boolean', 'email', 'Enable welcome emails'),
('deposit_email_enabled', '1', 'boolean', 'email', 'Enable deposit confirmation emails'),
('withdrawal_email_enabled', '1', 'boolean', 'email', 'Enable withdrawal notification emails'),
('daily_earnings_email_enabled', '0', 'boolean', 'email', 'Enable daily earnings emails'),
('referral_email_enabled', '1', 'boolean', 'email', 'Enable referral bonus emails');

-- --------------------------------------------------------
-- Triggers and Functions
-- --------------------------------------------------------

DELIMITER $$

-- Function to update updated_at timestamp
CREATE TRIGGER `trigger_users_updated_at` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_devices_updated_at` BEFORE UPDATE ON `devices` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_payments_updated_at` BEFORE UPDATE ON `payments` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_rentals_updated_at` BEFORE UPDATE ON `rentals` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_investments_updated_at` BEFORE UPDATE ON `investments` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_referrals_updated_at` BEFORE UPDATE ON `referrals` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_admin_users_updated_at` BEFORE UPDATE ON `admin_users` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_device_maintenance_updated_at` BEFORE UPDATE ON `device_maintenance` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_telegram_sessions_updated_at` BEFORE UPDATE ON `telegram_sessions` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_notification_logs_updated_at` BEFORE UPDATE ON `notification_logs` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

CREATE TRIGGER `trigger_system_settings_updated_at` BEFORE UPDATE ON `system_settings` FOR EACH ROW BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

COMMIT;

-- --------------------------------------------------------
-- End of Database Schema
-- --------------------------------------------------------