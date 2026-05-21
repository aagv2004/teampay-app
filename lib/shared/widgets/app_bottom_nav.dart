import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Grupo'),
        NavigationDestination(
          icon: Icon(Icons.add_card_rounded),
          label: 'Gastos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
