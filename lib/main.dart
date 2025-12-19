import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'data/repositories/doctor_repo.dart';
import 'features/auth_repo.dart';
import 'models/doctor.dart';
import 'models/patient.dart';
import 'models/appointment.dart';
import 'screens/login_screen.dart';
import 'screens/doctor_list_screen.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(DoctorAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(AppointmentAdapter());

  // Seed doctors and patients
  final doctorRepo = DoctorRepository();
  await doctorRepo.seedDoctors();
  final authRepo = AuthRepository();
  await authRepo.seedPatients();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(builder: (context, lang, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: lang.locale,
          supportedLocales: const [Locale('en'), Locale('sw')],
          theme: AppTheme.theme,
          home: const EntryPoint(),
        );
      }),
    );
  }
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // Show login if not authenticated
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    return const DoctorListScreen();
  }
}