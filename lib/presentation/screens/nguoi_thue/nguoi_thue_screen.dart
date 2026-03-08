import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/nguoi_thue_entity.dart';
import '../../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../bloc/nguoi_thue/nguoi_thue_state.dart';
import '../../bloc/nguoi_thue/nguoi_thue_event.dart';
import '../../widgets/empty_data_widget.dart';
import '../../widgets/app_confirm_dialog.dart';
import 'widgets/them_nguoi_thue_dialog.dart';

class NguoiThueScreen extends StatelessWidget {
  const NguoiThueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NguoiThueBloc, NguoiThueState>(
      buildWhen: (previous, current) =>
          current is NguoiThueLoading || current is NguoiThueLoaded || current is NguoiThueError,
      builder: (context, state) {
        if (state is NguoiThueLoading) {
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

class _NguoiThueCard extends StatelessWidget {
  final NguoiThueEntity item;

  const _NguoiThueCard({required this.item});

  void _showThemNguoiThueDialog(BuildContext context) {
    final chuNhaId = item.chuNhaId;
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
            chuNhaId: chuNhaId,
            initialNguoiThue: item,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNguoiThue(BuildContext context) {
    AppConfirmDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa thông tin người thuê "${item.hoTen}"?',
      confirmLabel: 'Xóa',
      confirmColor: AppColors.error,
      onConfirm: () {
        context.read<NguoiThueBloc>().add(XoaNguoiThueRequested(
              item.id,
              currentPhongId: item.phongId,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          item.hoTen,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(item.soDienThoai, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            if (item.queQuan != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(item.queQuan!, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
              onPressed: () => _showThemNguoiThueDialog(context),
              tooltip: 'Sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: () => _confirmDeleteNguoiThue(context),
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}
