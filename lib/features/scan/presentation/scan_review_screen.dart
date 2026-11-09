import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScanReviewScreen extends ConsumerStatefulWidget {
  final dynamic scanResult;
  const ScanReviewScreen({super.key, required this.scanResult});

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.scanResult is Map && widget.scanResult['items'] is List) {
      _items = List.from(widget.scanResult['items']);
    }
  }

  void _saveSelected() {
    // Save selected items to inventory
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu các món được chọn vào kho thành công!')),
    );
    context.go('/inventory');
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Rà soát kết quả quét')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Vui lòng kiểm tra và chọn các món bạn muốn lưu vào kho. Kết quả không tự động lưu.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final name = item['name'] ?? '';
                final qty = item['quantity'] ?? 1;
                final unit = item['unit'] ?? '';
                final selected = item['selected'] ?? false;

                return CheckboxListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Số lượng: $qty $unit'),
                  value: selected,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _items[index]['selected'] = val ?? false;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _items.any((i) => i['selected'] == true) ? _saveSelected : null,
              child: const Text('Lưu các món đã chọn'),
            ),
          ),
        ],
      ),
    );
  }
}
