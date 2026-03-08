import 'package:equatable/equatable.dart';
import '../../../domain/entities/nguoi_thue_entity.dart';

abstract class NguoiThueState extends Equatable {
  const NguoiThueState();

  @override
  List<Object?> get props => [];
}

class NguoiThueInitial extends NguoiThueState {}

class NguoiThueLoading extends NguoiThueState {}

class NguoiThueLoaded extends NguoiThueState {
  final List<NguoiThueEntity> items;

  const NguoiThueLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class NguoiThueError extends NguoiThueState {
  final String message;

  const NguoiThueError(this.message);

  @override
  List<Object?> get props => [message];
}

class NguoiThueActionLoading extends NguoiThueState {}

class NguoiThueActionSuccess extends NguoiThueState {}

class NguoiThueActionFailure extends NguoiThueState {
  final String message;

  const NguoiThueActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
