import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/bang_gia_entity.dart';
import '../../../bloc/bang_gia/bang_gia_bloc.dart';
import '../../../bloc/bang_gia/bang_gia_event.dart';
import '../../../bloc/bang_gia/bang_gia_state.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_dropdown_field.dart';
import '../../../widgets/app_dialog_actions.dart';
import '../../../widgets/app_section_header.dart';
import '../../../widgets/app_snackbar.dart';

class ThemBangGiaDialog extends StatefulWidget {
  final String chuNhaId;

  const ThemBangGiaDialog({
    super.key,
    required this.chuNhaId,
  });

  @override
  State<ThemBangGiaDialog> createState() => _ThemBangGiaDialogState();
}

class _ThemBangGiaDialogState extends State<ThemBangGiaDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _tenController = TextEditingController();
  final _giaThueController = TextEditingController();
  final _giaDienController = TextEditingController();
  final _giaNuocController = TextEditingController();
  final _giaInternetController = TextEditingController();
  final _chiPhiKhacController = TextEditingController();
  final _ghiChuController = TextEditingController();

  int _cachTinhDien = 0;
  int _cachTinhNuoc = 0;
  int _cachTinhInternet = 0;

  @override
  void dispose() {
    _tenController.dispose();
    _giaThueController.dispose();
    _giaDienController.dispose();
    _giaNuocController.dispose();
    _giaInternetController.dispose();
    _chiPhiKhacController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final entity = BangGiaEntity(
      id: '', // Firestore will generate
      tenBangGia: _tenController.text.trim(),
      chuNhaId: widget.chuNhaId,
      giaThue: int.parse(_giaThueController.text.trim()),
      giaDien: int.parse(_giaDienController.text.trim()),
      cachTinhDien: _cachTinhDien,
      giaNuoc: int.parse(_giaNuocController.text.trim()),
      cachTinhNuoc: _cachTinhNuoc,
      giaInternet: int.parse(_giaInternetController.text.trim()),
      cachTinhInternet: _cachTinhInternet,
      chiPhiKhac: int.tryParse(_chiPhiKhacController.text.trim()),
      ghiChu: _ghiChuController.text.trim().isEmpty ? null : _ghiChuController.text.trim(),
    );

    context.read<BangGiaBloc>().add(ThemBangGiaRequested(entity));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BangGiaBloc, BangGiaState>(
      listener: (context, state) {
        if (state is ThemBangGiaSuccess) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(context, 'Thêm bảng giá thành công!');
        } else if (state is ThemBangGiaFailure) {
          AppSnackBar.showError(context, 'Lỗi: ${state.message}');
        }
      },
      child: BlocBuilder<BangGiaBloc, BangGiaState>(
        builder: (context, state) {
          final isLoading = state is ThemBangGiaLoading;

          return AlertDialog(
            title: const Text('Thêm bảng giá mới'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(controller: _tenController, label: 'Tên bảng giá', hint: 'VD: Giá sinh viên...', isLoading: isLoading),
                    AppTextField(controller: _giaThueController, label: 'Giá thuê (VND/tháng)', hint: 'VND...', isLoading: isLoading, isNumber: true),
                    const Divider(height: 32),
                    const AppSectionHeader(title: 'Tiền Điện'),
                    AppTextField(controller: _giaDienController, label: 'Mức giá điện', hint: 'VND...', isLoading: isLoading, isNumber: true),
                    AppDropdownField<int>(
                      label: 'Cách tính điện',
                      value: _cachTinhDien,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('VND / số (kWh)')),
                        DropdownMenuItem(value: 1, child: Text('VND / người')),
                        DropdownMenuItem(value: 2, child: Text('Tự nhập')),
                      ],
                      onChanged: (val) => setState(() => _cachTinhDien = val!),
                    ),
                    const Divider(height: 32),
                    const AppSectionHeader(title: 'Tiền Nước'),
                    AppTextField(controller: _giaNuocController, label: 'Mức giá nước', hint: 'VND...', isLoading: isLoading, isNumber: true),
                    AppDropdownField<int>(
                      label: 'Cách tính nước',
                      value: _cachTinhNuoc,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('VND / khối (m³)')),
                        DropdownMenuItem(value: 1, child: Text('VND / người')),
                        DropdownMenuItem(value: 2, child: Text('Tự nhập')),
                      ],
                      onChanged: (val) => setState(() => _cachTinhNuoc = val!),
                    ),
                    const Divider(height: 32),
                    const AppSectionHeader(title: 'Internet'),
                    AppTextField(controller: _giaInternetController, label: 'Mức giá internet', hint: 'VND...', isLoading: isLoading, isNumber: true),
                    AppDropdownField<int>(
                      label: 'Cách tính internet',
                      value: _cachTinhInternet,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('VND / phòng')),
                        DropdownMenuItem(value: 1, child: Text('VND / người')),
                      ],
                      onChanged: (val) => setState(() => _cachTinhInternet = val!),
                    ),
                    const Divider(height: 32),
                    const AppSectionHeader(title: 'Chi phí khác'),
                    AppTextField(controller: _chiPhiKhacController, label: 'Số tiền (không bắt buộc)', hint: 'VND...', isLoading: isLoading, isNumber: true, isRequired: false),
                    AppTextField(controller: _ghiChuController, label: 'Ghi chú chi phí', hint: 'VD: Rác, vệ sinh...', isLoading: isLoading, isRequired: false),
                  ],
                ),
              ),
            ),
            actions: [
              AppDialogActions(
                isLoading: isLoading,
                onCancel: () => Navigator.pop(context),
                onSubmit: _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}
