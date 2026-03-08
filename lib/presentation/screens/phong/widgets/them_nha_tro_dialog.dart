import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/phong/phong_bloc.dart';
import '../../../bloc/phong/phong_event.dart';
import '../../../bloc/phong/phong_state.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_dialog_actions.dart';
import '../../../widgets/app_snackbar.dart';

import '../../../../domain/entities/nha_tro_entity.dart';

class ThemNhaTroDialog extends StatefulWidget {
  final String chuNhaId;
  final NhaTroEntity? initialNhaTro;
  final ScrollController? scrollController;

  const ThemNhaTroDialog({
    super.key,
    required this.chuNhaId,
    this.initialNhaTro,
    this.scrollController,
  });

  @override
  State<ThemNhaTroDialog> createState() => _ThemNhaTroDialogState();
}

class _ThemNhaTroDialogState extends State<ThemNhaTroDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenNhaTroController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soLuongPhongController = TextEditingController(text: '1');

  bool get _isEditing => widget.initialNhaTro != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _tenNhaTroController.text = widget.initialNhaTro!.tenNhaTro;
      _diaChiController.text = widget.initialNhaTro!.diaChi;
    }
  }

  @override
  void dispose() {
    _tenNhaTroController.dispose();
    _diaChiController.dispose();
    _soLuongPhongController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final updatedNhaTro = widget.initialNhaTro!.copyWith(
        tenNhaTro: _tenNhaTroController.text.trim(),
        diaChi: _diaChiController.text.trim(),
      );
      context.read<PhongBloc>().add(UpdateNhaTroRequested(updatedNhaTro));
    } else {
      context.read<PhongBloc>().add(ThemNhaTroRequested(
            tenNhaTro: _tenNhaTroController.text.trim(),
            diaChi: _diaChiController.text.trim(),
            soLuongPhong: int.parse(_soLuongPhongController.text.trim()),
            chuNhaId: widget.chuNhaId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhongBloc, PhongState>(
      listener: (context, state) {
        if (state is ThemNhaTroSuccess) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(context, _isEditing ? 'Cập nhật nhà trọ thành công!' : 'Tạo nhà trọ và các phòng thành công!');
        } else if (state is ThemNhaTroFailure) {
          AppSnackBar.showError(context, 'Lỗi: ${state.message}');
        }
      },
      child: BlocBuilder<PhongBloc, PhongState>(
        builder: (context, state) {
          final isBlocLoading = state is ThemNhaTroLoading;
          
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar for dragging
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Sửa thông tin nhà trọ' : 'Thêm nhà trọ mới',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(16),
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
                          if (!_isEditing)
                            AppTextField(
                              controller: _soLuongPhongController,
                              label: 'Số lượng phòng',
                              hint: '1',
                              isLoading: isBlocLoading,
                              isNumber: true,
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer Actions
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppDialogActions(
                      isLoading: isBlocLoading,
                      onCancel: () => Navigator.of(context).pop(),
                      onSubmit: _submit,
                      submitLabel: _isEditing ? 'Cập nhật' : 'Tạo mới',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
