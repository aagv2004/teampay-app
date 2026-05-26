import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/features/groups/providers/group_provider.dart';

import '../../home/screens/main_navigation_screen.dart';
import '../screens/login_screen.dart';

/// Decide que pantalla mostrar segun si hay usuario logueado.
/// Tambien conecta el GroupProvider con el usuario actual.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        final groupProvider = context.read<GroupProvider>();

        if (user != null) {
          groupProvider.bindUser(
            userId: user.uid,
            displayName: user.displayName,
            email: user.email,
          );
          return const MainNavigationScreen();
        }

        groupProvider.clearUser();
        return const LoginScreen();
      },
    );
  }
}

/// Pantalla corta mientras Firebase confirma la sesion.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
