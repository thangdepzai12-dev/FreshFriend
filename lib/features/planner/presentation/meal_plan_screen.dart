import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMealPlans();
  }

  Future<void> _fetchMealPlans() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/meal-plans');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> parsed = [];
        if (data is List) {
          parsed = data;
        } else if (data is Map) {
          parsed = data['plans'] ?? data['mealPlans'] ?? data['data'] ?? [];
        }
        setState(() => _plans = parsed);
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
      appBar: AppBar(title: const Text('Kế hoạch Bữa ăn')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Chưa có kế hoạch bữa ăn nào cho tuần này'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Generate AI meal plan
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Tạo kế hoạch tự động (AI)'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.restaurant, color: primaryColor),
                        title: Text(plan['title'] ?? 'Bữa ăn', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Ngày: ${plan['date'] ?? ''}'),
                      ),
                    );
                  },
                ),
    );
  }
}
