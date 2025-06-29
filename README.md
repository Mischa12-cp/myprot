# Starlink Router Rent - Complete Installation Guide

A comprehensive router rental platform with investment opportunities, 3-level referral system, and crypto payment integration built with React, PHP, and MySQL 8.

## 🚀 Features

- **Premium Router Rental**: Rent Starlink routers with guaranteed daily profits
- **Investment Plans**: 3, 6, and 12-month investment options with daily returns
- **3-Level Referral System**: Earn up to 15% commission from referrals
- **Crypto Payments**: Plisio.net integration for cryptocurrency payments
- **Binance Integration**: Direct Binance Pay support
- **Real-time Analytics**: Dashboard with earnings tracking
- **Responsive Design**: Works on all devices
- **Modern Frontend**: React + TypeScript + Supabase

## 💰 Plisio.net Cryptocurrency Integration

### Supported Cryptocurrencies
- **Bitcoin (BTC)** - The original cryptocurrency
- **Ethereum (ETH)** - Smart contract platform
- **Tether (USDT)** - Stable coin pegged to USD
- **USD Coin (USDC)** - Regulated stable coin
- **Litecoin (LTC)** - Fast and low-cost payments
- **Bitcoin Cash (BCH)** - Bitcoin fork with larger blocks
- **Dogecoin (DOGE)** - Popular meme cryptocurrency
- **TRON (TRX)** - High-throughput blockchain

### Payment Features
- **Instant Processing**: Real-time payment confirmation
- **Low Fees**: Competitive transaction fees
- **Secure**: Bank-level encryption and security
- **Automatic Conversion**: Real-time USD to crypto conversion
- **Webhook Integration**: Automatic payment status updates
- **Multi-Currency**: Support for 15+ cryptocurrencies

## 📋 System Requirements

- **PHP**: 8.0 or higher
- **MySQL**: 8.0 or higher
- **Node.js**: 18.0 or higher (for frontend)
- **Web Server**: Apache/Nginx with mod_rewrite
- **Extensions**: PDO, OpenSSL, cURL, mbstring, JSON
- **Memory**: 256MB minimum
- **Storage**: 1GB minimum

## 🛠️ Installation Instructions

### Step 1: Download and Extract

1. Download the complete package
2. Extract to your web server directory
3. Ensure proper file permissions (755 for directories, 644 for files)

### Step 2: Run Installation Script

1. Navigate to your domain in a web browser
2. You'll be automatically redirected to the installation page
3. Or manually visit: `http://yourdomain.com/install.php`

### Step 3: Complete Installation Wizard

The installation wizard will guide you through:

1. **System Requirements Check**
2. **Database Configuration** (starlink_router_rent)
3. **Admin Account Setup**
4. **Site Configuration**
5. **Payment Gateway Setup** (including Plisio.net)
6. **Telegram Integration**

### Step 4: Frontend Setup

1. Navigate to the project directory
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env`
4. Configure your Supabase credentials in `.env`
5. Start development server: `npm run dev`

### Step 5: Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key
3. Update `.env` file with your Supabase credentials
4. Run the database migrations in Supabase dashboard

### Step 6: Configure Plisio.net

1. Register at [plisio.net](https://plisio.net)
2. Get your API key from the dashboard
3. Configure in admin panel at `/admin/settings`
4. Set webhook URL: `https://yourdomain.com/api/plisio/webhook.php`

### Step 7: Post-Installation

1. Delete `install.php` for security
2. Set up cron jobs for automated tasks
3. Test cryptocurrency payments
4. Customize site settings

## 🔧 Configuration

### Database Configuration

The system uses the database name `starlink_router_rent` by default. This can be changed during installation.

### Frontend Configuration

#### Environment Variables (.env)
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_API_URL=http://localhost:3000/api
VITE_APP_URL=http://localhost:5173
VITE_TELEGRAM_BOT_TOKEN=your_telegram_bot_token
VITE_PLISIO_API_KEY=your_plisio_api_key
VITE_APP_NAME="Starlink Router Rent"
```

### Plisio.net Setup

#### 1. Create Plisio Account
- Visit [plisio.net](https://plisio.net)
- Register for a free account
- Verify your email address

#### 2. Get API Credentials
- Login to Plisio dashboard
- Navigate to "API" section
- Copy your API key

#### 3. Configure Webhook
- In Plisio dashboard, go to "Webhooks"
- Add webhook URL: `https://yourdomain.com/api/plisio/webhook.php`
- Select all events for notifications

#### 4. Admin Configuration
- Login to admin panel: `/admin`
- Go to Settings
- Enter Plisio API key
- Save configuration

## 🔄 Automated Tasks

Set up cron jobs for:

```bash
# Daily earnings processing
0 0 * * * php /path/to/your/site/cron/process_daily_earnings.php

# Payment status updates (every 5 minutes)
*/5 * * * * php /path/to/your/site/cron/update_payment_status.php

# Send daily email notifications
0 8 * * * php /path/to/your/site/cron/send_daily_emails.php
```

## 🔐 Security Features

- **Supabase Authentication**: Secure user verification
- **Webhook Verification**: HMAC signature validation
- **SQL Injection Prevention**: Prepared statements
- **XSS Protection**: Input sanitization
- **Secure API Communication**: HTTPS only
- **Payment Validation**: Double verification system

## 📊 Admin Panel Features

Access at `/admin` with features:

- **User Management**: Account and balance management
- **Payment Monitoring**: Real-time crypto payment tracking
- **Plisio Integration**: API status and configuration
- **Transaction Logs**: Complete payment audit trail
- **System Settings**: Payment gateway configuration
- **Email Settings**: SMTP configuration and templates

## 🎨 Frontend Features

### Modern React Application

1. **TypeScript Support**: Full type safety
2. **Supabase Integration**: Real-time database operations
3. **Responsive Design**: Mobile-first approach
4. **State Management**: Zustand for global state
5. **Routing**: React Router for navigation

### User Experience

1. **Dashboard**: Real-time stats and analytics
2. **Router Rental**: Browse and rent available routers
3. **Investment Plans**: Multiple investment options
4. **Referral System**: Track and manage referrals
5. **Payment Integration**: Seamless crypto payments

## 🔍 Troubleshooting

### Common Installation Issues

#### Database Connection Problems
- Verify database credentials
- Ensure MySQL service is running
- Check database name: `starlink_router_rent`

#### Frontend Issues
- Ensure Node.js 18+ is installed
- Run `npm install` to install dependencies
- Check Supabase configuration in `.env`

#### Plisio Integration Problems
- Verify API key is correct
- Check server has cURL enabled
- Ensure HTTPS is configured

### Log Files

Check these locations for errors:
- `logs/error.log` - General errors
- `logs/payment.log` - Payment processing
- `logs/plisio.log` - Plisio API calls
- Browser console - Frontend errors

## 📈 Performance Optimization

### Database Optimization
- **Proper Indexing**: Optimized queries for fast performance
- **Connection Pooling**: Efficient database connections
- **Query Optimization**: Minimal database calls

### Frontend Optimization
- **Code Splitting**: Lazy loading for better performance
- **Asset Optimization**: Compressed images and assets
- **Caching**: Browser and API response caching

## 🆘 Support

### Platform Support
- **Email**: support@starlinkrouterrent.com
- **GitHub Issues**: Bug reports and features

### Integration Support
- **Plisio Documentation**: [Plisio API Docs](https://plisio.net/documentation)
- **Supabase Documentation**: [Supabase Docs](https://supabase.com/docs)

## 🎉 Getting Started

1. **Install** the system using the web installer
2. **Configure** Supabase credentials
3. **Configure** Plisio.net API credentials
4. **Test** cryptocurrency payments
5. **Add** routers to inventory
6. **Launch** your platform!

Your users can now:
- **Rent** premium Starlink routers
- **Deposit** funds using 8+ cryptocurrencies
- **Earn** daily profits from rentals
- **Invest** in plans for guaranteed returns
- **Build** referral networks for passive income
- **Withdraw** earnings to crypto wallets

---

## 💡 Advanced Features

### Cryptocurrency Support
- Add new currencies via admin panel
- Configure custom exchange rates
- Set minimum/maximum amounts per currency

### Multi-Language Support
- Cryptocurrency names in multiple languages
- Localized payment interfaces
- Regional payment preferences

### Analytics & Reporting
- User behavior analytics
- Cryptocurrency payment analytics
- Revenue tracking by payment method
- Performance insights

---

**Ready to launch your router rental platform with cryptocurrency payments? Start with Starlink Router Rent today!**