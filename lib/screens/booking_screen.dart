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

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.doctor.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.doctor.specialization),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedDate,
              items: widget.doctor.availability.keys
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedDate = v;
                final range = widget.doctor.availability[v!] ?? [];
                final slots = _generateTimeSlots(range);
                _selectedTime = slots.isNotEmpty ? slots.first : null;
              }),
              decoration: InputDecoration(labelText: lang.t('select_date')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTime,
              items: times
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTime = v),
              decoration: InputDecoration(labelText: lang.t('select_time')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              decoration: InputDecoration(labelText: lang.t('reason')),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (auth.current == null) return; // guard
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
              child: Text(_saving ? '...' : lang.t('confirm')),
            ),
          ],
        ),
      ),
    );
  }
}
