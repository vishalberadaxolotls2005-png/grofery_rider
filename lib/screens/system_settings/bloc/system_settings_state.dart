import 'package:equatable/equatable.dart';
import '../model/settings_repo.dart';

abstract class SystemSettingsState extends Equatable {
  const SystemSettingsState();

  @override
  List<Object?> get props => [];
}

class SystemSettingsInitial extends SystemSettingsState {}

class SystemSettingsLoading extends SystemSettingsState {}

class SystemSettingsLoaded extends SystemSettingsState {
  final SettingsModel settings;

  const SystemSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SystemSettingsError extends SystemSettingsState {
  final String message;

  const SystemSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
