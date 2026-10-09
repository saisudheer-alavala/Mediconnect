import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class DoctorMainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorMainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        indicatorColor: AppColors.secondaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.secondary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded, color: AppColors.secondary),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded, color: AppColors.secondary),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.secondary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
