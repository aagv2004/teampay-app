import 'package:flutter/material.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../expenses/screens/add_expense_screen.dart';
import '../../groups/screens/groups_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    GroupsScreen(),
    AddExpenseScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
