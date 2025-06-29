<?php
require_once '../includes/database.php';
require_once '../includes/auth.php';

$auth = new Auth();
$auth->requireAdmin();

$db = Database::getInstance();
$error = '';
$success = '';

// Handle settings update
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $emailSettings = [
            'smtp_host' => $_POST['smtp_host'] ?? '',
            'smtp_port' => $_POST['smtp_port'] ?? '587',
            'smtp_username' => $_POST['smtp_username'] ?? '',
            'smtp_password' => $_POST['smtp_password'] ?? '',
            'smtp_secure' => $_POST['smtp_secure'] ?? 'tls',
            'email_from' => $_POST['email_from'] ?? '',
            'email_from_name' => $_POST['email_from_name'] ?? 'Starlink Rent',
            'email_notifications_enabled' => isset($_POST['email_notifications_enabled']) ? '1' : '0',
            'welcome_email_enabled' => isset($_POST['welcome_email_enabled']) ? '1' : '0',
            'deposit_email_enabled' => isset($_POST['deposit_email_enabled']) ? '1' : '0',
            'withdrawal_email_enabled' => isset($_POST['withdrawal_email_enabled']) ? '1' : '0',
            'daily_earnings_email_enabled' => isset($_POST['daily_earnings_email_enabled']) ? '1' : '0',
            'referral_email_enabled' => isset($_POST['referral_email_enabled']) ? '1' : '0'
        ];
        
        foreach ($emailSettings as $key => $value) {
            $existing = $db->fetch("SELECT id FROM system_settings WHERE setting_key = ?", [$key]);
            
            if ($existing) {
                $db->update('system_settings', 
                    ['setting_value' => $value, 'updated_at' => date('Y-m-d H:i:s')], 
                    'setting_key = ?', 
                    [$key]
                );
            } else {
                $db->insert('system_settings', [
                    'setting_key' => $key,
                    'setting_value' => $value,
                    'setting_type' => 'string',
                    'category' => 'email',
                    'created_at' => date('Y-m-d H:i:s'),
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
            }
        }
        
        $success = 'Email settings updated successfully!';
        
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Test email functionality
if (isset($_POST['test_email'])) {
    try {
        require_once '../includes/email.php';
        $emailService = new EmailService();
        
        $testEmail = $_POST['test_email_address'] ?? '';
        if (empty($testEmail)) {
            throw new Exception('Please enter a test email address');
        }
        
        $subject = 'Test Email from Starlink Rent';
        $body = '
        <h2>Email Test Successful!</h2>
        <p>This is a test email to verify your SMTP configuration is working correctly.</p>
        <p><strong>Sent at:</strong> ' . date('Y-m-d H:i:s') . '</p>
        <p>If you received this email, your email settings are configured properly.</p>
        ';
        
        if ($emailService->sendEmail($testEmail, $subject, $body)) {
            $success = 'Test email sent successfully to ' . $testEmail;
        } else {
            $error = 'Failed to send test email. Please check your SMTP settings.';
        }
        
    } catch (Exception $e) {
        $error = 'Test email failed: ' . $e->getMessage();
    }
}

// Get current settings
$currentSettings = [];
$settings = $db->fetchAll("SELECT setting_key, setting_value FROM system_settings WHERE setting_key LIKE 'smtp_%' OR setting_key LIKE 'email_%'");
foreach ($settings as $setting) {
    $currentSettings[$setting['setting_key']] = $setting['setting_value'];
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Settings - Starlink Rent Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.js"></script>
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
        }
    </style>
</head>
<body class="bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 text-white min-h-screen">
    <!-- Header -->
    <header class="bg-slate-900/95 backdrop-blur-sm border-b border-blue-500/20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-16">
                <div class="flex items-center space-x-3">
                    <a href="/admin" class="flex items-center space-x-3">
                        <div class="bg-gradient-to-r from-blue-500 to-cyan-400 p-2 rounded-lg">
                            <i data-lucide="mail" class="h-6 w-6 text-white"></i>
                        </div>
                        <span class="text-xl font-bold text-white">Email Settings</span>
                    </a>
                </div>

                <div class="flex items-center space-x-4">
                    <a href="/admin/settings" class="text-cyan-400 hover:text-cyan-300">← Back to Settings</a>
                    <a href="/admin" class="text-cyan-400 hover:text-cyan-300">Dashboard</a>
                </div>
            </div>
        </div>
    </header>

    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <?php if ($error): ?>
            <div class="bg-red-500/10 border border-red-500/20 text-red-400 p-4 rounded-lg mb-6">
                <?php echo htmlspecialchars($error); ?>
            </div>
        <?php endif; ?>

        <?php if ($success): ?>
            <div class="bg-green-500/10 border border-green-500/20 text-green-400 p-4 rounded-lg mb-6">
                <?php echo htmlspecialchars($success); ?>
            </div>
        <?php endif; ?>

        <form method="POST" class="space-y-8">
            <!-- SMTP Configuration -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="server" class="h-5 w-5 inline mr-2 text-blue-400"></i>
                    SMTP Configuration
                </h3>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-gray-300 mb-2">SMTP Host</label>
                        <input type="text" name="smtp_host" value="<?php echo htmlspecialchars($currentSettings['smtp_host'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="smtp.gmail.com">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">SMTP Port</label>
                        <input type="number" name="smtp_port" value="<?php echo htmlspecialchars($currentSettings['smtp_port'] ?? '587'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">SMTP Username</label>
                        <input type="text" name="smtp_username" value="<?php echo htmlspecialchars($currentSettings['smtp_username'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="your-email@gmail.com">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">SMTP Password</label>
                        <input type="password" name="smtp_password" value="<?php echo htmlspecialchars($currentSettings['smtp_password'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="App password or SMTP password">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Security</label>
                        <select name="smtp_secure" class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                            <option value="tls" <?php echo ($currentSettings['smtp_secure'] ?? 'tls') === 'tls' ? 'selected' : ''; ?>>TLS</option>
                            <option value="ssl" <?php echo ($currentSettings['smtp_secure'] ?? '') === 'ssl' ? 'selected' : ''; ?>>SSL</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Email From Settings -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="send" class="h-5 w-5 inline mr-2 text-green-400"></i>
                    Sender Information
                </h3>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-gray-300 mb-2">From Email</label>
                        <input type="email" name="email_from" value="<?php echo htmlspecialchars($currentSettings['email_from'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="noreply@starlink-rent.com">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">From Name</label>
                        <input type="text" name="email_from_name" value="<?php echo htmlspecialchars($currentSettings['email_from_name'] ?? 'Starlink Rent'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                </div>
            </div>

            <!-- Email Notifications -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="bell" class="h-5 w-5 inline mr-2 text-yellow-400"></i>
                    Email Notifications
                </h3>
                <div class="space-y-4">
                    <label class="flex items-center">
                        <input type="checkbox" name="email_notifications_enabled" 
                               <?php echo ($currentSettings['email_notifications_enabled'] ?? '1') === '1' ? 'checked' : ''; ?>
                               class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                        <span class="text-white">Enable Email Notifications</span>
                    </label>
                    
                    <div class="grid md:grid-cols-2 gap-4 ml-6">
                        <label class="flex items-center">
                            <input type="checkbox" name="welcome_email_enabled" 
                                   <?php echo ($currentSettings['welcome_email_enabled'] ?? '1') === '1' ? 'checked' : ''; ?>
                                   class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                            <span class="text-gray-300">Welcome Emails</span>
                        </label>
                        
                        <label class="flex items-center">
                            <input type="checkbox" name="deposit_email_enabled" 
                                   <?php echo ($currentSettings['deposit_email_enabled'] ?? '1') === '1' ? 'checked' : ''; ?>
                                   class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                            <span class="text-gray-300">Deposit Confirmations</span>
                        </label>
                        
                        <label class="flex items-center">
                            <input type="checkbox" name="withdrawal_email_enabled" 
                                   <?php echo ($currentSettings['withdrawal_email_enabled'] ?? '1') === '1' ? 'checked' : ''; ?>
                                   class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                            <span class="text-gray-300">Withdrawal Notifications</span>
                        </label>
                        
                        <label class="flex items-center">
                            <input type="checkbox" name="daily_earnings_email_enabled" 
                                   <?php echo ($currentSettings['daily_earnings_email_enabled'] ?? '0') === '1' ? 'checked' : ''; ?>
                                   class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                            <span class="text-gray-300">Daily Earnings Reports</span>
                        </label>
                        
                        <label class="flex items-center">
                            <input type="checkbox" name="referral_email_enabled" 
                                   <?php echo ($currentSettings['referral_email_enabled'] ?? '1') === '1' ? 'checked' : ''; ?>
                                   class="mr-3 rounded border-gray-600 bg-slate-700 text-blue-500 focus:ring-blue-500">
                            <span class="text-gray-300">Referral Bonuses</span>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Test Email -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-orange-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="test-tube" class="h-5 w-5 inline mr-2 text-orange-400"></i>
                    Test Email Configuration
                </h3>
                <div class="flex gap-4">
                    <input type="email" name="test_email_address" 
                           class="flex-1 bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                           placeholder="Enter email address to test">
                    <button type="submit" name="test_email" value="1"
                            class="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg font-semibold transition-all">
                        Send Test Email
                    </button>
                </div>
                <p class="text-gray-400 text-sm mt-2">Send a test email to verify your SMTP configuration is working correctly.</p>
            </div>

            <button type="submit" class="w-full bg-gradient-to-r from-blue-500 to-cyan-400 text-white py-3 rounded-lg font-semibold hover:from-blue-600 hover:to-cyan-500 transition-all">
                Save Email Settings
            </button>
        </form>

        <!-- Email Templates Info -->
        <div class="mt-8 bg-slate-800/30 p-6 rounded-xl">
            <h3 class="text-xl font-semibold text-white mb-4">📧 Available Email Templates</h3>
            <div class="grid md:grid-cols-2 gap-4">
                <div class="bg-slate-700/30 p-4 rounded-lg">
                    <h4 class="text-cyan-400 font-semibold mb-2">User Notifications</h4>
                    <ul class="text-gray-300 text-sm space-y-1">
                        <li>• Welcome Email</li>
                        <li>• Deposit Confirmation</li>
                        <li>• Withdrawal Notification</li>
                        <li>• Investment Confirmation</li>
                    </ul>
                </div>
                <div class="bg-slate-700/30 p-4 rounded-lg">
                    <h4 class="text-cyan-400 font-semibold mb-2">Earnings & Referrals</h4>
                    <ul class="text-gray-300 text-sm space-y-1">
                        <li>• Daily Earnings Report</li>
                        <li>• Referral Bonus</li>
                        <li>• Rental Activation</li>
                        <li>• Custom Notifications</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>