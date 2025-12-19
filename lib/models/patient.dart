import 'package:hive/hive.dart';

class Patient {
  final String id;
  final String username;
  final String password;
  final String? name;

  Patient({
    required this.id,
    required this.username,
    required this.password,
    this.name,
  });
}

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 3;

  @override
  Patient read(BinaryReader reader) {
    final id = reader.readString();
    final username = reader.readString();
    final password = reader.readString();
    final name = reader.readString();
    return Patient(id: id, username: username, password: password, name: name);
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.password);
    writer.writeString(obj.name ?? '');
  }
}
