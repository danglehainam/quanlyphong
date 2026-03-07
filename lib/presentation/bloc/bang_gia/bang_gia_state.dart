import 'package:equatable/equatable.dart';
import '../../../domain/entities/bang_gia_entity.dart';

abstract class BangGiaState extends Equatable {
  const BangGiaState();

  @override
  List<Object?> get props => [];
}

class BangGiaInitial extends BangGiaState {}

class BangGiaLoading extends BangGiaState {}

class BangGiaLoaded extends BangGiaState {
  final List<BangGiaEntity> items;

  const BangGiaLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class BangGiaError extends BangGiaState {
  final String message;

  const BangGiaError(this.message);

  @override
  List<Object?> get props => [message];
}

class ThemBangGiaLoading extends BangGiaState {}

class ThemBangGiaSuccess extends BangGiaState {}

class ThemBangGiaFailure extends BangGiaState {
  final String message;

  const ThemBangGiaFailure(this.message);

  @override
  List<Object?> get props => [message];
}
