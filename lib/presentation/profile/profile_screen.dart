import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/presentation/auth/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileTitle),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Header
              if (user != null)
                _buildProfileHeader(context, "${user.firstName} ${user.lastName}", user.email),

              const SizedBox(height: 24),
              const Divider(),

              // Log Out Button
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  strings.logout,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  // Pop all routes until the root and then sign out
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  context.read<AuthCubit>().signOut();
                },
              ),

              // Delete Account Button
              ListTile(
                leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                title: Text(
                  strings.deleteAccount,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _showDeleteConfirmationDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: theme.textTheme.displaySmall?.copyWith(color: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final strings = context.l10n;
    final confirmController = TextEditingController();
    final isButtonEnabled = ValueNotifier<bool>(false);
    void disposeResources() {
      confirmController.dispose();
      isButtonEnabled.dispose();
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ValueListenableBuilder<bool>(
          valueListenable: isButtonEnabled,
          builder: (context, isEnabled, child) {
            return AlertDialog(
              title: Text(strings.deleteAccount),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(strings.deleteAccountConfirmation),
                    const SizedBox(height: 16),
                    Text(strings.deleteAccountHint), // e.g., "Please type DELETE to confirm."
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: confirmController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: strings.deleteAccount, // "DELETE"
                      ),
                      onChanged: (value) {
                        isButtonEnabled.value = (value == strings.deleteAccount);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red, disabledBackgroundColor: Colors.red.withOpacity(0.4)),
                  onPressed: isEnabled ? () => context.read<AuthCubit>().deleteUser() : null,
                  child: Text(strings.delete),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => disposeResources());
  }
}