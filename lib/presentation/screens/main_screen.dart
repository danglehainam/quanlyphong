import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'phong/phong_screen.dart';
import 'gia/gia_screen.dart';
import 'hoa_don/hoa_don_screen.dart';
import 'nguoi_thue/nguoi_thue_screen.dart';
import '../../domain/usecases/watch_nha_tro_list.dart';
import '../../domain/usecases/watch_phong_list.dart';
import '../../domain/usecases/them_nha_tro.dart';
import '../widgets/app_bar_add_button.dart';
import 'phong/widgets/them_nha_tro_dialog.dart';
import '../../core/constants/app_colors.dart';

class MainScreen extends StatefulWidget {
  final UserEntity user;
  final WatchNhaTroListUseCase watchNhaTroList;
  final WatchPhongListUseCase watchPhongList;
  final ThemNhaTroUseCase themNhaTroUseCase;

  const MainScreen({
    super.key, 
    required this.user,
    required this.watchNhaTroList,
    required this.watchPhongList,
    required this.themNhaTroUseCase,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    PhongScreen(
      watchNhaTroList: widget.watchNhaTroList,
      watchPhongList: widget.watchPhongList,
    ),
    const GiaScreen(),
    const HoaDonScreen(),
    const NguoiThueScreen(),
  ];

  final List<String> _titles = const [
    'Phòng',
    'Giá',
    'Hóa đơn',
    'Người thuê',
  ];

  void _handleLogOut(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  void _showThemNhaTroDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ThemNhaTroDialog(
        themNhaTroUseCase: widget.themNhaTroUseCase,
        chuNhaId: widget.user.uid,
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
              leading: const Icon(Icons.meeting_room),
              title: const Text('Phòng'),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Giá'),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Hóa đơn'),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Người thuê'),
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
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
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Phòng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Giá',
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
