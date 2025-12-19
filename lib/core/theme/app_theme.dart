import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primarySwatch: Colors.amber,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber).copyWith(secondary: Colors.amberAccent),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
  );
}
