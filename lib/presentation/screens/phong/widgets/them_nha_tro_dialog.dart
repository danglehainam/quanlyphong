import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../bloc/phong/phong_bloc.dart';
import '../../../bloc/phong/phong_event.dart';
import '../../../bloc/phong/phong_state.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_dialog_actions.dart';

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
                    AppTextField(
                      controller: _tenNhaTroController,
                      label: 'Tên nhà trọ',
                      hint: 'VD: Trọ Sinh Viên...',
                      isLoading: isBlocLoading,
                    ),
                    AppTextField(
                      controller: _diaChiController,
                      label: 'Địa chỉ',
                      hint: 'Nhập địa chỉ...',
                      isLoading: isBlocLoading,
                    ),
                    AppTextField(
                      controller: _soLuongPhongController,
                      label: 'Số lượng phòng',
                      hint: '1',
                      isLoading: isBlocLoading,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              AppDialogActions(
                isLoading: isBlocLoading,
                onCancel: () => Navigator.of(context).pop(),
                onSubmit: _submit,
                submitLabel: 'Tạo mới',
              ),
            ],
          );
        },
      ),
    );
  }
}
