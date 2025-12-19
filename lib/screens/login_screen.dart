import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'doctor_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('login_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(labelText: lang.t('username')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: lang.t('password')),
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      final ok = await auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());
                      setState(() => _loading = false);
                      if (ok) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DoctorListScreen()));
                      } else {
                        setState(() => _error = 'Invalid credentials');
                      }
                    },
              child: Text(_loading ? '...' : lang.t('login')),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Spacer(),
              TextButton(
                onPressed: () {
                  final newLocale = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'en' ? const Locale('sw') : const Locale('en');
                  Provider.of<LanguageProvider>(context, listen: false).setLocale(newLocale);
                },
                child: Text('Switch Language'),
              )
            ])
          ],
        ),
      ),
    );
  }
}
