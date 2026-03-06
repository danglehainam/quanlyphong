import 'package:equatable/equatable.dart';
import '../../../domain/entities/nha_tro_entity.dart';
import '../../../domain/entities/phong_entity.dart';

class NhaTroWithPhong {
  final NhaTroEntity nhaTro;
  final List<PhongEntity> phongList;

  const NhaTroWithPhong({required this.nhaTro, required this.phongList});
}

abstract class PhongState extends Equatable {
  const PhongState();

  @override
  List<Object?> get props => [];
}

class PhongInitial extends PhongState {}

class PhongLoading extends PhongState {}

class PhongLoaded extends PhongState {
  final List<NhaTroWithPhong> items;

  const PhongLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class PhongError extends PhongState {
  final String message;

  const PhongError(this.message);

  @override
  List<Object?> get props => [message];
}
