import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';

import '../auth/auth_cubit.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    // The AuthCubit is provided globally, so we can access it here.
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileTitle),
        backgroundColor: Colors.teal.shade800,
      ),
      body: user == null
          ? Center(child: Text(strings.noUserLoggedIn))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(user.name.isNotEmpty ? user.name : strings.noName),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: Text(user.email.isNotEmpty ? user.email : strings.noEmail),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}