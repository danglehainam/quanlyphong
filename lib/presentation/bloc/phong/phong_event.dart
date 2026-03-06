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
