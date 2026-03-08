import 'package:equatable/equatable.dart';
import '../../../domain/entities/nha_tro_entity.dart';
import '../../../domain/entities/phong_entity.dart';

abstract class ApDungBangGiaState extends Equatable {
  const ApDungBangGiaState();

  @override
  List<Object?> get props => [];
}

class ApDungBangGiaLoading extends ApDungBangGiaState {}

class ApDungBangGiaLoaded extends ApDungBangGiaState {
  final List<NhaTroEntity> nhaTroList;
  final List<PhongEntity> phongList;
  final Set<String> selectedPhongIds; // Các ID phòng được tick chọn

  const ApDungBangGiaLoaded({
    required this.nhaTroList,
    required this.phongList,
    this.selectedPhongIds = const {},
  });

  ApDungBangGiaLoaded copyWith({
    List<NhaTroEntity>? nhaTroList,
    List<PhongEntity>? phongList,
    Set<String>? selectedPhongIds,
  }) {
    return ApDungBangGiaLoaded(
      nhaTroList: nhaTroList ?? this.nhaTroList,
      phongList: phongList ?? this.phongList,
      selectedPhongIds: selectedPhongIds ?? this.selectedPhongIds,
    );
  }

  @override
  List<Object?> get props => [nhaTroList, phongList, selectedPhongIds];
}

class ApDungBangGiaSubmitting extends ApDungBangGiaState {}

class ApDungBangGiaSuccess extends ApDungBangGiaState {}

class ApDungBangGiaFailure extends ApDungBangGiaState {
  final String message;

  const ApDungBangGiaFailure(this.message);

  @override
  List<Object?> get props => [message];
}
