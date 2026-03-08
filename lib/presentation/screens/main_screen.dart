import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/phong/phong_bloc.dart';
import 'phong/phong_screen.dart';
import 'gia/gia_screen.dart';
import 'hoa_don/hoa_don_screen.dart';
import 'nguoi_thue/nguoi_thue_screen.dart';
import 'cai_dat/cai_dat_screen.dart'; // Added this import
import '../widgets/app_bar_add_button.dart';
import 'phong/widgets/them_nha_tro_dialog.dart';
import 'nguoi_thue/widgets/them_nguoi_thue_dialog.dart';
import '../bloc/nguoi_thue/nguoi_thue_bloc.dart';
import '../../core/constants/app_colors.dart';

class MainScreen extends StatefulWidget {
  final UserEntity user;

  const MainScreen({
    super.key, 
    required this.user,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PhongScreen(),
    const HoaDonScreen(),
    const NguoiThueScreen(),
  ];

  final List<String> _titles = const [
    'Phòng',
    'Hóa đơn',
    'Người thuê',
  ];

  void _handleLogOut(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  void _showThemNhaTroDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<PhongBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) => ThemNhaTroDialog(
            chuNhaId: widget.user.uid,
          ),
        ),
      ),
    );
  }

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
            chuNhaId: widget.user.uid,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // Nút + chỉ hiện khi đang ở tab Phòng
          if (_currentIndex == 0)
            AppBarAddButton(
              tooltip: 'Thêm nhà trọ',
              onPressed: () => _showThemNhaTroDialog(context),
            ),
          if (_currentIndex == 2)
            AppBarAddButton(
              tooltip: 'Thêm người thuê',
              onPressed: () => _showThemNguoiThueDialog(context),
            ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _handleLogOut(context),
                tooltip: 'Đăng xuất',
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.displayName ?? 'Người dùng mới'),
              accountEmail: Text(widget.user.email ?? 'Không có email'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: widget.user.photoUrl != null
                    ? NetworkImage(widget.user.photoUrl!)
                    : null,
                child: widget.user.photoUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Bảng giá'),
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GiaScreen(chuNhaId: widget.user.uid)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaiDatScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Đăng xuất',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _handleLogOut(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Phòng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Hóa đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người thuê',
          ),
        ],
      ),
    );
  }
}
