import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/features/groups/providers/group_provider.dart';

import '../../home/screens/main_navigation_screen.dart';
import '../screens/login_screen.dart';

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
          groupProvider.bindUser(user.uid);
          return const MainNavigationScreen();
        }

        groupProvider.clearUser();
        return const LoginScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
