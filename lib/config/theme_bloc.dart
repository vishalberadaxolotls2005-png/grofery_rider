import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'constant.dart';

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class SetTheme extends ThemeEvent {
  final String theme;
  SetTheme(this.theme);
}

abstract class ThemeState {
  final String currentTheme;
  const ThemeState(this.currentTheme);
}

class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(defaultTheme);
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded(super.theme);
}

class ThemeChanged extends ThemeState {
  const ThemeChanged(super.theme);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeBoxName = 'theme_box';
  static const String _themeKey = 'selected_theme';

  ThemeBloc() : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      if (Hive.isBoxOpen(_themeBoxName)) {
        final box = Hive.box(_themeBoxName);
        final savedTheme = box.get(_themeKey, defaultValue: defaultTheme);

        emit(ThemeLoaded(savedTheme));
      } else {
        final box = await Hive.openBox(_themeBoxName);
        final savedTheme = box.get(_themeKey, defaultValue: defaultTheme);

        emit(ThemeLoaded(savedTheme));
      }
    } catch (e) {
      emit(ThemeLoaded(defaultTheme));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final newTheme = state.currentTheme == 'light' ? 'dark' : 'light';
    await _saveTheme(newTheme);
    emit(ThemeChanged(newTheme));
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<ThemeState> emit) async {
    await _saveTheme(event.theme);

    emit(ThemeChanged(event.theme));
  }

  Future<void> _saveTheme(String theme) async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(_themeKey, theme);
    // ignore: empty_catches
    } catch (e) {}
  }

  bool get isDarkMode => state.currentTheme == 'dark';
}
