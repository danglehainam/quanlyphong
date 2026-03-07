import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CaiDatScreen extends StatelessWidget {
  const CaiDatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.settings,
            size: 64,
            color: AppColors.primary,
          ),
          SValues.gapH16,
          Text(
            'Màn hình Cài đặt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Tính năng này đang được phát triển',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Giả định có SValues. Nếu không có tôi sẽ hardcode margin
class SValues {
  static const gapH16 = SizedBox(height: 16);
}
