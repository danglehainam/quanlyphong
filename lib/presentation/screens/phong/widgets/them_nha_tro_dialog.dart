import 'package:flutter/material.dart';
import '../../../../domain/usecases/them_nha_tro.dart';
import '../../../../core/constants/app_colors.dart';

class ThemNhaTroDialog extends StatefulWidget {
  final ThemNhaTroUseCase themNhaTroUseCase;
  final String chuNhaId;

  const ThemNhaTroDialog({
    super.key,
    required this.themNhaTroUseCase,
    required this.chuNhaId,
  });

  @override
  State<ThemNhaTroDialog> createState() => _ThemNhaTroDialogState();
}

class _ThemNhaTroDialogState extends State<ThemNhaTroDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenNhaTroController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soLuongPhongController = TextEditingController(text: '1');
  bool _isLoading = false;

  @override
  void dispose() {
    _tenNhaTroController.dispose();
    _diaChiController.dispose();
    _soLuongPhongController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      await widget.themNhaTroUseCase(
        tenNhaTro: _tenNhaTroController.text.trim(),
        diaChi: _diaChiController.text.trim(),
        soLuongPhong: int.parse(_soLuongPhongController.text.trim()),
        chuNhaId: widget.chuNhaId,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo nhà trọ và các phòng thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nhà trọ mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tenNhaTroController,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà trọ',
                  hintText: 'VD: Trọ Sinh Viên, Nhà trọ số 5...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Vui lòng nhập tên nhà trọ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _soLuongPhongController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng phòng',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nhập số lượng';
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) return 'Số phòng không hợp lệ';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Text('Tạo mới'),
        ),
      ],
    );
  }
}
