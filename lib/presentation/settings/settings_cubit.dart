import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/utils/themes.dart';
import 'package:suefery_partner/data/services/logging_service.dart';
import 'package:suefery_partner/data/services/pref_service.dart';
import 'package:suefery_partner/locator.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final AppTheme appTheme;
  final Locale locale;

  const SettingsState({
    required this.themeMode,
    required this.appTheme,
    required this.locale,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      themeMode: ThemeMode.light,
      appTheme: AppTheme.oceanBlue,
      locale: Locale('en'),
    );
  }

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

  @override
  List<Object> get props => [themeMode, appTheme, locale];
}

/// An enum representing the available application themes.
enum AppTheme {
  /// The Ocean Blue theme.
  oceanBlue,

  /// The Sunset Orange theme.
  sunsetOrange,
}

/// Extension to convert theme to readable format
extension AppThemeExtension on AppTheme {
  String get name {
    switch (this) {
      case AppTheme.oceanBlue:
        return 'Ocean Blue';
      case AppTheme.sunsetOrange:
        return 'Sunset Orange';
    }
  }

  ThemeData get themeData {
    switch (this) {
      case AppTheme.oceanBlue:
        return oceanBlueTheme;
      case AppTheme.sunsetOrange:
        return sunsetOrangeTheme;
    }
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final PrefService _prefService = sl<PrefService>();
  final _log = LoggerRepo('SettingsCubit');

  SettingsCubit() : super(SettingsState.initial());

  /// Loads the user's saved settings from preferences.
  void loadSettings() {
    _log.i('Loading user settings...');
    final isDark = _prefService.isDarkTheme;
    final theme = _prefService.theme;
    final langCode = _prefService.language;

    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      appTheme: theme == 'sunsetOrange' ? AppTheme.sunsetOrange: AppTheme.oceanBlue,
      locale: Locale(langCode),
    ));
  }

  /// Sets a new locale and persists it.
  void setLocale(Locale newLocale) {
    if (state.locale == newLocale) return;

    _prefService.setlanguage(newLocale.languageCode);
    emit(state.copyWith(locale: newLocale));
  }

  /// Changes the application theme and persists the choice.
  void changeTheme(AppTheme theme) {
    if (state.appTheme == theme) return;

    _log.i('Changing theme to ${theme.name}');
    _prefService.setTheme(theme.name);
    emit(state.copyWith(appTheme: theme));
  }

  /// Toggles dark mode and persists the choice.
  void toggleDarkMode(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefService.setThemeDark(isDark);
    emit(state.copyWith(themeMode: newMode));
  }
}