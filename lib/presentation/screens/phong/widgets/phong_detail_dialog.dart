import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../domain/entities/phong_entity.dart';
import '../../../../domain/entities/bang_gia_entity.dart';
import '../../../../domain/entities/nguoi_thue_entity.dart';
import '../../../../domain/usecases/get_bang_gia_by_id.dart';
import '../../../../domain/usecases/get_nguoi_thue_by_id.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_event.dart';
import '../../../bloc/nguoi_thue/nguoi_thue_state.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_confirm_dialog.dart';
import '../../nguoi_thue/widgets/them_nguoi_thue_dialog.dart';

class PhongDetailDialog extends StatefulWidget {
  final PhongEntity phong;
  final String nhaTroName;

  const PhongDetailDialog({
    super.key,
    required this.phong,
    required this.nhaTroName,
  });

  @override
  State<PhongDetailDialog> createState() => _PhongDetailDialogState();
}

class _PhongDetailDialogState extends State<PhongDetailDialog> {
  BangGiaEntity? _bangGia;
  List<NguoiThueEntity> _khachThue = [];
  bool _isLoading = true;
  late NguoiThueBloc _nguoiThueBloc;

  @override
  void initState() {
    super.initState();
    _nguoiThueBloc = serviceLocator<NguoiThueBloc>();
    _loadDetails();
  }

  @override
  void dispose() {
    _nguoiThueBloc.close();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    // Load bangGia và khachThue độc lập với nhau,
    // để lỗi của một bên không ảnh hưởng bên còn lại.

    // 1. Load bảng giá
    BangGiaEntity? bangGia;
    if (widget.phong.bangGiaId != null) {
      try {
        bangGia = await serviceLocator<GetBangGiaByIdUseCase>().call(widget.phong.bangGiaId!);
      } catch (_) {
        bangGia = null;
      }
    }

    // 2. Load từng khách thuê
    final khachThue = <NguoiThueEntity>[];
    for (final id in widget.phong.khachThue) {
      try {
        final nguoiThue = await serviceLocator<GetNguoiThueByIdUseCase>().call(id);
        if (nguoiThue != null) khachThue.add(nguoiThue);
      } catch (_) {
        // bỏ qua nếu không đọc được, tiếp tục các id còn lại
      }
    }

    if (!mounted) return;
    setState(() {
      _bangGia = bangGia;
      _khachThue = khachThue;
      _isLoading = false;
    });
  }

  void _showThemNguoiThue() async {
    // 1. Lưu lại các biến cần thiết trước khi pop (vì context cũ sẽ bị unmount)
    final rootContext = Navigator.of(context).context;
    final chuNhaId = widget.phong.chuNhaId;
    final phongId = widget.phong.id;

    // 2. Đóng dialog hiện tại
    Navigator.of(context).pop();

    // 3. Đợi một event loop cho an toàn (tránh conflic root navigator)
    await Future.delayed(const Duration(milliseconds: 50));

    // 4. Mở dialog mới từ rootContext, cung cấp Bloc riêng
    if (!rootContext.mounted) return;
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (bottomSheetContext, controller) => BlocProvider<NguoiThueBloc>(
          create: (ctx) => serviceLocator<NguoiThueBloc>(),
          child: ThemNguoiThueDialog(
            chuNhaId: chuNhaId,
            scrollController: controller,
            preselectedPhongId: phongId,
            isRoomFixed: true,
          ),
        ),
      ),
    );
  }

  void _confirmRemoveRenter(NguoiThueEntity nguoiThue) {
    showDialog(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: 'Xóa khỏi phòng',
        content: 'Bạn có chắc chắn muốn xóa khách thuê "${nguoiThue.hoTen}" khỏi phòng này không?\n\nNgười này vẫn sẽ được lưu trong danh sách Người thuê chung.',
        confirmLabel: 'Xóa',
        confirmColor: AppColors.error,
        onConfirm: () {
          _nguoiThueBloc.add(XoaKhachThuKhoiPhongRequested(nguoiThue, widget.phong.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _nguoiThueBloc,
      child: BlocListener<NguoiThueBloc, NguoiThueState>(
        listener: (context, state) {
          if (state is NguoiThueActionSuccess) {
            AppSnackBar.showSuccess(context, 'Đã xóa khách thuê khỏi phòng!');
            setState(() => _isLoading = true);
            _loadDetails();
          } else if (state is NguoiThueActionFailure) {
            AppSnackBar.showError(context, 'Lỗi: ${state.message}');
          }
        },
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                // Room icon + badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.door_front_door_outlined, color: _statusColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phòng ${widget.phong.tenPhong}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.nhaTroName,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(trangThai: widget.phong.trangThai),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tenants section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SectionTitle(
                              icon: Icons.people_outlined,
                              title: 'Khách thuê',
                              count: _khachThue.length,
                            ),
                            TextButton.icon(
                              onPressed: _showThemNguoiThue,
                              icon: const Icon(Icons.person_add_alt_1, size: 16),
                              label: const Text('Thêm khách', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_khachThue.isEmpty)
                          _EmptyRow(label: 'Chưa có khách thuê')
                        else
                          ..._khachThue.map((nt) => _KhachThueRow(
                                nguoiThue: nt,
                                onRemove: () => _confirmRemoveRenter(nt),
                              )),

                        const SizedBox(height: 20),

                        // Pricing section
                        _SectionTitle(
                          icon: Icons.receipt_long_outlined,
                          title: 'Bảng giá đang áp dụng',
                        ),
                        const SizedBox(height: 8),
                        if (_bangGia == null)
                          _EmptyRow(label: 'Chưa có bảng giá')
                        else
                          _BangGiaCard(bangGia: _bangGia!),

                        // Details section
                        const SizedBox(height: 20),
                        _SectionTitle(
                          icon: Icons.info_outline,
                          title: 'Chi tiết phòng',
                        ),
                        const SizedBox(height: 8),
                        if (widget.phong.chiSoDienHienTai != null)
                          _InfoRow(
                            icon: Icons.electric_bolt,
                            label: 'Chỉ số điện hiện tại:',
                            value: '${widget.phong.chiSoDienHienTai} kWh',
                          ),
                        if (widget.phong.chiSoNuocHienTai != null)
                          _InfoRow(
                            icon: Icons.water_drop_outlined,
                            label: 'Chỉ số nước hiện tại:',
                            value: '${widget.phong.chiSoNuocHienTai} m³',
                          ),
                        if (widget.phong.moTa != null)
                          _InfoRow(
                            icon: Icons.notes,
                            label: 'Ghi chú:',
                            value: widget.phong.moTa!,
                          ),
                        if (widget.phong.createdAt != null)
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Ngày tạo:',
                            value: DateFormat('dd/MM/yyyy').format(widget.phong.createdAt!),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đóng', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    )));
  }

  Color get _statusColor => switch (widget.phong.trangThai) {
        PhongTrangThai.trong => AppColors.phongTrong,
        PhongTrangThai.daThue => AppColors.phongDaThue,
        PhongTrangThai.baoTri => AppColors.phongBaoTri,
        PhongTrangThai.chuaThanhToan => AppColors.phongChuaThanhToan,
      };
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final PhongTrangThai trangThai;
  const _StatusBadge({required this.trangThai});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (trangThai) {
      PhongTrangThai.trong => ('Trống', AppColors.phongTrong),
      PhongTrangThai.daThue => ('Đã thuê', AppColors.phongDaThue),
      PhongTrangThai.baoTri => ('Bảo trì', AppColors.phongBaoTri),
      PhongTrangThai.chuaThanhToan => ('Nợ tiền', AppColors.phongChuaThanhToan),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;

  const _SectionTitle({required this.icon, required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String label;
  const _EmptyRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}

class _KhachThueRow extends StatelessWidget {
  final NguoiThueEntity nguoiThue;
  final VoidCallback onRemove;
  const _KhachThueRow({required this.nguoiThue, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nguoiThue.hoTen, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    nguoiThue.soDienThoai,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_remove_outlined, color: AppColors.error),
              tooltip: 'Xóa khỏi phòng',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _BangGiaCard extends StatelessWidget {
  final BangGiaEntity bangGia;
  const _BangGiaCard({required this.bangGia});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.label_important_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  bangGia.tenBangGia,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _PriceRow(label: 'Giá thuê:', value: '${CurrencyFormat.format(bangGia.giaThue)} VND/tháng'),
          _PriceRow(label: 'Tiền điện:', value: '${CurrencyFormat.format(bangGia.giaDien)} VND/${_cachTinh(bangGia.cachTinhDien, 'số')}'),
          _PriceRow(label: 'Tiền nước:', value: '${CurrencyFormat.format(bangGia.giaNuoc)} VND/${_cachTinh(bangGia.cachTinhNuoc, 'm³')}'),
          _PriceRow(label: 'Internet:', value: '${CurrencyFormat.format(bangGia.giaInternet)} VND/${bangGia.cachTinhInternet == 0 ? 'phòng' : 'người'}'),
          if (bangGia.chiPhiKhac != null)
            _PriceRow(label: 'Chi phí khác:', value: '${CurrencyFormat.format(bangGia.chiPhiKhac!)} VND'),
        ],
      ),
    );
  }

  String _cachTinh(int value, String unit) {
    return switch (value) {
      0 => unit,
      1 => 'người',
      _ => 'tự nhập',
    };
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
