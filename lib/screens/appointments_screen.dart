import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/appointment_repo.dart';
import '../providers/auth_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _repo = AppointmentRepository();
  var _appointments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.current == null) return;
    final list = await _repo.getAppointmentsForUser(auth.current!.username);
    setState(() => _appointments = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _appointments.length,
          itemBuilder: (ctx, i) {
            final a = _appointments[i];
            return ListTile(
              title: Text('${a.date} ${a.timeSlot}'),
              subtitle: Text('${a.reason} • ${a.status}'),
              trailing: a.status == 'scheduled'
                  ? TextButton(
                      onPressed: () async {
                        await _repo.cancelAppointment(a.id);
                        await _load();
                      },
                      child: const Text('Cancel'))
                  : null,
            );
          },
        ),
      ),
    );
  }
}
