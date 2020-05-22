import 'package:flutter/material.dart';

enum AppTheme { White, Dark }

/// Returns enum value name without enum class name.
String enumName(AppTheme anyEnum) {
  return anyEnum.toString().split('.')[1];
}

final appThemeData = {
  AppTheme.White: ThemeData(primaryColor: Colors.white),
  AppTheme.Dark: ThemeData.dark(),
};
