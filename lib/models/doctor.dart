import 'package:hive/hive.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final double fee;
  final String currency;
  final Map<String, List<String>> availability; // e.g., {"2025-12-21": ["09:00","10:00"]}

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.fee,
    required this.currency,
    required this.availability,
  });
}

class DoctorAdapter extends TypeAdapter<Doctor> {
  @override
  final int typeId = 2;

  @override
  Doctor read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final specialization = reader.readString();
    final fee = reader.readDouble();
    final currency = reader.readString();
    final rawMap = Map<dynamic, dynamic>.from(reader.readMap());
    final availability = rawMap.map<String, List<String>>((k, v) {
      return MapEntry(k.toString(), List<String>.from(v as List<dynamic>));
    });
    return Doctor(
      id: id,
      name: name,
      specialization: specialization,
      fee: fee,
      currency: currency,
      availability: availability,
    );
  }

  @override
  void write(BinaryWriter writer, Doctor obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.specialization);
    writer.writeDouble(obj.fee);
    writer.writeString(obj.currency);
    writer.writeMap(obj.availability);
  }
}
