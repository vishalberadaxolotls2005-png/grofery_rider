import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'system_settings_event.dart';
import 'system_settings_state.dart';
import '../repo/system_settings_repo.dart';
import '../model/settings_repo.dart';

class SystemSettingsBloc
    extends Bloc<SystemSettingsEvent, SystemSettingsState> {
  final SystemSettingsRepo _repo;
  SettingsModel? _cachedSettings;

  SystemSettingsBloc(this._repo) : super(SystemSettingsInitial()) {
    on<FetchSystemSettings>(_onFetchSystemSettings);
    on<RefreshSystemSettings>(_onRefreshSystemSettings);
    on<FetchDeliveryBoySettings>(_onFetchDeliveryBoySettings);
  }

  Future<void> _onFetchSystemSettings(
    FetchSystemSettings event,
    Emitter<SystemSettingsState> emit,
  ) async {
    try {
      // If we have cached system_settings, emit them immediately
      if (_cachedSettings != null) {
        emit(SystemSettingsLoaded(_cachedSettings!));
        return;
      }

      emit(SystemSettingsLoading());

      final settings = await _repo.getSystemSettings();
      if (settings != null) {
        _cachedSettings = settings;

        emit(SystemSettingsLoaded(settings));
      } else {
        emit(SystemSettingsError('Failed to fetch system_settings'));
      }
    } catch (e) {
      if (kDebugMode) {}

      // If we have cached system_settings, use them even on error
      if (_cachedSettings != null) {
        emit(SystemSettingsLoaded(_cachedSettings!));
      } else {
        emit(SystemSettingsError('Failed to fetch system_settings'));
      }
    }
  }

  Future<void> _onRefreshSystemSettings(
    RefreshSystemSettings event,
    Emitter<SystemSettingsState> emit,
  ) async {
    try {
      emit(SystemSettingsLoading());

      final settings = await _repo.getSystemSettings();
      if (settings != null) {
        _cachedSettings = settings;
        emit(SystemSettingsLoaded(settings));
      } else {
        emit(SystemSettingsError('Failed to refresh system_settings'));
      }
    } catch (e) {
      if (kDebugMode) {}

      // Keep current system_settings on refresh error
      if (_cachedSettings != null) {
        emit(SystemSettingsLoaded(_cachedSettings!));
      } else {
        emit(SystemSettingsError('Failed to refresh system_settings'));
      }
    }
  }

  Future<void> _onFetchDeliveryBoySettings(
    FetchDeliveryBoySettings event,
    Emitter<SystemSettingsState> emit,
  ) async {
    try {
      emit(SystemSettingsLoading());

      final settings = await _repo.getDeliveryBoySettings();
      if (settings != null) {
        _cachedSettings = settings;
        emit(SystemSettingsLoaded(settings));
      } else {
        emit(
          SystemSettingsError('Failed to fetch delivery boy system_settings'),
        );
      }
    } catch (e) {
      if (kDebugMode) {}
      emit(SystemSettingsError('Failed to fetch delivery boy system_settings'));
    }
  }

  // Getter for current system_settings
  SettingsModel? get currentSettings => _cachedSettings;

  // Getter for currency symbol
  String get currencySymbol {
    // Temporarily remove fallback to see what's actually returned
    final symbol = _cachedSettings?.systemSettings?.value?.currencySymbol;

    // If symbol is null or empty, return a placeholder to avoid crashes
    if (symbol == null || symbol.isEmpty) {
      return '\$'; // Use Euro as placeholder since that's what the user expects
    }

    return symbol;
  }

  bool get isDemo => _cachedSettings?.systemSettings?.value?.demoMode ?? true;

  String get demoMessage =>
      _cachedSettings?.systemSettings?.value?.deliveryBoyDemoModeMessage ??
      "Some operations may not be allowed in the DEMO MODE.";

  // Getter for currency code
  String get currencyCode =>
      _cachedSettings?.systemSettings?.value?.currency ?? 'INR';
}
