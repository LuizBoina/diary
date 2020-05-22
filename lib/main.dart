import 'package:diary/auth/google_auth.dart';
import 'package:diary/screens/home.dart';
import 'package:diary/screens/login.dart';
import 'package:diary/theme/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Widget handleAuth =
  getCurrentUser() != null ? HomeScreen() : LoginScreen();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, manager, _) =>
            MaterialApp(
                title: 'Flutter Diary',
                debugShowCheckedModeBanner: false,
                theme: manager.themeData,
                home: handleAuth),
      ),
    );
  }
}
