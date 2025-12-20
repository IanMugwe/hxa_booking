import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../data/repositories/appointment_repo.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  const BookingScreen({required this.doctor, super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedDate;
  String? _selectedTime;
  final _reasonCtrl = TextEditingController();
  final _repo = AppointmentRepository();
  bool _saving = false;

  /// Generate hourly time slots between start and end time
  List<String> _generateTimeSlots(List<String> timeRange) {
    if (timeRange.length < 2) return [];

    final startTime = timeRange[0]; // e.g., "09:00"
    final endTime = timeRange[1]; // e.g., "17:00"

    final startHour = int.parse(startTime.split(':')[0]);
    final endHour = int.parse(endTime.split(':')[0]);

    final slots = <String>[];
    for (int h = startHour; h < endHour; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
    }
    return slots;
  }

  @override
  void initState() {
    super.initState();
    if (widget.doctor.availability.isNotEmpty) {
      _selectedDate = widget.doctor.availability.keys.first;
      final timeRange = widget.doctor.availability[_selectedDate!];
      if (timeRange != null) {
        final slots = _generateTimeSlots(timeRange);
        _selectedTime = slots.isNotEmpty ? slots.first : null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final timeRange = _selectedDate == null
        ? <String>[]
        : widget.doctor.availability[_selectedDate!] ?? [];
    final times = _generateTimeSlots(timeRange);

    // Split times into morning and evening
    final morningTimes = times
        .where((t) => int.parse(t.split(':')[0]) < 12)
        .toList();
    final eveningTimes = times
        .where((t) => int.parse(t.split(':')[0]) >= 12)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor\'s Details'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctor.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.doctor.specialization,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Fee',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${widget.doctor.currency}${widget.doctor.fee.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[700],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Date Selection
              Text(
                'Select a Time Slot',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.doctor.availability.length,
                  itemBuilder: (ctx, i) {
                    final date = widget.doctor.availability.keys.elementAt(i);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(date),
                        selected: _selectedDate == date,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDate = date;
                            final range =
                                widget.doctor.availability[date] ?? [];
                            final slots = _generateTimeSlots(range);
                            _selectedTime = slots.isNotEmpty
                                ? slots.first
                                : null;
                          });
                        },
                        selectedColor: Colors.amber,
                        labelStyle: TextStyle(
                          color: _selectedDate == date
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Time Selection with Morning/Evening sections
              if (morningTimes.isNotEmpty) ...[
                Text(
                  'Morning',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: morningTimes.map((t) {
                    return ChoiceChip(
                      label: Text(t),
                      selected: _selectedTime == t,
                      onSelected: (selected) =>
                          setState(() => _selectedTime = t),
                      selectedColor: Colors.amber,
                      labelStyle: TextStyle(
                        color: _selectedTime == t ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (eveningTimes.isNotEmpty) ...[
                Text(
                  'Evening',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: eveningTimes.map((t) {
                    return ChoiceChip(
                      label: Text(t),
                      selected: _selectedTime == t,
                      onSelected: (selected) =>
                          setState(() => _selectedTime = t),
                      selectedColor: Colors.amber,
                      labelStyle: TextStyle(
                        color: _selectedTime == t ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              // Reason Text Field
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: lang.t('reason') ?? 'Reason for visit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saving
                      ? null
                      : () async {
                          if (auth.current == null) return;
                          setState(() => _saving = true);
                          await _repo.createAppointment(
                            patientUsername: auth.current!.username,
                            doctorId: widget.doctor.id,
                            date: _selectedDate ?? '',
                            timeSlot: _selectedTime ?? '',
                            reason: _reasonCtrl.text.trim(),
                          );
                          setState(() => _saving = false);
                          Navigator.of(context).pop();
                        },
                  child: Text(
                    _saving ? '...' : (lang.t('confirm') ?? 'Confirm'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
