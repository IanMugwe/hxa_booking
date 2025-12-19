import 'package:hive/hive.dart';

class Appointment {
  final String id;
  final String patientUsername;
  final String doctorId;
  final String date; // ISO date string
  final String timeSlot;
  final String reason;
  String status; // scheduled or cancelled

  Appointment({
    required this.id,
    required this.patientUsername,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.reason,
    this.status = 'scheduled',
  });
}

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 4;

  @override
  Appointment read(BinaryReader reader) {
    final id = reader.readString();
    final patient = reader.readString();
    final doctor = reader.readString();
    final date = reader.readString();
    final time = reader.readString();
    final reason = reader.readString();
    final status = reader.readString();
    return Appointment(
      id: id,
      patientUsername: patient,
      doctorId: doctor,
      date: date,
      timeSlot: time,
      reason: reason,
      status: status,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.patientUsername);
    writer.writeString(obj.doctorId);
    writer.writeString(obj.date);
    writer.writeString(obj.timeSlot);
    writer.writeString(obj.reason);
    writer.writeString(obj.status);
  }
}
