import 'package:equatable/equatable.dart';
import 'package:mobile_flutter_iot/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final UserModel updatedUser;

  const ProfileUpdateRequested(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class ProfileDeleteAccountRequested extends ProfileEvent {}

class ProfileToggleNotifications extends ProfileEvent {
  final bool value;
  const ProfileToggleNotifications(this.value);
  @override
  List<Object?> get props => [value];
}

class ProfileToggleDarkMode extends ProfileEvent {
  final bool value;
  const ProfileToggleDarkMode(this.value);
  @override
  List<Object?> get props => [value];
}

class ProfileUpdateFieldRequested extends ProfileEvent {
  final String fieldTitle;
  final String newValue;
  const ProfileUpdateFieldRequested(this.fieldTitle, this.newValue);
  @override
  List<Object?> get props => [fieldTitle, newValue];
}
