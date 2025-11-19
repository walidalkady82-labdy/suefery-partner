import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/utils/themes.dart';

/// Represents the available app themes.
/// Currently, we only have one light theme.
enum AppTheme {
  light,dark;

  ThemeData get themeData {
    switch (this) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return daskTheme;
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
}