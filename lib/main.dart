
// Main entry point for the Flutter app. Sets up Hive, seeds data, and launches the UI.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

/// App initialization: sets up Hive, registers adapters, seeds local data, and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(DoctorAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(AppointmentAdapter());

  // Seed doctors and patients from assets if not already present
  final doctorRepo = DoctorRepository();
  await doctorRepo.seedDoctors();
  final authRepo = AuthRepository();
  await authRepo.seedPatients();

  runApp(const MyApp());
}

/// Root widget for the app. Sets up providers for language and authentication.
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
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.theme,
          home: const EntryPoint(),
        );
      }),
    );
  }
}

/// Decides which screen to show based on authentication state.
class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    // Show login if not authenticated
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    // If logged in, show doctor directory
    return const DoctorListScreen();
  }
}