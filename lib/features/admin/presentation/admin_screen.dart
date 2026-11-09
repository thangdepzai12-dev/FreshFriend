import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminStats();
  }

  Future<void> _fetchAdminStats() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/admin/stats');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _stats = response.data;
        });
      }
    } catch (e) {
      setState(() {
        _isUnauthorized = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị hệ thống (Admin)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isUnauthorized
              ? const Center(
                  child: Text(
                    'Bạn không có quyền truy cập chức năng này (Yêu cầu quyền ADMIN)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thống kê hệ thống',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Tổng số người dùng'),
                                trailing: Text('${_stats?['usersCount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              const Divider(),
                              ListTile(
                                title: const Text('Tổng số thực phẩm trong kho'),
                                trailing: Text('${_stats?['foodsCount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
