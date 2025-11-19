import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/utils/themes.dart';

/// Represents the available app themes.
/// Currently, we only have one light theme.
enum AppTheme {
  light, dark;

  ThemeData get themeData {
    switch (this) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return darkTheme;
    }
  }
}

/// The state for the SettingsCubit, holding the current theme mode and locale.
class SettingsState {
  final ThemeMode themeMode;
  final AppTheme appTheme;
  final Locale locale;

  SettingsState({
    this.themeMode = ThemeMode.light,
    this.appTheme = AppTheme.light, // Default to the orange light theme
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppTheme? appTheme,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      appTheme: appTheme ?? this.appTheme,
      locale: locale ?? this.locale,
    );
  }
}

/// Cubit to manage application settings like theme and locale.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState());

  /// Toggles the application theme between light and dark mode.
  void toggleTheme() {
    final newThemeMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(
      themeMode: newThemeMode,
      appTheme: newThemeMode == ThemeMode.dark ? AppTheme.dark : AppTheme.light,
    ));
  }

  /// Sets the application's locale.
  void setLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}