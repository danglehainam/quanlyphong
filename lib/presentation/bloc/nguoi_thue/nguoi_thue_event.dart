import 'package:equatable/equatable.dart';
import '../../../domain/entities/nguoi_thue_entity.dart';

abstract class NguoiThueEvent extends Equatable {
  const NguoiThueEvent();

  @override
  List<Object?> get props => [];
}

class NguoiThueStarted extends NguoiThueEvent {
  final String chuNhaId;

  const NguoiThueStarted(this.chuNhaId);

  @override
  List<Object?> get props => [chuNhaId];
}

class ThemNguoiThueRequested extends NguoiThueEvent {
  final NguoiThueEntity nguoiThue;
  final String? phongId;

  const ThemNguoiThueRequested(
    this.nguoiThue, {
    this.phongId,
  });

  @override
  List<Object?> get props => [nguoiThue, phongId];
}

class UpdateNguoiThueRequested extends NguoiThueEvent {
  final NguoiThueEntity nguoiThue;
  final String? newPhongId;

  const UpdateNguoiThueRequested(
    this.nguoiThue, {
    this.newPhongId,
  });

  @override
  List<Object?> get props => [nguoiThue, newPhongId];
}

class XoaNguoiThueRequested extends NguoiThueEvent {
  final String nguoiThueId;
  final String? currentPhongId;

  const XoaNguoiThueRequested(this.nguoiThueId, {this.currentPhongId});

  @override
  List<Object?> get props => [nguoiThueId, currentPhongId];
}

class XoaKhachThuKhoiPhongRequested extends NguoiThueEvent {
  final NguoiThueEntity nguoiThue;
  final String phongId;

  const XoaKhachThuKhoiPhongRequested(this.nguoiThue, this.phongId);

  @override
  List<Object?> get props => [nguoiThue, phongId];
}
