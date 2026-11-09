import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/secure_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt & Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Thành viên FreshFriends', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('user@freshfriends.vn'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: primaryColor),
            ),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.home, color: primaryColor),
            title: const Text('Quản lý Hộ gia đình'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/household'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: primaryColor),
            title: const Text('Thông báo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: primaryColor),
            title: const Text('Quản trị hệ thống (Admin)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/admin'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _logout(ref, context),
          ),
        ],
      ),
    );
  }
}
