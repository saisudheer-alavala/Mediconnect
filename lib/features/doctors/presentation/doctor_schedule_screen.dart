import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state_view.dart';

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability Schedule'),
      ),
      body: EmptyStateView(
        icon: Icons.calendar_month_rounded,
        title: 'Weekly Slot Configuration',
        description: 'Set your operating days, consultation hours, and appointment durations.',
        actionText: 'Configure Hours',
        onAction: () {},
      ),
    );
  }
}
