import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData light = ThemeData(
    brightness: Brightness.light,
    textTheme: TextDisplayTheme.lightTextTheme,
    inputDecorationTheme: TextFieldTheme.lightInputDecorationTheme,
    dividerColor: Colors.black,
    cardColor: Colors.grey.withOpacity(0.5)
  );

  ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    textTheme: TextDisplayTheme.darkTextTheme,
    inputDecorationTheme: TextFieldTheme.darkInputDecorationTheme,
    dividerColor: Colors.white,
    cardColor: Colors.grey.withOpacity(0.5)
  );
}

final AppTheme globalTheme = AppTheme();
