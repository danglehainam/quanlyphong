import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/phong/phong_bloc.dart';
import '../../bloc/phong/phong_event.dart';
import '../../bloc/phong/phong_state.dart';
import '../../../domain/entities/nha_tro_entity.dart';
import '../../widgets/empty_data_widget.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/phong_card_widget.dart';
import 'widgets/them_nha_tro_dialog.dart';

class PhongScreen extends StatelessWidget {
  const PhongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PhongView();
  }
}

class _PhongView extends StatelessWidget {
  const _PhongView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhongBloc, PhongState>(
      buildWhen: (previous, current) =>
          current is PhongLoading ||
          current is PhongLoaded ||
          current is PhongError ||
          current is PhongInitial,
      builder: (context, state) {
        if (state is PhongLoading || state is PhongInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PhongError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state is PhongLoaded) {
          if (state.items.isEmpty) {
            return const EmptyDataWidget(
              icon: Icons.home_work_outlined,
              title: 'Chưa có nhà trọ nào',
              subtitle: 'Bấm + để thêm nhà trọ đầu tiên',
            );
          }
          return _PhongListView(items: state.items);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _PhongListView extends StatelessWidget {
  final List<NhaTroWithPhong> items;

  const _PhongListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _NhaTroSection(nhaTroWithPhong: items[index]);
      },
    );
  }
}

class _NhaTroSection extends StatelessWidget {
  final NhaTroWithPhong nhaTroWithPhong;

  const _NhaTroSection({required this.nhaTroWithPhong});

  @override
  Widget build(BuildContext context) {
    final nhaTro = nhaTroWithPhong.nhaTro;
    final phongList = nhaTroWithPhong.phongList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nhaTro.tenNhaTro,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      nhaTro.diaChi,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showThemNhaTroDialog(context, nhaTro: nhaTro),
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Sửa nhà trọ',
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteNhaTro(context, nhaTro),
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Theme.of(context).colorScheme.error,
                tooltip: 'Xóa nhà trọ',
              ),
              const SizedBox(width: 8),
              Text(
                '${phongList.length} phòng',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
        if (phongList.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 12),
            child: Text(
              'Chưa có phòng nào',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: phongList.length,
            itemBuilder: (context, index) {
              return PhongCardWidget(
                phong: phongList[index],
                onTap: () {
                  // TODO: Navigate to Room Details
                },
              );
            },
          ),
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  void _showThemNhaTroDialog(BuildContext context, {NhaTroEntity? nhaTro}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<PhongBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) => ThemNhaTroDialog(
            chuNhaId: nhaTro?.chuNhaId ?? '',
            initialNhaTro: nhaTro,
            scrollController: controller,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNhaTro(BuildContext context, NhaTroEntity nhaTro) {
    AppConfirmDialog.show(
      context: context,
      title: 'Xóa nhà trọ',
      content: 'Bạn có chắc chắn muốn xóa nhà trọ "${nhaTro.tenNhaTro}"? Hành động này sẽ XÓA TẤT CẢ các phòng thuộc nhà trọ này và không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
      confirmColor: Theme.of(context).colorScheme.error,
      onConfirm: () {
        context.read<PhongBloc>().add(XoaNhaTroRequested(nhaTro.id));
      },
    );
  }
}
