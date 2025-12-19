import 'package:hive/hive.dart';
import '../../models/appointment.dart';

class AppointmentRepository {
  static const String boxName = 'appointmentsBox';

  Future<void> saveAppointment(Appointment appt) async {
    final box = await Hive.openBox<Appointment>(boxName);
    await box.put(appt.id, appt);
  }

  Future<Appointment> createAppointment({
    required String patientUsername,
    required String doctorId,
    required String date,
    required String timeSlot,
    required String reason,
  }) async {
    final box = await Hive.openBox<Appointment>(boxName);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final appt = Appointment(
      id: id,
      patientUsername: patientUsername,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
      reason: reason,
    );
    await box.put(id, appt);
    return appt;
  }

  Future<List<Appointment>> getAppointmentsForUser(String username) async {
    final box = await Hive.openBox<Appointment>(boxName);
    return box.values.where((a) => a.patientUsername == username).toList();
  }

  Future<void> cancelAppointment(String id) async {
    final box = await Hive.openBox<Appointment>(boxName);
    final appt = box.get(id);
    if (appt != null) {
      appt.status = 'cancelled';
      await box.put(id, appt);
    }
  }
}
