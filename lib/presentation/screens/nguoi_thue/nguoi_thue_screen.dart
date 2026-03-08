import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/dependency_Injection.dart';
import '../../../domain/entities/nguoi_thue_entity.dart';
import '../../../domain/usecases/get_phong.dart';
import '../../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../bloc/nguoi_thue/nguoi_thue_state.dart';
import '../../bloc/nguoi_thue/nguoi_thue_event.dart';
import '../../widgets/empty_data_widget.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/app_expansion_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/app_snackbar.dart';
import 'widgets/them_nguoi_thue_dialog.dart';

class NguoiThueScreen extends StatelessWidget {
  const NguoiThueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NguoiThueBloc, NguoiThueState>(
      buildWhen: (previous, current) =>
          current is NguoiThueLoading || 
          current is NguoiThueLoaded || 
          current is NguoiThueError ||
          current is NguoiThueActionLoading ||
          current is NguoiThueActionSuccess ||
          current is NguoiThueActionFailure,
      builder: (context, state) {
        if (state is NguoiThueLoading || state is NguoiThueActionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NguoiThueError) {
          return Center(
            child: Text(
              'Lỗi: ${state.message}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        if (state is NguoiThueLoaded) {
          if (state.items.isEmpty) {
            return const EmptyDataWidget(
              icon: Icons.people_outline,
              title: 'Chưa có người thuê nào',
              subtitle: 'Nhấn nút + để thêm người thuê mới vào danh sách quản lý.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _NguoiThueCard(item: item);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _NguoiThueCard extends StatefulWidget {
  final NguoiThueEntity item;

  const _NguoiThueCard({required this.item});

  @override
  State<_NguoiThueCard> createState() => _NguoiThueCardState();
}

class _NguoiThueCardState extends State<_NguoiThueCard> {
  String? _phongName;

  void _showThemNguoiThueDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<NguoiThueBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) => ThemNguoiThueDialog(
            chuNhaId: widget.item.chuNhaId,
            initialNguoiThue: widget.item,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNguoiThue(BuildContext context) {
    AppConfirmDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa thông tin người thuê "${widget.item.hoTen}"?',
      confirmLabel: 'Xóa',
      confirmColor: AppColors.error,
      onConfirm: () {
        context.read<NguoiThueBloc>().add(XoaNguoiThueRequested(
              widget.item.id,
              currentPhongId: widget.item.phongId,
            ));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRoomDetail();
  }

  Future<void> _loadRoomDetail() async {
    if (widget.item.phongId != null) {
      final detail = await serviceLocator<GetPhongUseCase>().call(widget.item.phongId!);
      if (detail != null && mounted) {
        setState(() {
          _phongName = 'Phòng ${detail.phong.tenPhong} (${detail.nhaTro?.tenNhaTro ?? ''})';
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          AppSnackBar.showError(context, 'Không thể mở trình gọi điện');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Lỗi: ${e.toString()}');
      }
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      AppSnackBar.showInfo(context, 'Đã sao chép $label');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppExpansionCard(
      title: Text(
        widget.item.hoTen,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(_phongName ?? 'Đang tải thông tin phòng...', style: const TextStyle(color: AppColors.primary)),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
      onEdit: () => _showThemNguoiThueDialog(context),
      onDelete: () => _confirmDeleteNguoiThue(context),
      children: [
        _buildInfoRow(
          Icons.phone,
          'Số điện thoại:',
          widget.item.soDienThoai,
          onTap: () => _makePhoneCall(widget.item.soDienThoai),
          isLink: true,
          onCopy: () => _copyToClipboard(widget.item.soDienThoai, 'số điện thoại'),
        ),
        if (widget.item.ngaySinh != null)
          _buildInfoRow(Icons.cake, 'Ngày sinh:', DateFormat('dd/MM/yyyy').format(widget.item.ngaySinh!)),
        if (widget.item.cccd != null)
          _buildInfoRow(
            Icons.badge,
            'CCCD/CMND:',
            widget.item.cccd!,
            onCopy: () => _copyToClipboard(widget.item.cccd!, 'số CCCD'),
          ),
        if (widget.item.queQuan != null)
          _buildInfoRow(Icons.location_on, 'Quê quán:', widget.item.queQuan!),
        _buildInfoRow(
          Icons.calendar_today,
          'Ngày tham gia:',
          widget.item.createdAt != null ? DateFormat('dd/MM/yyyy').format(widget.item.createdAt!) : 'N/A',
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    bool isLink = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        color: isLink ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isLink ? FontWeight.bold : FontWeight.w400,
                        decoration: isLink ? TextDecoration.underline : null,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: onCopy,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              tooltip: 'Sao chép',
              visualDensity: VisualDensity.compact,
            ),
          if (onTap != null && value == 'Đang tải...')
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
