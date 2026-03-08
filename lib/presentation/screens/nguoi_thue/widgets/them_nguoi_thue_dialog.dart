import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/nguoi_thue_entity.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_event.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_state.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_dialog_actions.dart';
import '../../../widgets/app_snackbar.dart';

class ThemNguoiThueDialog extends StatefulWidget {
  final String chuNhaId;
  final NguoiThueEntity? initialNguoiThue;

  const ThemNguoiThueDialog({
    super.key,
    required this.chuNhaId,
    this.initialNguoiThue,
  });

  @override
  State<ThemNguoiThueDialog> createState() => _ThemNguoiThueDialogState();
}

class _ThemNguoiThueDialogState extends State<ThemNguoiThueDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _soDienThoaiController;
  late TextEditingController _cccdController;
  late TextEditingController _queQuanController;

  bool get _isEditing => widget.initialNguoiThue != null;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.initialNguoiThue?.hoTen ?? '');
    _soDienThoaiController = TextEditingController(text: widget.initialNguoiThue?.soDienThoai ?? '');
    _cccdController = TextEditingController(text: widget.initialNguoiThue?.cccd ?? '');
    _queQuanController = TextEditingController(text: widget.initialNguoiThue?.queQuan ?? '');
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _soDienThoaiController.dispose();
    _cccdController.dispose();
    _queQuanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final nguoiThue = NguoiThueEntity(
      id: widget.initialNguoiThue?.id ?? '',
      hoTen: _hoTenController.text.trim(),
      soDienThoai: _soDienThoaiController.text.trim(),
      cccd: _cccdController.text.trim().isEmpty ? null : _cccdController.text.trim(),
      queQuan: _queQuanController.text.trim().isEmpty ? null : _queQuanController.text.trim(),
      chuNhaId: widget.chuNhaId,
      createdAt: widget.initialNguoiThue?.createdAt,
      anhCCCD: widget.initialNguoiThue?.anhCCCD ?? [],
      ngaySinh: widget.initialNguoiThue?.ngaySinh,
    );

    if (_isEditing) {
      context.read<NguoiThueBloc>().add(UpdateNguoiThueRequested(nguoiThue));
    } else {
      context.read<NguoiThueBloc>().add(ThemNguoiThueRequested(nguoiThue));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NguoiThueBloc, NguoiThueState>(
      listener: (context, state) {
        if (state is NguoiThueActionSuccess) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(
              context, _isEditing ? 'Cập nhật thành công!' : 'Thêm người thuê thành công!');
        } else if (state is NguoiThueActionFailure) {
          AppSnackBar.showError(context, 'Lỗi: ${state.message}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Sửa thông tin người thuê' : 'Thêm người thuê mới',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _hoTenController,
                  label: 'Họ và tên',
                  hint: 'Nhập họ tên đầy đủ...',
                  isRequired: true,
                ),
                AppTextField(
                  controller: _soDienThoaiController,
                  label: 'Số điện thoại',
                  hint: 'Nhập số điện thoại...',
                  isNumber: true,
                  isRequired: true,
                ),
                AppTextField(
                  controller: _cccdController,
                  label: 'Số CCCD/CMND (Tùy chọn)',
                  hint: 'Nhập số CCCD...',
                ),
                AppTextField(
                  controller: _queQuanController,
                  label: 'Quê quán (Tùy chọn)',
                  hint: 'Nhập quê quán...',
                ),
                const SizedBox(height: 32),
                BlocBuilder<NguoiThueBloc, NguoiThueState>(
                  builder: (context, state) {
                    final isLoading = state is NguoiThueActionLoading;
                    return AppDialogActions(
                      isLoading: isLoading,
                      onCancel: () => Navigator.of(context).pop(),
                      onSubmit: _submit,
                      submitLabel: _isEditing ? 'Cập nhật' : 'Thêm mới',
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
