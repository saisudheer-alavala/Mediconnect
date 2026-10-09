import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class PatientMainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientMainLayout({
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
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services_rounded, color: AppColors.primary),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication_rounded, color: AppColors.primary),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
