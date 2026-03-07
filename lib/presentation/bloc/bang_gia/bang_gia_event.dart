import 'package:equatable/equatable.dart';
import '../../../domain/entities/bang_gia_entity.dart';

abstract class BangGiaEvent extends Equatable {
  const BangGiaEvent();

  @override
  List<Object?> get props => [];
}

class BangGiaStarted extends BangGiaEvent {
  final String chuNhaId;

  const BangGiaStarted(this.chuNhaId);

  @override
  List<Object?> get props => [chuNhaId];
}

class ThemBangGiaRequested extends BangGiaEvent {
  final BangGiaEntity bangGia;

  const ThemBangGiaRequested(this.bangGia);

  @override
  List<Object?> get props => [bangGia];
}
