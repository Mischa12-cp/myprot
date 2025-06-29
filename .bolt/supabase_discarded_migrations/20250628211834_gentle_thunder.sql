-- Starlink Rent Devices - Complete MySQL 8.0 Database Schema
-- Version: 2.0.0
-- Created: 2024
-- Description: Full database structure for Starlink rental system with investment features

SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS withdrawal_requests;
DROP TABLE IF EXISTS telegram_sessions;
DROP TABLE IF EXISTS notification_logs;
DROP TABLE IF EXISTS api_logs;
DROP TABLE IF EXISTS device_maintenance;
DROP TABLE IF EXISTS investment_earnings;
DROP TABLE IF EXISTS rental_earnings;
DROP TABLE IF EXISTS referral_earnings;
DROP TABLE IF EXISTS investments;
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS referrals;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS system_settings;
DROP TABLE IF EXISTS admin_sessions;
DROP TABLE IF EXISTS admin_users;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

-- USERS TABLE - Main user accounts
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  referral_code VARCHAR(20) NOT NULL UNIQUE,
  referred_by INT NULL,
  telegram_id BIGINT UNIQUE NULL,
  telegram_username VARCHAR(50) NULL,
  telegram_first_name VARCHAR(100) NULL,
  telegram_last_name VARCHAR(100) NULL,
  telegram_photo_url TEXT NULL,
  balance DECIMAL(12,2) DEFAULT 0.00,
  total_earnings DECIMAL(12,2) DEFAULT 0.00,
  total_invested DECIMAL(12,2) DEFAULT 0.00,
  total_withdrawn DECIMAL(12,2) DEFAULT 0.00,
  referral_earnings DECIMAL(12,2) DEFAULT 0.00,
  rental_earnings DECIMAL(12,2) DEFAULT 0.00,
  investment_earnings DECIMAL(12,2) DEFAULT 0.00,
  phone VARCHAR(20) NULL,
  country VARCHAR(50) NULL,
  timezone VARCHAR(50) DEFAULT 'UTC',
  language VARCHAR(10) DEFAULT 'en',
  status ENUM('active', 'suspended', 'pending', 'banned') DEFAULT 'active',
  email_verified BOOLEAN DEFAULT FALSE,
  telegram_verified BOOLEAN DEFAULT FALSE,
  kyc_status ENUM('none', 'pending', 'approved', 'rejected') DEFAULT 'none',
  kyc_documents JSON NULL,
  last_login TIMESTAMP NULL,
  last_activity TIMESTAMP NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (referred_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- USER SESSIONS TABLE
CREATE TABLE user_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  session_token VARCHAR(255) NOT NULL UNIQUE,
  device_info TEXT NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ADMIN USERS TABLE
CREATE TABLE admin_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('super_admin', 'admin', 'moderator', 'support') DEFAULT 'admin',
  permissions JSON NULL,
  two_factor_secret VARCHAR(32) NULL,
  two_factor_enabled BOOLEAN DEFAULT FALSE,
  status ENUM('active', 'suspended', 'inactive') DEFAULT 'active',
  last_login TIMESTAMP NULL,
  last_activity TIMESTAMP NULL,
  login_attempts INT DEFAULT 0,
  locked_until TIMESTAMP NULL,
  ip_address VARCHAR(45) NULL,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ADMIN SESSIONS TABLE
CREATE TABLE admin_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admin_id INT NOT NULL,
  session_token VARCHAR(255) NOT NULL UNIQUE,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES admin_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- SYSTEM SETTINGS TABLE
CREATE TABLE system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT NOT NULL,
  setting_type ENUM('string', 'number', 'boolean', 'json', 'text') DEFAULT 'string',
  category VARCHAR(50) DEFAULT 'general',
  description TEXT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  updated_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- DEVICES TABLE
CREATE TABLE devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_id VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  model VARCHAR(50) DEFAULT 'Starlink Standard',
  serial_number VARCHAR(100) UNIQUE NULL,
  location VARCHAR(100) NULL,
  latitude DECIMAL(10,8) NULL,
  longitude DECIMAL(11,8) NULL,
  status ENUM('available', 'rented', 'maintenance', 'offline', 'reserved') DEFAULT 'available',
  daily_rate DECIMAL(8,2) NOT NULL DEFAULT 15.00,
  setup_fee DECIMAL(8,2) DEFAULT 0.00,
  max_speed_down INT DEFAULT 200,
  max_speed_up INT DEFAULT 20,
  uptime_percentage DECIMAL(5,2) DEFAULT 99.00,
  total_earnings DECIMAL(12,2) DEFAULT 0.00,
  total_rentals INT DEFAULT 0,
  specifications JSON NULL,
  features JSON NULL,
  images JSON NULL,
  installation_date DATE NULL,
  warranty_expires DATE NULL,
  maintenance_schedule VARCHAR(20) DEFAULT 'monthly',
  last_maintenance DATE NULL,
  next_maintenance DATE NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- PAYMENTS TABLE
CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  transaction_id VARCHAR(100) UNIQUE NULL,
  external_id VARCHAR(100) NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'USD',
  crypto_currency VARCHAR(20) NULL,
  crypto_amount DECIMAL(20,8) NULL,
  exchange_rate DECIMAL(15,8) NULL,
  payment_method ENUM('crypto', 'binance', 'card', 'bank_transfer', 'balance', 'manual') NOT NULL,
  payment_provider VARCHAR(50) NULL,
  provider_transaction_id VARCHAR(200) NULL,
  provider_response JSON NULL,
  status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'expired') DEFAULT 'pending',
  type ENUM('rental', 'investment', 'withdrawal', 'referral_bonus', 'deposit', 'fee', 'refund') NOT NULL,
  description TEXT NULL,
  metadata JSON NULL,
  fee_amount DECIMAL(12,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) NULL,
  webhook_received BOOLEAN DEFAULT FALSE,
  webhook_data JSON NULL,
  processed_at TIMESTAMP NULL,
  expires_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- REFERRALS TABLE
CREATE TABLE referrals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  referrer_id INT NOT NULL,
  referred_id INT NOT NULL,
  level TINYINT NOT NULL CHECK (level IN (1, 2, 3)),
  commission_rate DECIMAL(5,2) NOT NULL,
  total_commission_earned DECIMAL(12,2) DEFAULT 0.00,
  total_referral_volume DECIMAL(12,2) DEFAULT 0.00,
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  first_earning_date DATE NULL,
  last_earning_date DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_referral (referrer_id, referred_id),
  FOREIGN KEY (referrer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (referred_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- RENTALS TABLE
CREATE TABLE rentals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_id INT NOT NULL,
  payment_id INT NULL,
  plan_type ENUM('basic', 'standard', 'premium', 'custom') NOT NULL,
  plan_name VARCHAR(100) NULL,
  rental_duration INT NOT NULL,
  daily_profit_rate DECIMAL(5,2) NOT NULL,
  total_cost DECIMAL(12,2) NOT NULL,
  setup_fee DECIMAL(8,2) DEFAULT 0.00,
  expected_daily_profit DECIMAL(8,2) NOT NULL,
  actual_total_profit DECIMAL(12,2) DEFAULT 0.00,
  total_days_active INT DEFAULT 0,
  performance_bonus DECIMAL(8,2) DEFAULT 0.00,
  status ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'expired') DEFAULT 'pending',
  auto_renew BOOLEAN DEFAULT FALSE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  actual_start_date DATE NULL,
  actual_end_date DATE NULL,
  last_profit_date DATE NULL,
  cancellation_reason TEXT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INVESTMENTS TABLE
CREATE TABLE investments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  payment_id INT NULL,
  plan_name VARCHAR(100) NOT NULL,
  plan_duration INT NOT NULL,
  investment_amount DECIMAL(12,2) NOT NULL,
  daily_rate DECIMAL(6,4) NOT NULL,
  expected_daily_profit DECIMAL(8,2) NOT NULL,
  total_earned DECIMAL(12,2) DEFAULT 0.00,
  total_days_active INT DEFAULT 0,
  compound_interest BOOLEAN DEFAULT FALSE,
  auto_reinvest BOOLEAN DEFAULT FALSE,
  reinvest_percentage DECIMAL(5,2) DEFAULT 0.00,
  status ENUM('pending', 'active', 'completed', 'cancelled', 'suspended', 'matured') DEFAULT 'pending',
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  actual_start_date DATE NULL,
  maturity_date DATE NULL,
  last_profit_date DATE NULL,
  early_withdrawal_fee DECIMAL(5,2) DEFAULT 10.00,
  withdrawal_allowed_after INT DEFAULT 30,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- RENTAL EARNINGS TABLE
CREATE TABLE rental_earnings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rental_id INT NOT NULL,
  user_id INT NOT NULL,
  device_id INT NOT NULL,
  earning_date DATE NOT NULL,
  base_profit_amount DECIMAL(8,2) NOT NULL,
  performance_bonus DECIMAL(8,2) DEFAULT 0.00,
  total_profit_amount DECIMAL(8,2) NOT NULL,
  device_uptime DECIMAL(5,2) DEFAULT 100.00,
  performance_factor DECIMAL(4,3) DEFAULT 1.000,
  weather_factor DECIMAL(4,3) DEFAULT 1.000,
  network_quality DECIMAL(5,2) DEFAULT 100.00,
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_rental_earning (rental_id, earning_date),
  FOREIGN KEY (rental_id) REFERENCES rentals(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INVESTMENT EARNINGS TABLE
CREATE TABLE investment_earnings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  investment_id INT NOT NULL,
  user_id INT NOT NULL,
  earning_date DATE NOT NULL,
  base_amount DECIMAL(12,2) NOT NULL,
  daily_rate DECIMAL(6,4) NOT NULL,
  profit_amount DECIMAL(8,2) NOT NULL,
  compound_amount DECIMAL(8,2) DEFAULT 0.00,
  reinvested_amount DECIMAL(8,2) DEFAULT 0.00,
  paid_amount DECIMAL(8,2) NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_investment_earning (investment_id, earning_date),
  FOREIGN KEY (investment_id) REFERENCES investments(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- REFERRAL EARNINGS TABLE
CREATE TABLE referral_earnings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  referral_id INT NOT NULL,
  referrer_id INT NOT NULL,
  referred_id INT NOT NULL,
  source_type ENUM('rental', 'investment', 'deposit') NOT NULL,
  source_id INT NOT NULL,
  level TINYINT NOT NULL CHECK (level IN (1, 2, 3)),
  commission_rate DECIMAL(5,2) NOT NULL,
  base_amount DECIMAL(12,2) NOT NULL,
  commission_amount DECIMAL(8,2) NOT NULL,
  earning_date DATE NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (referral_id) REFERENCES referrals(id) ON DELETE CASCADE,
  FOREIGN KEY (referrer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (referred_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- WITHDRAWAL REQUESTS TABLE
CREATE TABLE withdrawal_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  fee_amount DECIMAL(8,2) DEFAULT 0.00,
  net_amount DECIMAL(12,2) NOT NULL,
  withdrawal_method ENUM('crypto', 'bank_transfer', 'paypal', 'binance') NOT NULL,
  withdrawal_address TEXT NULL,
  bank_details JSON NULL,
  status ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') DEFAULT 'pending',
  admin_notes TEXT NULL,
  user_notes TEXT NULL,
  processed_by INT NULL,
  transaction_hash VARCHAR(200) NULL,
  external_transaction_id VARCHAR(200) NULL,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (processed_by) REFERENCES admin_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create indexes for better performance
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_telegram_id ON users(telegram_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_admin_users_role ON admin_users(role);
CREATE INDEX idx_admin_users_status ON admin_users(status);
CREATE INDEX idx_admin_sessions_admin_id ON admin_sessions(admin_id);
CREATE INDEX idx_admin_sessions_expires_at ON admin_sessions(expires_at);
CREATE INDEX idx_system_settings_category ON system_settings(category);
CREATE INDEX idx_devices_device_id ON devices(device_id);
CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_location ON devices(location);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_type ON payments(type);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referrals_referred_id ON referrals(referred_id);
CREATE INDEX idx_referrals_level ON referrals(level);
CREATE INDEX idx_rentals_user_id ON rentals(user_id);
CREATE INDEX idx_rentals_device_id ON rentals(device_id);
CREATE INDEX idx_rentals_status ON rentals(status);
CREATE INDEX idx_rentals_dates ON rentals(start_date, end_date);
CREATE INDEX idx_investments_user_id ON investments(user_id);
CREATE INDEX idx_investments_status ON investments(status);
CREATE INDEX idx_investments_dates ON investments(start_date, end_date);
CREATE INDEX idx_rental_earnings_rental_id ON rental_earnings(rental_id);
CREATE INDEX idx_rental_earnings_user_id ON rental_earnings(user_id);
CREATE INDEX idx_rental_earnings_earning_date ON rental_earnings(earning_date);
CREATE INDEX idx_investment_earnings_investment_id ON investment_earnings(investment_id);
CREATE INDEX idx_investment_earnings_user_id ON investment_earnings(user_id);
CREATE INDEX idx_investment_earnings_earning_date ON investment_earnings(earning_date);
CREATE INDEX idx_referral_earnings_referral_id ON referral_earnings(referral_id);
CREATE INDEX idx_referral_earnings_referrer_id ON referral_earnings(referrer_id);
CREATE INDEX idx_referral_earnings_earning_date ON referral_earnings(earning_date);
CREATE INDEX idx_withdrawal_requests_user_id ON withdrawal_requests(user_id);
CREATE INDEX idx_withdrawal_requests_status ON withdrawal_requests(status);

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description, is_public) VALUES
-- Referral Settings
('referral_level_1_rate', '7.00', 'number', 'referral', 'Level 1 referral commission rate (%)', 1),
('referral_level_2_rate', '5.00', 'number', 'referral', 'Level 2 referral commission rate (%)', 1),
('referral_level_3_rate', '3.00', 'number', 'referral', 'Level 3 referral commission rate (%)', 1),
('referral_max_levels', '3', 'number', 'referral', 'Maximum referral levels', 1),
('referral_min_activity', '100', 'number', 'referral', 'Minimum referred user activity for commission ($)', 1),

-- Investment Plans
('investment_3month_rate', '0.27', 'number', 'investment', 'Daily rate for 3-month investment plan (%)', 1),
('investment_6month_rate', '0.40', 'number', 'investment', 'Daily rate for 6-month investment plan (%)', 1),
('investment_12month_rate', '0.60', 'number', 'investment', 'Daily rate for 12-month investment plan (%)', 1),
('min_investment_3month', '500', 'number', 'investment', 'Minimum investment for 3-month plan ($)', 1),
('min_investment_6month', '1000', 'number', 'investment', 'Minimum investment for 6-month plan ($)', 1),
('min_investment_12month', '2000', 'number', 'investment', 'Minimum investment for 12-month plan ($)', 1),
('max_investment_amount', '50000', 'number', 'investment', 'Maximum single investment amount ($)', 1),
('early_withdrawal_fee', '10.00', 'number', 'investment', 'Early withdrawal fee (%)', 1),

-- Rental Plans
('rental_basic_rate', '5.00', 'number', 'rental', 'Basic plan daily profit rate (%)', 1),
('rental_standard_rate', '8.00', 'number', 'rental', 'Standard plan daily profit rate (%)', 1),
('rental_premium_rate', '12.00', 'number', 'rental', 'Premium plan daily profit rate (%)', 1),
('rental_min_duration', '30', 'number', 'rental', 'Minimum rental duration (days)', 1),
('rental_max_duration', '365', 'number', 'rental', 'Maximum rental duration (days)', 1),

-- Payment Settings
('plisio_api_key', '', 'string', 'payment', 'Plisio payment gateway API key', 0),
('plisio_secret_key', '', 'string', 'payment', 'Plisio payment gateway secret key', 0),
('binance_api_key', '', 'string', 'payment', 'Binance payment gateway API key', 0),
('binance_secret_key', '', 'string', 'payment', 'Binance payment gateway secret key', 0),
('min_deposit_amount', '50', 'number', 'payment', 'Minimum deposit amount ($)', 1),
('max_deposit_amount', '10000', 'number', 'payment', 'Maximum deposit amount ($)', 1),
('min_withdrawal_amount', '20', 'number', 'payment', 'Minimum withdrawal amount ($)', 1),
('withdrawal_fee_percentage', '2.00', 'number', 'payment', 'Withdrawal fee percentage (%)', 1),
('withdrawal_fee_minimum', '5.00', 'number', 'payment', 'Minimum withdrawal fee ($)', 1),

-- Telegram Settings
('telegram_bot_token', '', 'string', 'telegram', 'Telegram bot token for mini app', 0),
('telegram_webhook_url', '', 'string', 'telegram', 'Telegram webhook URL', 0),
('telegram_notifications_enabled', '1', 'boolean', 'telegram', 'Enable Telegram notifications', 1),

-- Site Settings
('site_name', 'Starlink Rent', 'string', 'general', 'Site name', 1),
('site_url', 'https://starlink-rent.com', 'string', 'general', 'Site URL', 1),
('site_description', 'Rent Starlink devices and earn daily profits', 'string', 'general', 'Site description', 1),
('site_maintenance', '0', 'boolean', 'general', 'Site maintenance mode', 1),
('site_timezone', 'UTC', 'string', 'general', 'Site timezone', 1),
('site_currency', 'USD', 'string', 'general', 'Site currency', 1),
('site_language', 'en', 'string', 'general', 'Default site language', 1);

-- Insert sample admin user (password: admin123)
INSERT INTO admin_users (username, email, password_hash, role) VALUES
('admin', 'admin@starlink-rent.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin');

-- Insert sample devices
INSERT INTO devices (device_id, name, model, location, status, daily_rate, max_speed_down, max_speed_up, uptime_percentage, specifications, features) VALUES
('STL-001', 'Starlink Terminal 001', 'Starlink Standard', 'New York, USA', 'available', 15.00, 200, 20, 99.8, '{"antenna_type": "phased_array", "power_consumption": "50-75W", "operating_temp": "-30°C to +60°C"}', '["High-speed internet", "Low latency", "Weather resistant"]'),
('STL-002', 'Starlink Terminal 002', 'Starlink Standard', 'California, USA', 'available', 15.00, 200, 20, 99.5, '{"antenna_type": "phased_array", "power_consumption": "50-75W", "operating_temp": "-30°C to +60°C"}', '["High-speed internet", "Low latency", "Weather resistant"]'),
('STL-003', 'Starlink Terminal 003', 'Starlink Standard', 'Texas, USA', 'rented', 15.00, 200, 20, 99.9, '{"antenna_type": "phased_array", "power_consumption": "50-75W", "operating_temp": "-30°C to +60°C"}', '["High-speed internet", "Low latency", "Weather resistant"]'),
('STL-004', 'Starlink Terminal 004', 'Starlink Standard', 'Florida, USA', 'available', 15.00, 200, 20, 98.7, '{"antenna_type": "phased_array", "power_consumption": "50-75W", "operating_temp": "-30°C to +60°C"}', '["High-speed internet", "Low latency", "Weather resistant"]'),
('STL-005', 'Starlink Terminal 005', 'Starlink Standard', 'Nevada, USA', 'maintenance', 15.00, 200, 20, 97.2, '{"antenna_type": "phased_array", "power_consumption": "50-75W", "operating_temp": "-30°C to +60°C"}', '["High-speed internet", "Low latency", "Weather resistant"]');

-- Insert sample users with referral relationships
INSERT INTO users (username, email, password_hash, referral_code, referred_by, balance, total_earnings, status, email_verified) VALUES
('john_doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'JOHN2024ABC', NULL, 1234.50, 2547.85, 'active', 1),
('sarah_k', 'sarah@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'SARAH2024XYZ', 1, 889.25, 1867.40, 'active', 1),
('mike_chen', 'mike@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'MIKE2024DEF', 2, 567.80, 1234.60, 'active', 1),
('emma_w', 'emma@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'EMMA2024GHI', 1, 756.90, 1543.20, 'active', 1),
('alex_r', 'alex@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ALEX2024JKL', 3, 343.20, 678.50, 'active', 1);

-- Create referral relationships
INSERT INTO referrals (referrer_id, referred_id, level, commission_rate, status) VALUES
(1, 2, 1, 7.00, 'active'),
(2, 3, 1, 7.00, 'active'),
(1, 3, 2, 5.00, 'active'),
(1, 4, 1, 7.00, 'active'),
(3, 5, 1, 7.00, 'active'),
(2, 5, 2, 5.00, 'active'),
(1, 5, 3, 3.00, 'active');

-- Insert sample investments
INSERT INTO investments (user_id, plan_name, plan_duration, investment_amount, daily_rate, expected_daily_profit, status, start_date, end_date, actual_start_date, total_earned) VALUES
(1, '6 Month Investment Plan', 180, 2000.00, 0.40, 8.00, 'active', '2024-01-01', '2024-06-29', '2024-01-01', 456.00),
(2, '3 Month Investment Plan', 90, 1000.00, 0.27, 2.70, 'active', '2024-01-15', '2024-04-15', '2024-01-15', 189.00),
(4, '12 Month Investment Plan', 365, 5000.00, 0.60, 30.00, 'active', '2024-01-10', '2025-01-10', '2024-01-10', 1200.00);

SET FOREIGN_KEY_CHECKS = 1;