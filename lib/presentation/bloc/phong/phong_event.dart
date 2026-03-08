import 'package:equatable/equatable.dart';
import '../../../domain/entities/nha_tro_entity.dart';

abstract class PhongEvent extends Equatable {
  const PhongEvent();

  @override
  List<Object?> get props => [];
}

class PhongStarted extends PhongEvent {
  final String chuNhaId;

  const PhongStarted(this.chuNhaId);

  @override
  List<Object?> get props => [chuNhaId];
}

class ThemNhaTroRequested extends PhongEvent {
  final String tenNhaTro;
  final String diaChi;
  final int soLuongPhong;
  final String chuNhaId;

  const ThemNhaTroRequested({
    required this.tenNhaTro,
    required this.diaChi,
    required this.soLuongPhong,
    required this.chuNhaId,
  });

  @override
  List<Object?> get props => [tenNhaTro, diaChi, soLuongPhong, chuNhaId];
}

class UpdateNhaTroRequested extends PhongEvent {
  final NhaTroEntity nhaTro;

  const UpdateNhaTroRequested(this.nhaTro);

  @override
  List<Object?> get props => [nhaTro];
}

class XoaNhaTroRequested extends PhongEvent {
  final String nhaTroId;

  const XoaNhaTroRequested(this.nhaTroId);

  @override
  List<Object?> get props => [nhaTroId];
}
