import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../models/doctor.dart';

class DoctorRepository {
  static const String boxName = 'doctorsBox';

  // Seed data from JSON file
  Future<void> seedDoctors() async {
    final box = await Hive.openBox<Doctor>(boxName);

    // Prevent re-seeding if already seeded
    if (box.isNotEmpty) return;

    // Load JSON from assets
    final String data = await rootBundle.loadString('assets/doctors.json');
    final List<dynamic> jsonList = jsonDecode(data);

    for (var docJson in jsonList) {
      final availability = <String, List<String>>{};
      (docJson['availability'] as Map<String, dynamic>).forEach((k, v) {
        availability[k] = List<String>.from(v as List<dynamic>);
      });

      final doctor = Doctor(
        id: docJson['id'],
        name: docJson['name'],
        specialization: docJson['specialization'],
        fee: (docJson['fee'] as num).toDouble(),
        currency: docJson['currency'],
        availability: availability,
      );

      await box.put(doctor.id, doctor);
    }
  }

  // Retrieve all doctors
  Future<List<Doctor>> getAllDoctors() async {
    final box = await Hive.openBox<Doctor>(boxName);
    return box.values.toList();
  }
}
