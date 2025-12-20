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

  @override
  void initState() {
    super.initState();
    if (widget.doctor.availability.isNotEmpty) {
      _selectedDate = widget.doctor.availability.keys.first;
      _selectedTime = widget.doctor.availability[_selectedDate!]!.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final times = _selectedDate == null ? <String>[] : widget.doctor.availability[_selectedDate!] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.doctor.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.doctor.specialization),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDate,
            items: widget.doctor.availability.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() {
              _selectedDate = v;
              final tlist = widget.doctor.availability[v!] ?? [];
              _selectedTime = tlist.isNotEmpty ? tlist.first : null;
            }),
            decoration: InputDecoration(labelText: lang.t('select_date')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedTime,
            items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
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
          )
        ]),
      ),
    );
  }
}
