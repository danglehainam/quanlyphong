import 'package:equatable/equatable.dart';

class NguoiThueEntity extends Equatable {
  final String id;
  final String hoTen;
  final String soDienThoai;
  final String? cccd;
  final DateTime? ngaySinh;
  final String? queQuan;
  final List<String> anhCCCD;
  final String chuNhaId;
  final DateTime? createdAt;
  final String? phongId;

  const NguoiThueEntity({
    required this.id,
    required this.hoTen,
    required this.soDienThoai,
    this.cccd,
    this.ngaySinh,
    this.queQuan,
    this.anhCCCD = const [],
    required this.chuNhaId,
    this.createdAt,
    this.phongId,
  });

  @override
  List<Object?> get props => [
        id,
        hoTen,
        soDienThoai,
        cccd,
        ngaySinh,
        queQuan,
        anhCCCD,
        chuNhaId,
        createdAt,
        phongId,
      ];

  NguoiThueEntity copyWith({
    String? id,
    String? hoTen,
    String? soDienThoai,
    String? cccd,
    DateTime? ngaySinh,
    String? queQuan,
    List<String>? anhCCCD,
    String? chuNhaId,
    DateTime? createdAt,
    String? phongId,
  }) {
    return NguoiThueEntity(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      cccd: cccd ?? this.cccd,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      queQuan: queQuan ?? this.queQuan,
      anhCCCD: anhCCCD ?? this.anhCCCD,
      chuNhaId: chuNhaId ?? this.chuNhaId,
      createdAt: createdAt ?? this.createdAt,
      phongId: phongId ?? this.phongId,
    );
  }
}
