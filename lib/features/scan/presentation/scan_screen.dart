import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      setState(() => _isUploading = true);

      // Simulate or upload to /ai/scan-jobs or /ai/scan-receipt
      // Mock result preview for demonstration or actual multipart POST
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to review screen with mock or parsed scan items
      final mockScanResult = {
        'items': [
          {'name': 'Sữa tươi', 'quantity': 2, 'unit': 'hộp', 'selected': false},
          {'name': 'Trứng gà', 'quantity': 10, 'unit': 'quả', 'selected': false},
        ]
      };

      if (!mounted) return;
      context.push('/scan-review', extra: mockScanResult);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi quét ảnh: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A44);
    return Scaffold(
      appBar: AppBar(title: const Text('Quét Thực Phẩm & Hóa Đơn')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.document_scanner_outlined, size: 100, color: primaryColor),
            const SizedBox(height: 24),
            const Text(
              'Chụp ảnh hoặc chọn ảnh hóa đơn / thực phẩm để AI nhận diện',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: () => _pickAndUpload(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh camera'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pickAndUpload(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn từ thư viện'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
