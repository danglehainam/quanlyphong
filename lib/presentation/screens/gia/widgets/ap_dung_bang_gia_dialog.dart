import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/phong_entity.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_bloc.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_event.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_state.dart';
import '../../../widgets/app_snackbar.dart';

class ApDungBangGiaDialog extends StatelessWidget {
  final String bangGiaId;

  const ApDungBangGiaDialog({
    super.key,
    required this.bangGiaId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApDungBangGiaBloc, ApDungBangGiaState>(
      listener: (context, state) {
        if (state is ApDungBangGiaSuccess) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(context, 'Đã áp dụng bảng giá cho các phòng đã chọn');
        } else if (state is ApDungBangGiaFailure) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn phòng áp dụng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Danh sách phòng
            Flexible(
              child: BlocBuilder<ApDungBangGiaBloc, ApDungBangGiaState>(
                builder: (context, state) {
                  if (state is ApDungBangGiaLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is ApDungBangGiaLoaded || state is ApDungBangGiaSubmitting) {
                    // State handled correctly by buildWhen and bloc reads.
                  }
                  
                  return _buildMainContent(context, state);
                },
                buildWhen: (previous, current) {
                  // Only rebuild when loaded or error, ignore submitting to keep the list visible
                  return current is ApDungBangGiaLoaded || current is ApDungBangGiaLoading || current is ApDungBangGiaFailure;
                },
              ),
            ),

            // Nút Lưu
            BlocBuilder<ApDungBangGiaBloc, ApDungBangGiaState>(
              builder: (context, state) {
                final isSubmitting = state is ApDungBangGiaSubmitting;
                
                // Get selected count if loaded
                int selectedCount = 0;
                if (state is ApDungBangGiaLoaded) selectedCount = state.selectedPhongIds.length;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting || selectedCount == 0
                          ? null
                          : () {
                              context.read<ApDungBangGiaBloc>().add(SubmitApDungBangGia(bangGiaId));
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Áp dụng cho $selectedCount phòng',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ApDungBangGiaState state) {
    if (state is! ApDungBangGiaLoaded) return const SizedBox.shrink();

    if (state.phongList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Chưa có phòng nào. Vùi lòng tạo phòng trước.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Group phòng by nhaTro
    final map = <String, List<PhongEntity>>{};
    for (final phong in state.phongList) {
      map.putIfAbsent(phong.nhaTroId, () => []).add(phong);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.nhaTroList.length,
      itemBuilder: (context, index) {
        final nhaTro = state.nhaTroList[index];
        final phongOfNhaTro = map[nhaTro.id] ?? [];

        if (phongOfNhaTro.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                nhaTro.tenNhaTro,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
            ),
            ...phongOfNhaTro.map((phong) {
              final isSelected = state.selectedPhongIds.contains(phong.id);
              final isUsingThisBangGia = phong.bangGiaId == bangGiaId;

              return CheckboxListTile(
                title: Row(
                  children: [
                    Text('Phòng ${phong.tenPhong}'),
                    if (isUsingThisBangGia)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Đang áp dụng',
                          style: TextStyle(fontSize: 10, color: AppColors.success),
                        ),
                      )
                  ],
                ),
                value: isSelected,
                activeColor: AppColors.primary,
                onChanged: (bool? value) {
                  context.read<ApDungBangGiaBloc>().add(TogglePhongSelection(phong.id));
                },
              );
            }),
            const Divider(),
          ],
        );
      },
    );
  }
}
