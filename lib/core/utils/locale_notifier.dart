import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple ValueNotifier to manage the app's current locale.
/// This allows the MaterialApp to reactively update its locale.
class LocaleNotifier extends ValueNotifier<Locale?> {

  LocaleNotifier(super.value);

  /// Sets a new locale and notifies listeners.
  Future<void> setLocale(Locale newLocale) async {
    final prefs = SharedPreferencesAsync();
    if (value == newLocale) return; // Don't do anything if the locale is the same
    value = newLocale;
    await prefs.setString('language', newLocale.languageCode);
    notifyListeners();
  }
}