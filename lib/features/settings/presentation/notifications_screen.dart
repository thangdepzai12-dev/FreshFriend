import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/notifications');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> parsed = [];
        if (data is List) {
          parsed = data;
        } else if (data is Map) {
          parsed = data['notifications'] ?? data['data'] ?? [];
        }
        setState(() => _notifications = parsed);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Không có thông báo mới'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.notifications, color: primaryColor),
                        title: Text(n['title'] ?? 'Thông báo', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(n['message'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
