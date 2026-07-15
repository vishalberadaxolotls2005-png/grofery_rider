import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/profile_repo.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileBloc(this._profileRepo) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepo.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      // Add settings detailed error logging

      if (e.toString().contains('toDouble') ||
          e.toString().contains('NoSuchMethodError')) {
        emit(ProfileError('Data format error: Please contact support'));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {


      emit(ProfileUpdating());

      final profile = await _profileRepo.updateProfile(
        fullName: event.fullName,
        address: event.address,
        driverLicenseNumber: event.driverLicenseNumber,
        vehicleType: event.vehicleType,
        mobile: event.mobile,
        email: event.email,
        country: event.country,
        driverLicenseFiles: event.driverLicenseFiles,
        vehicleRegistrationFiles: event.vehicleRegistrationFiles,
        profileImageFile: event.profileImageFile,
      );


      emit(ProfileUpdated(profile, 'Profile updated successfully'));
    } catch (e) {

      if (e.toString().contains('toDouble') ||
          e.toString().contains('NoSuchMethodError')) {
        emit(ProfileError('Data format error: Please contact support'));
      } else {
        emit(ProfileError(e.toString()));
      }
    }
  }
}
