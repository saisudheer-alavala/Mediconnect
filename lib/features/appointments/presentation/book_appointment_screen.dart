import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../doctors/data/doctor_repository.dart';
import '../../doctors/domain/doctor_model.dart';
import 'appointment_controller.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final DoctorModel doctor;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  late DateTime _selectedDate;
  DoctorSlotModel? _selectedSlot;
  final TextEditingController _notesController = TextEditingController();
  List<DoctorSlotModel> _slots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    // Default to tomorrow or today
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _fetchSlotsForDate(_selectedDate);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateYmd(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _selectedSlot = null;
    });

    final dateStr = _formatDateYmd(date);
    try {
      final repo = ref.read(doctorRepositoryProvider);
      final fetched = await repo.getAvailableSlots(widget.doctor.id, dateStr);
      if (mounted) {
        setState(() {
          _slots = fetched.isNotEmpty ? fetched : _generateDefaultSlots();
          _isLoadingSlots = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _slots = _generateDefaultSlots();
          _isLoadingSlots = false;
        });
      }
    }
  }

  List<DoctorSlotModel> _generateDefaultSlots() {
    final times = [
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
    ];
    return times.map((t) {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final endM = (m + 30) % 60;
      final endH = (m + 30) >= 60 ? h + 1 : h;
      final endStr = '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
      return DoctorSlotModel(
        startTime: t,
        endTime: endStr,
        isAvailable: true,
      );
    }).toList();
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available consultation slot.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = await ref.read(appointmentControllerProvider.notifier).bookAppointment(
          doctorId: widget.doctor.id,
          date: _selectedDate,
          startTime: _selectedSlot!.startTime,
          patientNotes: _notesController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      _showBookingSuccessModal();
    } else {
      final error = ref.read(appointmentControllerProvider).errorMessage ?? 'Failed to book appointment';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBookingSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 52),
            ),
            const SizedBox(height: 18),
            Text(
              'Appointment Confirmed!',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your consultation with ${widget.doctor.fullName} has been successfully scheduled.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _selectedSlot?.startTime ?? '',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.doctor.clinicName,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'View My Appointments',
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/patient/appointments');
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/patient');
              },
              child: Text(
                'Back to Home Dashboard',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Fee', style: AppTextStyles.bodySmall),
                  Text(
                    '\$${widget.doctor.consultationFee.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  key: const Key('confirm_booking_button'),
                  text: 'Confirm Booking',
                  isLoading: appointmentState.isBooking,
                  onPressed: _confirmBooking,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Summary Header Card
            _buildDoctorHeader(),
            const SizedBox(height: 20),

            // Select Date Section
            Text('Select Date', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 24),

            // Available Time Slots Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Slots', style: AppTextStyles.titleMedium),
                if (_selectedSlot != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Selected: ${_selectedSlot!.startTime}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSlotsGrid(),
            const SizedBox(height: 24),

            // Patient Notes / Symptoms Input
            CustomTextField(
              key: const Key('patient_notes_input'),
              controller: _notesController,
              labelText: 'Reason for Visit / Symptoms (Optional)',
              hintText: 'Describe symptoms or reasons for consultation...',
              maxLines: 3,
              prefixIcon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 24),

            // Consultation Booking Summary
            _buildBookingSummary(),
            const SizedBox(height: 20),

            // Healthcare Boundary / Informational Disclaimer
            _buildMedicalDisclaimer(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.doctor.fullName.split(' ').map((e) => e[0]).take(2).join(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.fullName,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.doctor.specializationName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.doctor.clinicName,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dates = List.generate(14, (index) {
      final d = now.add(Duration(days: index));
      return DateTime(d.year, d.month, d.day);
    });

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          return GestureDetector(
            key: Key('date_chip_${DateFormat('yyyy-MM-dd').format(date)}'),
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _fetchSlotsForDate(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM').format(date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? Colors.white70 : AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotsGrid() {
    if (_isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: LoadingIndicator(message: 'Checking schedule availability...')),
      );
    }

    if (_slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_busy_rounded, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No consultation slots available on this date. Please pick another date.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _slots.map((slot) {
        final isSelected = _selectedSlot?.startTime == slot.startTime;
        final isAvailable = slot.isAvailable;

        return GestureDetector(
          key: Key('slot_chip_${slot.startTime.replaceAll(':', '_')}'),
          onTap: isAvailable
              ? () {
                  setState(() {
                    _selectedSlot = slot;
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: !isAvailable
                  ? AppColors.inputBackground
                  : (isSelected ? AppColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !isAvailable
                    ? AppColors.borderLight
                    : (isSelected ? AppColors.primary : AppColors.borderLight),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: !isAvailable
                      ? AppColors.textMutedLight
                      : (isSelected ? Colors.white : AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  slot.startTime,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: !isAvailable
                        ? AppColors.textMutedLight
                        : (isSelected ? Colors.white : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingSummary() {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Consultation Overview', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: Icons.person_outline_rounded,
            title: 'Practitioner',
            value: widget.doctor.fullName,
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            icon: Icons.calendar_today_rounded,
            title: 'Date',
            value: formattedDate,
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            icon: Icons.access_time_rounded,
            title: 'Time Slot',
            value: _selectedSlot != null
                ? '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}'
                : 'Not selected',
            highlight: _selectedSlot != null,
          ),
          const Divider(height: 16),
          _buildSummaryRow(
            icon: Icons.local_hospital_outlined,
            title: 'Clinic',
            value: widget.doctor.clinicName,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.primary : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Informational Boundary: MediCare Connect facilitates appointment scheduling and medical adherence. It is not an emergency triage service. If you are experiencing acute medical emergencies, call your local emergency services immediately.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
