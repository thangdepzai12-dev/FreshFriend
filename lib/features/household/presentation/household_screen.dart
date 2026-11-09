import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class HouseholdScreen extends ConsumerStatefulWidget {
  const HouseholdScreen({super.key});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  List<dynamic> _households = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHouseholds();
  }

  Future<void> _fetchHouseholds() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/households');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> parsed = [];
        if (data is List) {
          parsed = data;
        } else if (data is Map) {
          parsed = data['households'] ?? data['data'] ?? data['result'] ?? [];
        }
        setState(() => _households = parsed);
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
      appBar: AppBar(title: const Text('Quản lý Hộ gia đình')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _households.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Bạn chưa tham gia hộ gia đình nào'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Create household dialog
                        },
                        child: const Text('Tạo hộ gia đình mới'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _households.length,
                  itemBuilder: (context, index) {
                    final h = _households[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF86F8BE),
                          child: Icon(Icons.home, color: primaryColor),
                        ),
                        title: Text(h['name'] ?? 'Hộ gia đình', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Thành viên: ${h['membersCount'] ?? 1}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Select household context
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
