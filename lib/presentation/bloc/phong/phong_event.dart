import 'package:equatable/equatable.dart';

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
