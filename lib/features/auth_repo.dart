import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/patient.dart';

class AuthRepository {
  static const String boxName = 'patientsBox';

  // Seed patients from JSON
  Future<void> seedPatients() async {
    final box = await Hive.openBox<Patient>(boxName);

    if (box.isNotEmpty) return;

    final String data = await rootBundle.loadString('assets/data/patients.json');
    final List<dynamic> jsonList = jsonDecode(data);

    for (var patJson in jsonList) {
      final patient = Patient(
        id: patJson['id'],
        username: patJson['username'],
        password: patJson['password'],
      );

      await box.put(patient.username, patient); // Key = username
    }
  }

  // Authenticate a patient
  Future<Patient?> login(String username, String password) async {
    final box = await Hive.openBox<Patient>(boxName);
    final patient = box.get(username);

    if (patient != null && patient.password == password) {
      // Persist current user
      final authBox = await Hive.openBox('authBox');
      await authBox.put('currentPatientUsername', patient.username);
      return patient;
    }

    return null; // invalid login
  }

  // Optional: logout (delete from local cache)
  Future<void> logout() async {
    // For MVP, just clear locally stored logged-in patient ID
    final box = await Hive.openBox('authBox');
    await box.delete('currentPatientUsername');
  }

  Future<Patient?> getCurrentPatient() async {
    final authBox = await Hive.openBox('authBox');
    final username = authBox.get('currentPatientUsername');
    if (username == null) return null;
    final box = await Hive.openBox<Patient>(boxName);
    return box.get(username);
  }
}
