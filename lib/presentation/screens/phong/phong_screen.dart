import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/watch_nha_tro_list.dart';
import '../../../domain/usecases/watch_phong_list.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/phong/phong_bloc.dart';
import '../../bloc/phong/phong_event.dart';
import '../../bloc/phong/phong_state.dart';
import '../../../domain/entities/phong_entity.dart';
import '../../widgets/empty_data_widget.dart';
import '../../widgets/status_badge.dart';

class PhongScreen extends StatelessWidget {
  final WatchNhaTroListUseCase watchNhaTroList;
  final WatchPhongListUseCase watchPhongList;

  const PhongScreen({
    super.key,
    required this.watchNhaTroList,
    required this.watchPhongList,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => PhongBloc(
        watchNhaTroList: watchNhaTroList,
        watchPhongList: watchPhongList,
      )..add(PhongStarted(authState.user.uid)),
      child: const _PhongView(),
    );
  }
}

class _PhongView extends StatelessWidget {
  const _PhongView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhongBloc, PhongState>(
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
                child: Text(
                  nhaTro.tenNhaTro,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
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
          ...phongList.map((phong) => _PhongCard(phong: phong)),
        const Divider(),
      ],
    );
  }
}

class _PhongCard extends StatelessWidget {
  final PhongEntity phong;

  const _PhongCard({required this.phong});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phong.trangThai) {
      PhongTrangThai.trong => ('Trống', Colors.green),
      PhongTrangThai.daThue => ('Đã thuê', Colors.blue),
      PhongTrangThai.baoTri => ('Bảo trì', Colors.orange),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.door_front_door_outlined, color: color),
        ),
        title: Text(phong.tenPhong),
        subtitle: phong.moTa != null ? Text(phong.moTa!) : null,
        trailing: StatusBadge(
          label: label,
          color: color,
        ),
      ),
    );
  }
}
