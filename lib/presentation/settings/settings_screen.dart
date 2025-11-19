import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/app_localizations.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/presentation/profile/profile_screen.dart';
import 'package:suefery_partner/presentation/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
      final settingsCubit = context.read<SettingsCubit>();
      return Scaffold(
        appBar: AppBar(
          title: Text(strings.settingsTitle),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(strings.profileTitle), // Add 'profileTitle' to localizations
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(strings.changeLanguage),
              subtitle: Text(strings.currentLanguage(state.locale.languageCode)),
              onTap: () => _showLanguagePickerDialog(context, settingsCubit),
            ),
            SwitchListTile(
              title: Text(strings.darkMode),
              value: state.themeMode == ThemeMode.dark,
              onChanged: (isDark) => settingsCubit.toggleTheme(),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            // // Assuming AppTheme is an enum you have defined elsewhere
            // // You can map over its values to create the radio buttons
            // ...AppTheme.values.map((theme) {
            //   return RadioListTile<AppTheme>(
            //     value: theme,
            //     groupValue: state.appTheme,
            //     onChanged: (newTheme) => settingsCubit.changeTheme(newTheme!),
            //     title: Text(theme.name), // You can create a getter for a more user-friendly name
            //     subtitle: Text('A theme description'), // Add to localizations
            //   );
            // }),
          ],
        ),
      );
    });
  }

  void _showLanguagePickerDialog(
      BuildContext context, SettingsCubit settingsCubit) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(l10n.selectLanguage),
          children: AppLocalizations.supportedLocales.map((locale) {
            return SimpleDialogOption(
              onPressed: () {
                settingsCubit.setLocale(locale);
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                locale.languageCode == 'en' ? 'English' : 'العربية',
                style: TextStyle(
                  fontWeight: settingsCubit.state.locale == locale
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: settingsCubit.state.locale == locale
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}