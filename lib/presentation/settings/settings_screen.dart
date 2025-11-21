import 'package:flutter/material.dart';
import 'package:suefery_partner/core/l10n/app_localizations.dart';
import 'package:suefery_partner/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings!.settingsTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(strings.changeLanguage),
            subtitle: Text(strings.currentLanguage(localeNotifier.value?.languageCode ?? 'en')),
            onTap: () {
              _showLanguageDialog(context, strings);
            },
          ),
          // Add more settings options here (e.g., theme, notifications)
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations? strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings!.selectLanguage),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: AppLocalizations.supportedLocales.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final locale = AppLocalizations.supportedLocales[index];
                return ListTile(
                  title: Text(locale.languageCode),
                  onTap: () {
                    localeNotifier.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(strings.cancel),
            ),
          ],
        );
      },
    );
  }
}