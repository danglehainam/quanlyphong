import 'package:flutter/material.dart';
import '../../domain/entities/phong_entity.dart';
import '../../core/constants/app_colors.dart';

class PhongCardWidget extends StatelessWidget {
  final PhongEntity phong;
  final VoidCallback onTap;

  const PhongCardWidget({
    super.key,
    required this.phong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phong.trangThai) {
      PhongTrangThai.trong => ('Trống', AppColors.phongTrong),
      PhongTrangThai.daThue => ('Đã thuê', AppColors.phongDaThue),
      PhongTrangThai.baoTri => ('Bảo trì', AppColors.phongBaoTri),
      PhongTrangThai.chuaThanhToan => ('Nợ tiền', AppColors.phongChuaThanhToan),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.door_front_door, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              phong.tenPhong,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
