import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_Injection.dart';
import '../../../../domain/entities/nguoi_thue_entity.dart';
import '../../../../domain/usecases/get_phong.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_bloc.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_event.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_event.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_state.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_dialog_actions.dart';
import '../../../widgets/app_snackbar.dart';
import '../../gia/widgets/chon_phong_selection_dialog.dart';

class ThemNguoiThueDialog extends StatefulWidget {
  final String chuNhaId;
  final NguoiThueEntity? initialNguoiThue;
  final ScrollController? scrollController;
  final String? preselectedPhongId;
  final bool isRoomFixed;

  const ThemNguoiThueDialog({
    super.key,
    required this.chuNhaId,
    this.initialNguoiThue,
    this.scrollController,
    this.preselectedPhongId,
    this.isRoomFixed = false,
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
  late TextEditingController _phongNameController;
  DateTime? _birthday;
  String? _selectedPhongId;

  bool get _isEditing => widget.initialNguoiThue != null;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.initialNguoiThue?.hoTen ?? '');
    _soDienThoaiController = TextEditingController(text: widget.initialNguoiThue?.soDienThoai ?? '');
    _cccdController = TextEditingController(text: widget.initialNguoiThue?.cccd ?? '');
    _queQuanController = TextEditingController(text: widget.initialNguoiThue?.queQuan ?? '');
    _phongNameController = TextEditingController();
    _birthday = widget.initialNguoiThue?.ngaySinh;
    _selectedPhongId = widget.preselectedPhongId ?? widget.initialNguoiThue?.phongId;

    if (_selectedPhongId != null) {
      _loadRoomDetail();
    }
  }

  Future<void> _loadRoomDetail() async {
    final detail = await serviceLocator<GetPhongUseCase>().call(_selectedPhongId!);
    if (detail != null && mounted) {
      setState(() {
        _phongNameController.text = 'Phòng ${detail.phong.tenPhong} (${detail.nhaTro?.tenNhaTro ?? ''})';
      });
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _soDienThoaiController.dispose();
    _cccdController.dispose();
    _queQuanController.dispose();
    _phongNameController.dispose();
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
      ngaySinh: _birthday,
      phongId: widget.initialNguoiThue?.phongId,
    );

    if (_isEditing) {
      context.read<NguoiThueBloc>().add(UpdateNguoiThueRequested(
            nguoiThue,
            newPhongId: _selectedPhongId,
          ));
    } else {
      context.read<NguoiThueBloc>().add(ThemNguoiThueRequested(
            nguoiThue,
            phongId: _selectedPhongId,
          ));
    }
  }

  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  void _selectPhong() {
    if (widget.isRoomFixed) {
      AppSnackBar.showError(context, 'Không thể đổi phòng khi thêm trực tiếp từ chi tiết phòng.');
      return;
    }

    showModalBottomSheet<List<RoomSelectionResult>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => serviceLocator<ApDungBangGiaBloc>()..add(ApDungBangGiaStarted(widget.chuNhaId)),
        child: ChonPhongSelectionDialog(
          initialSelectedIds: _selectedPhongId != null ? [_selectedPhongId!] : [],
          isSingleSelection: true,
        ),
      ),
    ).then((selectedIds) {
      if (selectedIds != null && selectedIds.isNotEmpty) {
        setState(() {
          final result = selectedIds.first;
          _selectedPhongId = result.id;
          _phongNameController.text = result.displayName;
        });
      }
    });
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
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: widget.scrollController,
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
                  controller: TextEditingController(
                    text: _birthday != null ? DateFormat('dd/MM/yyyy').format(_birthday!) : '',
                  ),
                  label: 'Ngày sinh (Tùy chọn)',
                  hint: 'Chọn ngày sinh...',
                  readOnly: true,
                  onTap: _selectBirthday,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                  isRequired: false,
                ),
                AppTextField(
                  controller: _cccdController,
                  label: 'Số CCCD/CMND (Tùy chọn)',
                  hint: 'Nhập số CCCD...',
                  isRequired: false,
                ),
                AppTextField(
                  controller: _queQuanController,
                  label: 'Quê quán (Tùy chọn)',
                  hint: 'Nhập quê quán...',
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phongNameController,
                  label: 'Phòng thuê (Tùy chọn)',
                  hint: 'Chọn phòng thuê...',
                  readOnly: true,
                  onTap: widget.isRoomFixed ? null : _selectPhong,
                  suffixIcon: Icon(
                    widget.isRoomFixed ? Icons.lock_outline : Icons.meeting_room,
                    size: 20, 
                    color: widget.isRoomFixed ? AppColors.textSecondary : AppColors.primary,
                  ),
                  isRequired: false,
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
