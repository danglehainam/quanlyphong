import 'package:equatable/equatable.dart';

abstract class ApDungBangGiaEvent extends Equatable {
  const ApDungBangGiaEvent();

  @override
  List<Object?> get props => [];
}

class ApDungBangGiaStarted extends ApDungBangGiaEvent {
  final String chuNhaId;

  const ApDungBangGiaStarted(this.chuNhaId);

  @override
  List<Object?> get props => [chuNhaId];
}

class TogglePhongSelection extends ApDungBangGiaEvent {
  final String phongId;

  const TogglePhongSelection(this.phongId);

  @override
  List<Object?> get props => [phongId];
}

class SubmitApDungBangGia extends ApDungBangGiaEvent {
  final String bangGiaId;

  const SubmitApDungBangGia(this.bangGiaId);

  @override
  List<Object?> get props => [bangGiaId];
}
