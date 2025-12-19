import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/doctor_repo.dart';
import '../models/doctor.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'booking_screen.dart';
import 'appointments_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final repo = DoctorRepository();
  List<Doctor> _doctors = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await repo.getAllDoctors();
    setState(() => _doctors = docs);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final filtered = _filter.isEmpty ? _doctors : _doctors.where((d) => d.specialization.toLowerCase().contains(_filter.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('doctors')),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Filter by specialization'),
            onChanged: (v) => setState(() => _filter = v),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final d = filtered[i];
              return ListTile(
                title: Text(d.name),
                subtitle: Text('${d.specialization} • ${d.currency}${d.fee.toStringAsFixed(2)}'),
                trailing: ElevatedButton(
                  child: Text(lang.t('book')),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingScreen(doctor: d))),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}
