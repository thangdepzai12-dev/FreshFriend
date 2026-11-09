import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AddEditFoodScreen extends ConsumerStatefulWidget {
  final String? foodId;
  const AddEditFoodScreen({super.key, this.foodId});

  @override
  ConsumerState<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends ConsumerState<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'cái');
  final _expiryController = TextEditingController(
    text: DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
  );

  List<dynamic> _categories = [];
  List<dynamic> _locations = [];
  String? _selectedCategoryId;
  String? _selectedLocationId;
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    setState(() => _isLoadingData = true);
    try {
      final dio = ref.read(dioProvider);

      // Fetch categories
      final catRes = await dio.get('/foods/categories');
      if (catRes.statusCode == 200 && catRes.data != null) {
        final data = catRes.data;
        if (data is List) {
          _categories = data;
        } else if (data is Map) {
          _categories = data['categories'] ?? data['data'] ?? data['result'] ?? [];
        }
      }

      // Fetch storage locations
      final locRes = await dio.get('/storage-locations', queryParameters: {'ownerType': 'personal'});
      if (locRes.statusCode == 200 && locRes.data != null) {
        final data = locRes.data;
        if (data is List) {
          _locations = data;
        } else if (data is Map) {
          _locations = data['locations'] ?? data['data'] ?? data['result'] ?? [];
        }
      }

      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first['id'] ?? _categories.first['_id'];
      }
      if (_locations.isNotEmpty) {
        _selectedLocationId = _locations.first['id'] ?? _locations.first['_id'];
      }

      if (widget.foodId != null) {
        // If editing, fetch food detail
        final foodRes = await dio.get('/foods/${widget.foodId}');
        if (foodRes.statusCode == 200 && foodRes.data != null) {
          final food = foodRes.data is Map ? foodRes.data : foodRes.data['food'];
          if (food != null) {
            _nameController.text = food['name'] ?? food['foodName'] ?? '';
            _quantityController.text = (food['quantity'] ?? 1).toString();
            _unitController.text = food['unit'] ?? 'cái';
            _expiryController.text = food['expiryDate'] ?? food['expiresAt'] ?? '';
            if (food['categoryId'] != null) {
              _selectedCategoryId = food['categoryId'] is Map 
                  ? (food['categoryId']['id'] ?? food['categoryId']['_id']) 
                  : food['categoryId'].toString();
            }
            if (food['storageLocationId'] != null) {
              _selectedLocationId = food['storageLocationId'] is Map 
                  ? (food['storageLocationId']['id'] ?? food['storageLocationId']['_id']) 
                  : food['storageLocationId'].toString();
            }
          }
        }
      }
    } catch (e) {
      // Handle loading error
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục và vị trí lưu trữ'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dio = ref.read(dioProvider);
      final data = {
        'foodName': _nameController.text.trim(),
        'name': _nameController.text.trim(),
        'quantity': double.tryParse(_quantityController.text) ?? 1.0,
        'unit': _unitController.text.trim(),
        'categoryId': _selectedCategoryId,
        'storageLocationId': _selectedLocationId,
        'ownerType': 'personal',
        'sourceType': 'MANUAL',
        'expiryType': 'EXACT_DATE',
        'purchaseDate': DateTime.now().toIso8601String().split('T')[0],
        'expiryDate': _expiryController.text.trim(),
      };

      if (widget.foodId == null) {
        await dio.post('/foods', data: data);
      } else {
        await dio.put('/foods/${widget.foodId}', data: data);
      }

      if (!mounted) return;
      context.pop();
    } on DioException catch (e) {
      String msg = 'Lỗi khi lưu thực phẩm.';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        msg = e.response?.data['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foodId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Sửa thực phẩm' : 'Thêm thực phẩm')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên thực phẩm',
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Nhập số lượng' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị (cái, kg...)',
                              prefixIcon: Icon(Icons.scale),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Nhập đơn vị' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categories.any((c) => (c['id'] ?? c['_id']).toString() == _selectedCategoryId)
                          ? _selectedCategoryId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục thực phẩm',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map<DropdownMenuItem<String>>((cat) {
                        final id = (cat['id'] ?? cat['_id']).toString();
                        final name = cat['name'] ?? cat['categoryName'] ?? 'Danh mục';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (val) => val == null ? 'Vui lòng chọn danh mục' : null,
                    ),
                    const SizedBox(height: 16),
                    // Storage Location Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _locations.any((l) => (l['id'] ?? l['_id']).toString() == _selectedLocationId)
                          ? _selectedLocationId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Vị trí lưu trữ',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _locations.map<DropdownMenuItem<String>>((loc) {
                        final id = (loc['id'] ?? loc['_id']).toString();
                        final name = loc['name'] ?? loc['storageName'] ?? 'Vị trí';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLocationId = val),
                      validator: (val) => val == null ? 'Vui lòng chọn vị trí lưu trữ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Ngày hết hạn (YYYY-MM-DD)',
                        hintText: 'VD: 2025-12-31',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Nhập ngày hết hạn' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'Cập nhật' : 'Thêm vào kho'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
