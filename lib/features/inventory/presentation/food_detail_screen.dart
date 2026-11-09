import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final String foodId;
  const FoodDetailScreen({super.key, required this.foodId});

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  Map<String, dynamic>? _food;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoodDetail();
  }

  Future<void> _fetchFoodDetail() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/foods/${widget.foodId}');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _food = response.data is Map ? response.data : response.data['food'];
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Không rõ';
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      if (isoDate.contains('T')) {
        return isoDate.split('T')[0];
      }
      return isoDate;
    }
  }

  Future<void> _deleteFood() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/foods/${widget.foodId}');
      if (!mounted) return;
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa thực phẩm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    
    final name = _food?['foodName'] ?? _food?['name'] ?? 'Không tên';
    final quantity = _food?['quantity'] ?? 1;
    final unit = _food?['unit'] ?? '';
    
    final locationObj = _food?['storageLocationId'];
    final locationName = locationObj is Map 
        ? (locationObj['storageName'] ?? locationObj['name'] ?? 'Mặc định') 
        : 'Mặc định';

    final categoryObj = _food?['categoryId'];
    final categoryName = categoryObj is Map 
        ? (categoryObj['displayName'] ?? categoryObj['categoryName'] ?? 'Chung') 
        : 'Chung';

    final purchaseDate = _formatDate(_food?['purchaseDate']);
    final expiryDate = _formatDate(_food?['expiryDate'] ?? _food?['expiresAt']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thực phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/add-edit-food', extra: widget.foodId),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteFood,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _food == null
              ? const Center(child: Text('Không tìm thấy thông tin thực phẩm'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.fastfood, size: 40, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Số lượng', '$quantity $unit'),
                      _buildInfoRow('Danh mục', categoryName),
                      _buildInfoRow('Vị trí lưu trữ', locationName),
                      _buildInfoRow('Ngày mua', purchaseDate),
                      _buildInfoRow('Ngày hết hạn', expiryDate),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã đánh dấu đã sử dụng thực phẩm')),
                          );
                          context.pop();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Đã sử dụng'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
