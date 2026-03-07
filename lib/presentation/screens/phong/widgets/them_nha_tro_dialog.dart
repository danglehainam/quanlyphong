import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../bloc/phong/phong_bloc.dart';
import '../../../bloc/phong/phong_event.dart';
import '../../../bloc/phong/phong_state.dart';

class ThemNhaTroDialog extends StatefulWidget {
  final String chuNhaId;

  const ThemNhaTroDialog({
    super.key,
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

  @override
  void dispose() {
    _tenNhaTroController.dispose();
    _diaChiController.dispose();
    _soLuongPhongController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<PhongBloc>().add(ThemNhaTroRequested(
          tenNhaTro: _tenNhaTroController.text.trim(),
          diaChi: _diaChiController.text.trim(),
          soLuongPhong: int.parse(_soLuongPhongController.text.trim()),
          chuNhaId: widget.chuNhaId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhongBloc, PhongState>(
      listener: (context, state) {
        if (state is ThemNhaTroSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo nhà trọ và các phòng thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ThemNhaTroFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<PhongBloc, PhongState>(
        builder: (context, state) {
          final isBlocLoading = state is ThemNhaTroLoading;
          
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
                      enabled: !isBlocLoading,
                      decoration: const InputDecoration(
                        labelText: 'Tên nhà trọ',
                        hintText: 'VD: Trọ Sinh Viên, Nhà trọ số 5...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tên nhà trọ'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _diaChiController,
                      enabled: !isBlocLoading,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ',
                        hintText: 'Nhập địa chỉ...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập địa chỉ'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _soLuongPhongController,
                      enabled: !isBlocLoading,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số lượng phòng',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập số lượng';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num <= 0) {
                          return 'Số phòng không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isBlocLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Hủy',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: isBlocLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: isBlocLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Tạo mới'),
              ),
            ],
          );
        },
      ),
    );
  }
}
