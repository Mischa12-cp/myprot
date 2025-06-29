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
        $settings = [
            'plisio_api_key' => $_POST['plisio_api_key'] ?? '',
            'plisio_webhook_url' => $_POST['plisio_webhook_url'] ?? '',
            'binance_api_key' => $_POST['binance_api_key'] ?? '',
            'binance_secret' => $_POST['binance_secret'] ?? '',
            'site_name' => $_POST['site_name'] ?? 'GainsMax Test Telegram',
            'site_url' => $_POST['site_url'] ?? '',
            'admin_email' => $_POST['admin_email'] ?? '',
            'telegram_bot_token' => $_POST['telegram_bot_token'] ?? '',
            'min_deposit' => $_POST['min_deposit'] ?? '50',
            'max_deposit' => $_POST['max_deposit'] ?? '10000',
            'min_withdrawal' => $_POST['min_withdrawal'] ?? '20',
            'withdrawal_fee' => $_POST['withdrawal_fee'] ?? '2.0'
        ];
        
        foreach ($settings as $key => $value) {
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
                    'category' => 'general',
                    'created_at' => date('Y-m-d H:i:s'),
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
            }
        }
        
        $success = 'Settings updated successfully!';
        
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Get current settings
$currentSettings = [];
$settings = $db->fetchAll("SELECT setting_key, setting_value FROM system_settings");
foreach ($settings as $setting) {
    $currentSettings[$setting['setting_key']] = $setting['setting_value'];
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Settings - GainsMax Test Telegram</title>
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
                            <i data-lucide="settings" class="h-6 w-6 text-white"></i>
                        </div>
                        <span class="text-xl font-bold text-white">GainsMax Settings</span>
                    </a>
                </div>

                <div class="flex items-center space-x-4">
                    <a href="/admin" class="text-cyan-400 hover:text-cyan-300">← Back to Dashboard</a>
                    <a href="/admin/logout" class="text-red-400 hover:text-red-300">Logout</a>
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
            <!-- General Settings -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">General Settings</h3>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-gray-300 mb-2">Site Name</label>
                        <input type="text" name="site_name" value="<?php echo htmlspecialchars($currentSettings['site_name'] ?? 'GainsMax Test Telegram'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Site URL</label>
                        <input type="url" name="site_url" value="<?php echo htmlspecialchars($currentSettings['site_url'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Admin Email</label>
                        <input type="email" name="admin_email" value="<?php echo htmlspecialchars($currentSettings['admin_email'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                </div>
            </div>

            <!-- Telegram Settings -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-green-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="send" class="h-5 w-5 inline mr-2 text-green-400"></i>
                    Telegram Bot Configuration
                </h3>
                <div class="space-y-4">
                    <div>
                        <label class="block text-gray-300 mb-2">Telegram Bot Token</label>
                        <input type="text" name="telegram_bot_token" value="<?php echo htmlspecialchars($currentSettings['telegram_bot_token'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="Enter your Telegram bot token">
                        <p class="text-gray-400 text-sm mt-1">Get your bot token from <a href="https://t.me/BotFather" target="_blank" class="text-green-400">@BotFather</a></p>
                    </div>
                    <div class="bg-green-500/10 border border-green-500/20 p-4 rounded-lg">
                        <h4 class="text-green-400 font-medium mb-2">📱 Telegram Mini App Setup</h4>
                        <ol class="text-gray-300 text-sm space-y-1 list-decimal list-inside">
                            <li>Create a bot with @BotFather</li>
                            <li>Use /newapp command to create Mini App</li>
                            <li>Set Web App URL to your domain</li>
                            <li>Configure bot commands and description</li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Plisio Settings -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-orange-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="bitcoin" class="h-5 w-5 inline mr-2 text-orange-400"></i>
                    Plisio.net Cryptocurrency Settings
                </h3>
                <div class="space-y-4">
                    <div>
                        <label class="block text-gray-300 mb-2">Plisio API Key</label>
                        <input type="text" name="plisio_api_key" value="<?php echo htmlspecialchars($currentSettings['plisio_api_key'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="Enter your Plisio API key">
                        <p class="text-gray-400 text-sm mt-1">Get your API key from <a href="https://plisio.net" target="_blank" class="text-orange-400">plisio.net</a></p>
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Webhook URL</label>
                        <input type="url" name="plisio_webhook_url" 
                               value="<?php echo htmlspecialchars($currentSettings['plisio_webhook_url'] ?? 'https://' . $_SERVER['HTTP_HOST'] . '/api/plisio/webhook.php'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                        <p class="text-gray-400 text-sm mt-1">Configure this URL in your Plisio dashboard</p>
                    </div>
                </div>
            </div>

            <!-- Binance Settings -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-yellow-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">
                    <i data-lucide="wallet" class="h-5 w-5 inline mr-2 text-yellow-400"></i>
                    Binance Pay Settings
                </h3>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-gray-300 mb-2">Binance API Key</label>
                        <input type="text" name="binance_api_key" value="<?php echo htmlspecialchars($currentSettings['binance_api_key'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Binance API Secret</label>
                        <input type="password" name="binance_secret" value="<?php echo htmlspecialchars($currentSettings['binance_secret'] ?? ''); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                </div>
            </div>

            <!-- Payment Limits -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">Payment Limits & Fees</h3>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-gray-300 mb-2">Minimum Deposit ($)</label>
                        <input type="number" name="min_deposit" value="<?php echo htmlspecialchars($currentSettings['min_deposit'] ?? '50'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Maximum Deposit ($)</label>
                        <input type="number" name="max_deposit" value="<?php echo htmlspecialchars($currentSettings['max_deposit'] ?? '10000'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Minimum Withdrawal ($)</label>
                        <input type="number" name="min_withdrawal" value="<?php echo htmlspecialchars($currentSettings['min_withdrawal'] ?? '20'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-gray-300 mb-2">Withdrawal Fee (%)</label>
                        <input type="number" step="0.1" name="withdrawal_fee" value="<?php echo htmlspecialchars($currentSettings['withdrawal_fee'] ?? '2.0'); ?>"
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none">
                    </div>
                </div>
            </div>

            <button type="submit" class="w-full bg-gradient-to-r from-blue-500 to-cyan-400 text-white py-3 rounded-lg font-semibold hover:from-blue-600 hover:to-cyan-500 transition-all">
                Save Settings
            </button>
        </form>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>