import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/phong_entity.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_bloc.dart';
import '../../../bloc/ap_dung_bang_gia/ap_dung_bang_gia_state.dart';

class ChonPhongSelectionDialog extends StatefulWidget {
  final List<String> initialSelectedIds;

  const ChonPhongSelectionDialog({
    super.key,
    this.initialSelectedIds = const [],
  });

  @override
  State<ChonPhongSelectionDialog> createState() => _ChonPhongSelectionDialogState();
}

class _ChonPhongSelectionDialogState extends State<ChonPhongSelectionDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is ApDungBangGiaLoaded) {
                  return _buildList(state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Nút Xác nhận
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context, _selectedIds.toList());
                },
                child: Text(
                  'Xác nhận (${_selectedIds.length} phòng)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ApDungBangGiaLoaded state) {
    if (state.phongList.isEmpty) {
      return const Center(child: Text('Chưa có phòng nào.'));
    }

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
              final isSelected = _selectedIds.contains(phong.id);
              return CheckboxListTile(
                title: Text('Phòng ${phong.tenPhong}'),
                value: isSelected,
                activeColor: AppColors.primary,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(phong.id);
                    } else {
                      _selectedIds.remove(phong.id);
                    }
                  });
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
