import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  final _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchShoppingList();
  }

  Future<void> _fetchShoppingList() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/shopping-lists');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> parsed = [];
        if (data is List) {
          parsed = data;
        } else if (data is Map) {
          parsed = data['items'] ?? data['shoppingLists'] ?? data['data'] ?? [];
        }
        setState(() => _items = parsed);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addItem() async {
    if (_itemController.text.trim().isEmpty) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/shopping-lists', data: {
        'name': _itemController.text.trim(),
        'quantity': 1,
      });
      _itemController.clear();
      _fetchShoppingList();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Mua sắm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      hintText: 'Thêm món cần mua...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(50, 56)),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('Danh sách mua sắm trống'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final name = item['name'] ?? '';
                          final completed = item['completed'] ?? false;

                          return CheckboxListTile(
                            title: Text(
                              name,
                              style: TextStyle(
                                decoration: completed ? TextDecoration.lineThrough : null,
                                color: completed ? Colors.grey : Colors.black87,
                              ),
                            ),
                            value: completed,
                            activeColor: primaryColor,
                            onChanged: (val) {
                              setState(() {
                                _items[index]['completed'] = val ?? false;
                              });
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
