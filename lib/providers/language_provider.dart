import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String t(String key) {
    final Map<String, Map<String, String>> translations = {
      'en': {
        'login_title': 'Login',
        'username': 'Username',
        'password': 'Password',
        'login': 'Login',
        'doctors': 'Doctors',
        'book': 'Book',
        'my_appointments': 'My Appointments',
        'select_date': 'Select Date',
        'select_time': 'Select Time',
        'reason': 'Reason',
        'confirm': 'Confirm Booking',
        'cancel': 'Cancel',
      },
      'sw': {
        'login_title': 'Ingia',
        'username': 'Jina la mtumiaji',
        'password': 'Nenosiri',
        'login': 'Ingia',
        'doctors': 'Madaktari',
        'book': 'Weka miadi',
        'my_appointments': 'Miadi Yangu',
        'select_date': 'Chagua Tarehe',
        'select_time': 'Chagua Muda',
        'reason': 'Sababu',
        'confirm': 'Thibitisha',
        'cancel': 'Ghairi',
      }
    };

    final lang = _locale.languageCode;
    return translations[lang]?[key] ?? key;
  }
}
