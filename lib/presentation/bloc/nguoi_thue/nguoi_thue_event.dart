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

  const ThemNguoiThueRequested(this.nguoiThue);

  @override
  List<Object?> get props => [nguoiThue];
}

class UpdateNguoiThueRequested extends NguoiThueEvent {
  final NguoiThueEntity nguoiThue;

  const UpdateNguoiThueRequested(this.nguoiThue);

  @override
  List<Object?> get props => [nguoiThue];
}

class XoaNguoiThueRequested extends NguoiThueEvent {
  final String nguoiThueId;

  const XoaNguoiThueRequested(this.nguoiThueId);

  @override
  List<Object?> get props => [nguoiThueId];
}
