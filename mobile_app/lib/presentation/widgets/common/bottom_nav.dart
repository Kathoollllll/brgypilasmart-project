import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Requests'),
    BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), activeIcon: Icon(Icons.track_changes), label: 'Tracker'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSub,
    selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 11),
    unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
    items: _items,
  );
}

// ─── Main Shell with bottom nav ───────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _routes = [
    AppRoutes.home,
    AppRoutes.requestCats,
    AppRoutes.tracker,
    AppRoutes.profile,
  ];

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    Navigator.pushReplacementNamed(context, _routes[i]);
  }

  @override
  Widget build(BuildContext context) => AppBottomNav(currentIndex: _index, onTap: _onTap);
}
