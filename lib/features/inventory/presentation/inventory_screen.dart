import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  List<dynamic> _foods = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, fresh, expiring, expired
  String _searchQuery = '';
  String _ownerType = 'personal'; // personal or household

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/foods',
        queryParameters: {'ownerType': _ownerType},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> parsedList = [];
        if (data is List) {
          parsedList = data;
        } else if (data is Map) {
          if (data['foods'] is List) {
            parsedList = data['foods'];
          } else if (data['data'] is List) {
            parsedList = data['data'];
          } else if (data['result'] is List) {
            parsedList = data['result'];
          }
        }
        setState(() => _foods = parsedList);
      }
    } on DioException catch (e) {
      String msg = 'Không thể tải dữ liệu kho.';
      if (e.response?.statusCode == 403) {
        msg = 'Lỗi 403 (Forbidden): Tài khoản chưa tham gia hộ gia đình hoặc chưa chọn đúng kho.';
      } else if (e.response?.statusCode == 401) {
        msg = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      } else if (e.message != null) {
        msg = 'Lỗi kết nối: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
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

  List<dynamic> get _filteredFoods {
    return _foods.where((food) {
      final name = (food['foodName'] ?? food['name'] ?? '').toString().toLowerCase();
      if (_searchQuery.isNotEmpty && !name.contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho Thực Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            onPressed: () => context.push('/household'),
            tooltip: 'Hộ gia đình',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Thông báo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Owner Type Selector (Personal vs Household) & Search & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Kho cá nhân')),
                        selected: _ownerType == 'personal',
                        selectedColor: primaryColor.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _ownerType == 'personal' ? primaryColor : Colors.black87,
                          fontWeight: _ownerType == 'personal' ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _ownerType = 'personal');
                            _fetchFoods();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Kho hộ gia đình')),
                        selected: _ownerType == 'household',
                        selectedColor: primaryColor.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: _ownerType == 'household' ? primaryColor : Colors.black87,
                          fontWeight: _ownerType == 'household' ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _ownerType = 'household');
                            _fetchFoods();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm thực phẩm...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Còn tốt', 'fresh'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sắp hết hạn', 'expiring'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã hết hạn', 'expired'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Food List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFoods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.kitchen, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(_ownerType == 'personal'
                                ? 'Kho cá nhân chưa có thực phẩm nào'
                                : 'Kho hộ gia đình chưa có thực phẩm nào'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/add-edit-food'),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm thực phẩm'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchFoods,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredFoods.length,
                          itemBuilder: (context, index) {
                            final food = _filteredFoods[index];
                            final name = food['foodName'] ?? food['name'] ?? 'Không tên';
                            final quantity = food['quantity'] ?? 1;
                            final unit = food['unit'] ?? '';
                            final expiryDate = food['expiryDate'] ?? food['expiresAt'] ?? '';
                            
                            final locationObj = food['storageLocationId'];
                            final locationName = locationObj is Map 
                                ? (locationObj['storageName'] ?? locationObj['name'] ?? '') 
                                : '';

                            final subtitleText = locationName.isNotEmpty
                                ? 'Số lượng: $quantity $unit • Vị trí: $locationName\nHạn: ${_formatDate(expiryDate)}'
                                : 'Số lượng: $quantity $unit\nHạn: ${_formatDate(expiryDate)}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF86F8BE),
                                  child: Icon(Icons.fastfood, color: primaryColor),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(subtitleText),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    final id = food['id'] ?? food['_id'] ?? '';
                                    context.push('/food-detail', extra: id.toString());
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-edit-food'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    const primaryColor = Color(0xFF006A44);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
    );
  }
}
