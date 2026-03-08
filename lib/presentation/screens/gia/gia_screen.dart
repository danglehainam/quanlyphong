import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/dependency_Injection.dart';
import '../../../domain/entities/bang_gia_entity.dart';
import '../../bloc/bang_gia/bang_gia_bloc.dart';
import '../../bloc/bang_gia/bang_gia_event.dart';
import '../../bloc/bang_gia/bang_gia_state.dart';
import '../../widgets/app_bar_add_button.dart';
import '../../widgets/empty_data_widget.dart';
import '../../../core/utils/currency_format.dart';
import 'widgets/them_bang_gia_dialog.dart';

class GiaScreen extends StatelessWidget {
  final String chuNhaId;

  const GiaScreen({
    super.key,
    required this.chuNhaId,
  });

  void _showThemBangGiaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<BangGiaBloc>(),
        child: ThemBangGiaDialog(chuNhaId: chuNhaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<BangGiaBloc>()..add(BangGiaStarted(chuNhaId)),
      child: BlocBuilder<BangGiaBloc, BangGiaState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bảng giá'),
              actions: [
                AppBarAddButton(
                  tooltip: 'Thêm bảng giá',
                  onPressed: () => _showThemBangGiaDialog(context),
                ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BangGiaState state) {
    if (state is BangGiaLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BangGiaError) {
      return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: AppColors.error)));
    }

    if (state is BangGiaLoaded) {
      if (state.items.isEmpty) {
        return const EmptyDataWidget(
          icon: Icons.attach_money,
          title: 'Chưa có bảng giá nào',
          subtitle: 'Nhấn nút + ở góc trên để thêm bảng giá mới cho nhà trọ của bạn.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _buildBangGiaCard(item);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBangGiaCard(BangGiaEntity item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(item.tenBangGia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('Giá thuê: ${CurrencyFormat.format(item.giaThue)} VND/tháng', style: const TextStyle(color: AppColors.primary)),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.attach_money, color: Colors.white),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _buildInfoRow(Icons.electric_bolt, 'Điện:', '${CurrencyFormat.format(item.giaDien)} VND (${_getCachTinhText(item.cachTinhDien)})'),
          _buildInfoRow(Icons.water_drop, 'Nước:', '${CurrencyFormat.format(item.giaNuoc)} VND (${_getCachTinhText(item.cachTinhNuoc)})'),
          _buildInfoRow(Icons.wifi, 'Internet:', '${CurrencyFormat.format(item.giaInternet)} VND (${item.cachTinhInternet == 0 ? "phòng" : "người"})'),
          if (item.chiPhiKhac != null)
            _buildInfoRow(Icons.more_horiz, 'Khác:', '${CurrencyFormat.format(item.chiPhiKhac!)} VND (${item.ghiChu ?? "Không có ghi chú"})'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  String _getCachTinhText(int value) {
    switch (value) {
      case 0: return 'số';
      case 1: return 'người';
      case 2: return 'tự nhập';
      default: return '';
    }
  }
}
