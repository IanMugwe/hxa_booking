import 'package:hive/hive.dart';

/// Patient model for Hive local storage.

/// Represents a patient/user in the app.
class Patient {
  final String id;
  final String username;
  final String password;

  Patient({
    required this.id,
    required this.username,
    required this.password,
  });
}

/// Hive adapter for Patient model.
class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 3;

  @override
  Patient read(BinaryReader reader) {
    final id = reader.readString();
    final username = reader.readString();
    final password = reader.readString();
    return Patient(id: id, username: username, password: password);
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.password);
  }
}
