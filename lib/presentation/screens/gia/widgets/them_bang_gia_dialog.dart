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
import '../../../../core/utils/currency_format.dart';
import '../../../../core/di/dependency_Injection.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_bloc.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_event.dart';
import 'chon_phong_selection_dialog.dart';

class ThemBangGiaDialog extends StatefulWidget {
  final String chuNhaId;
  final BangGiaEntity? initialBangGia;
  final ScrollController? scrollController;

  const ThemBangGiaDialog({
    super.key,
    required this.chuNhaId,
    this.initialBangGia,
    this.scrollController,
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
  
  List<String> _selectedPhongIds = [];

  bool get _isEditing => widget.initialBangGia != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final bg = widget.initialBangGia!;
      _tenController.text = bg.tenBangGia;
      _giaThueController.text = CurrencyFormat.format(bg.giaThue);
      _giaDienController.text = CurrencyFormat.format(bg.giaDien);
      _cachTinhDien = bg.cachTinhDien;
      _giaNuocController.text = CurrencyFormat.format(bg.giaNuoc);
      _cachTinhNuoc = bg.cachTinhNuoc;
      _giaInternetController.text = CurrencyFormat.format(bg.giaInternet);
      _cachTinhInternet = bg.cachTinhInternet;
      _chiPhiKhacController.text = bg.chiPhiKhac != null ? CurrencyFormat.format(bg.chiPhiKhac!) : '';
      _ghiChuController.text = bg.ghiChu ?? '';
    }
  }
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
      id: _isEditing ? widget.initialBangGia!.id : '',
      tenBangGia: _tenController.text.trim(),
      chuNhaId: widget.chuNhaId,
      giaThue: CurrencyFormat.parse(_giaThueController.text.trim()),
      giaDien: CurrencyFormat.parse(_giaDienController.text.trim()),
      cachTinhDien: _cachTinhDien,
      giaNuoc: CurrencyFormat.parse(_giaNuocController.text.trim()),
      cachTinhNuoc: _cachTinhNuoc,
      giaInternet: CurrencyFormat.parse(_giaInternetController.text.trim()),
      cachTinhInternet: _cachTinhInternet,
      chiPhiKhac: CurrencyFormat.parse(_chiPhiKhacController.text.trim()),
      ghiChu: _ghiChuController.text.trim().isEmpty ? null : _ghiChuController.text.trim(),
    );

    if (_isEditing) {
      context.read<BangGiaBloc>().add(UpdateBangGiaRequested(entity));
    } else {
      context.read<BangGiaBloc>().add(ThemBangGiaRequested(
            entity,
            selectedPhongIds: _selectedPhongIds,
          ));
    }
  }

  void _onTapChonPhong() async {
    final result = await showModalBottomSheet<List<RoomSelectionResult>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider(
        create: (context) => serviceLocator<ApDungBangGiaBloc>()..add(ApDungBangGiaStarted(widget.chuNhaId)),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) => ChonPhongSelectionDialog(
            initialSelectedIds: _selectedPhongIds,
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPhongIds = result.map((r) => r.id).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BangGiaBloc, BangGiaState>(
      listener: (context, state) {
        if (state is ThemBangGiaSuccess) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(context, _isEditing ? 'Cập nhật bảng giá thành công!' : 'Thêm bảng giá thành công!');
        } else if (state is ThemBangGiaFailure) {
          AppSnackBar.showError(context, 'Lỗi: ${state.message}');
        }
      },
      child: BlocBuilder<BangGiaBloc, BangGiaState>(
        builder: (context, state) {
          final isLoading = state is ThemBangGiaLoading;

          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
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
                        _isEditing ? 'Sửa bảng giá' : 'Thêm bảng giá mới',
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
                          AppTextField(controller: _tenController, label: 'Tên bảng giá', hint: 'VD: Giá sinh viên...', isLoading: isLoading),
                          AppTextField(controller: _giaThueController, label: 'Giá thuê (VND/tháng)', hint: 'VND...', isLoading: isLoading, isCurrency: true),
                          const Divider(height: 32),
                          const AppSectionHeader(title: 'Tiền Điện'),
                          AppTextField(controller: _giaDienController, label: 'Mức giá điện', hint: 'VND...', isLoading: isLoading, isCurrency: true),
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
                          AppTextField(controller: _giaNuocController, label: 'Mức giá nước', hint: 'VND...', isLoading: isLoading, isCurrency: true),
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
                          AppTextField(controller: _giaInternetController, label: 'Mức giá internet', hint: 'VND...', isLoading: isLoading, isCurrency: true),
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
                          AppTextField(controller: _chiPhiKhacController, label: 'Số tiền (không bắt buộc)', hint: 'VND...', isLoading: isLoading, isCurrency: true, isRequired: false),
                          AppTextField(controller: _ghiChuController, label: 'Ghi chú chi phí', hint: 'VD: Rác, vệ sinh...', isLoading: isLoading, isRequired: false),
                          const Divider(height: 32),
                          
                          if (!_isEditing) ...[
                            // Chọn phòng
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Áp dụng cho phòng', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(_selectedPhongIds.isEmpty ? 'Chưa chọn phòng nào' : 'Đã chọn ${_selectedPhongIds.length} phòng'),
                              trailing: TextButton.icon(
                                onPressed: isLoading ? null : _onTapChonPhong,
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                label: Text(_selectedPhongIds.isEmpty ? 'Chọn phòng' : 'Thay đổi'),
                              ),
                            ),
                            if (_selectedPhongIds.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Bảng giá này sẽ được áp dụng ngay cho các phòng đã chọn sau khi lưu.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                          const SizedBox(height: 16),
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
                      isLoading: isLoading,
                      onCancel: () => Navigator.pop(context),
                      onSubmit: _submit,
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
