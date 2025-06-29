<?php
require_once '../includes/database.php';
require_once '../includes/auth.php';

$auth = new Auth();
$db = Database::getInstance();

// Handle admin login
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$auth->isAdmin()) {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if ($auth->adminLogin($username, $password)) {
        header('Location: /admin');
        exit;
    } else {
        $loginError = 'Invalid username or password';
    }
}

// Redirect to login if not admin
if (!$auth->isAdmin()) {
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Login - Starlink Rent</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.js"></script>
    </head>
    <body class="bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 min-h-screen flex items-center justify-center">
        <div class="max-w-md w-full mx-4">
            <div class="bg-slate-800/50 p-8 rounded-2xl border border-blue-500/10 backdrop-blur-sm">
                <div class="text-center mb-8">
                    <div class="bg-gradient-to-r from-blue-500 to-cyan-400 p-3 rounded-lg w-fit mx-auto mb-4">
                        <i data-lucide="shield" class="h-8 w-8 text-white"></i>
                    </div>
                    <h2 class="text-3xl font-bold text-white">Admin Login</h2>
                    <p class="text-gray-300 mt-2">Access the admin dashboard</p>
                </div>

                <?php if (isset($loginError)): ?>
                    <div class="bg-red-500/10 border border-red-500/20 text-red-400 p-4 rounded-lg mb-6">
                        <?php echo htmlspecialchars($loginError); ?>
                    </div>
                <?php endif; ?>

                <form method="POST" class="space-y-6">
                    <div>
                        <label class="block text-gray-300 mb-2">Username</label>
                        <input type="text" name="username" required
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="Enter admin username">
                    </div>

                    <div>
                        <label class="block text-gray-300 mb-2">Password</label>
                        <input type="password" name="password" required
                               class="w-full bg-slate-700 text-white p-3 rounded-lg border border-gray-600 focus:border-blue-500 focus:outline-none"
                               placeholder="Enter admin password">
                    </div>

                    <button type="submit" class="w-full bg-gradient-to-r from-blue-500 to-cyan-400 text-white py-3 rounded-lg font-semibold hover:from-blue-600 hover:to-cyan-500 transition-all">
                        Login to Admin Panel
                    </button>
                </form>

                <div class="mt-6 text-center">
                    <a href="/" class="text-cyan-400 hover:text-cyan-300 text-sm">
                        ← Back to Website
                    </a>
                </div>
            </div>
        </div>

        <script>
            lucide.createIcons();
        </script>
    </body>
    </html>
    <?php
    exit;
}

// Get admin dashboard data
$stats = [
    'total_users' => $db->fetch("SELECT COUNT(*) as count FROM users")['count'],
    'active_devices' => $db->fetch("SELECT COUNT(*) as count FROM devices WHERE status = 'available'")['count'],
    'total_investments' => $db->fetch("SELECT COALESCE(SUM(investment_amount), 0) as total FROM investments WHERE status = 'active'")['total'],
    'pending_withdrawals' => $db->fetch("SELECT COUNT(*) as count FROM withdrawal_requests WHERE status = 'pending'")['count']
];

$recentUsers = $db->fetchAll("SELECT username, email, created_at FROM users ORDER BY created_at DESC LIMIT 5");
$recentWithdrawals = $db->fetchAll("
    SELECT wr.*, u.username 
    FROM withdrawal_requests wr 
    JOIN users u ON wr.user_id = u.id 
    WHERE wr.status = 'pending' 
    ORDER BY wr.requested_at DESC 
    LIMIT 5
");

// Handle quick actions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    $action = $_POST['action'];
    $id = intval($_POST['id'] ?? 0);
    
    switch ($action) {
        case 'approve_withdrawal':
            $db->update('withdrawal_requests', ['status' => 'approved'], 'id = ?', [$id]);
            break;
        case 'reject_withdrawal':
            $db->update('withdrawal_requests', ['status' => 'rejected'], 'id = ?', [$id]);
            break;
    }
    
    header('Location: /admin');
    exit;
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Starlink Rent</title>
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
                    <div class="bg-gradient-to-r from-blue-500 to-cyan-400 p-2 rounded-lg">
                        <i data-lucide="shield" class="h-6 w-6 text-white"></i>
                    </div>
                    <span class="text-xl font-bold text-white">Admin Dashboard</span>
                </div>

                <div class="flex items-center space-x-4">
                    <span class="text-gray-300">Welcome, <?php echo htmlspecialchars($_SESSION['admin_username']); ?></span>
                    <a href="/" class="text-cyan-400 hover:text-cyan-300">View Site</a>
                    <a href="/admin/logout" class="text-red-400 hover:text-red-300">Logout</a>
                </div>
            </div>
        </div>
    </header>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Total Users</p>
                        <p class="text-2xl font-bold text-white mt-1"><?php echo number_format($stats['total_users']); ?></p>
                    </div>
                    <div class="bg-gradient-to-r from-blue-500 to-cyan-400 p-3 rounded-lg">
                        <i data-lucide="users" class="h-6 w-6 text-white"></i>
                    </div>
                </div>
            </div>

            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Active Devices</p>
                        <p class="text-2xl font-bold text-white mt-1"><?php echo number_format($stats['active_devices']); ?></p>
                    </div>
                    <div class="bg-gradient-to-r from-green-500 to-blue-500 p-3 rounded-lg">
                        <i data-lucide="satellite" class="h-6 w-6 text-white"></i>
                    </div>
                </div>
            </div>

            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Total Investments</p>
                        <p class="text-2xl font-bold text-white mt-1">$<?php echo number_format($stats['total_investments'], 2); ?></p>
                    </div>
                    <div class="bg-gradient-to-r from-purple-500 to-pink-500 p-3 rounded-lg">
                        <i data-lucide="trending-up" class="h-6 w-6 text-white"></i>
                    </div>
                </div>
            </div>

            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Pending Withdrawals</p>
                        <p class="text-2xl font-bold text-white mt-1"><?php echo number_format($stats['pending_withdrawals']); ?></p>
                    </div>
                    <div class="bg-gradient-to-r from-orange-500 to-red-500 p-3 rounded-lg">
                        <i data-lucide="dollar-sign" class="h-6 w-6 text-white"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid lg:grid-cols-2 gap-8">
            <!-- Recent Users -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">Recent Users</h3>
                <div class="space-y-3">
                    <?php foreach ($recentUsers as $user): ?>
                        <div class="flex items-center justify-between p-3 bg-slate-700/30 rounded">
                            <div>
                                <p class="text-white font-medium"><?php echo htmlspecialchars($user['username']); ?></p>
                                <p class="text-gray-400 text-sm"><?php echo htmlspecialchars($user['email']); ?></p>
                            </div>
                            <span class="text-gray-400 text-sm"><?php echo date('M j', strtotime($user['created_at'])); ?></span>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>

            <!-- Pending Withdrawals -->
            <div class="bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
                <h3 class="text-xl font-semibold text-white mb-4">Pending Withdrawals</h3>
                <div class="space-y-3">
                    <?php foreach ($recentWithdrawals as $withdrawal): ?>
                        <div class="p-3 bg-slate-700/30 rounded">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-white font-medium"><?php echo htmlspecialchars($withdrawal['username']); ?></span>
                                <span class="text-green-400 font-semibold">$<?php echo number_format($withdrawal['amount'], 2); ?></span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-gray-400 text-sm"><?php echo ucfirst($withdrawal['withdrawal_method']); ?></span>
                                <div class="flex space-x-2">
                                    <form method="POST" class="inline">
                                        <input type="hidden" name="action" value="approve_withdrawal">
                                        <input type="hidden" name="id" value="<?php echo $withdrawal['id']; ?>">
                                        <button type="submit" class="bg-green-500 hover:bg-green-600 text-white px-2 py-1 rounded text-xs">
                                            Approve
                                        </button>
                                    </form>
                                    <form method="POST" class="inline">
                                        <input type="hidden" name="action" value="reject_withdrawal">
                                        <input type="hidden" name="id" value="<?php echo $withdrawal['id']; ?>">
                                        <button type="submit" class="bg-red-500 hover:bg-red-600 text-white px-2 py-1 rounded text-xs">
                                            Reject
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="mt-8 bg-slate-800/50 p-6 rounded-xl border border-blue-500/10">
            <h3 class="text-xl font-semibold text-white mb-4">Quick Actions</h3>
            <div class="grid md:grid-cols-4 gap-4">
                <a href="/admin/users" class="bg-blue-500 hover:bg-blue-600 text-white p-4 rounded-lg text-center transition-all">
                    <i data-lucide="users" class="h-6 w-6 mx-auto mb-2"></i>
                    <div class="font-medium">Manage Users</div>
                </a>
                <a href="/admin/devices" class="bg-green-500 hover:bg-green-600 text-white p-4 rounded-lg text-center transition-all">
                    <i data-lucide="satellite" class="h-6 w-6 mx-auto mb-2"></i>
                    <div class="font-medium">Manage Devices</div>
                </a>
                <a href="/admin/investments" class="bg-purple-500 hover:bg-purple-600 text-white p-4 rounded-lg text-center transition-all">
                    <i data-lucide="trending-up" class="h-6 w-6 mx-auto mb-2"></i>
                    <div class="font-medium">Investments</div>
                </a>
                <a href="/admin/settings" class="bg-orange-500 hover:bg-orange-600 text-white p-4 rounded-lg text-center transition-all">
                    <i data-lucide="settings" class="h-6 w-6 mx-auto mb-2"></i>
                    <div class="font-medium">Settings</div>
                </a>
            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>