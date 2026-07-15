import 'package:equatable/equatable.dart';
import '../../model/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final ProfileModel profile;
  final String message;

  const ProfileUpdated(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

class DocumentUploading extends ProfileState {
  final String documentType;

  const DocumentUploading(this.documentType);

  @override
  List<Object?> get props => [documentType];
}

class DocumentUploaded extends ProfileState {
  final String documentType;
  final String message;

  const DocumentUploaded(this.documentType, this.message);

  @override
  List<Object?> get props => [documentType, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
