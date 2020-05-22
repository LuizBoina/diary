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
  Future<String> _getUserId() {
    return (getCurrentUser()).then((user) {
      print('user $user');
      if (user == null) return 'NO_AUTH';
      return user.uid;
    });
  }

  Widget _circularLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, manager, _) =>
            FutureProvider<String>(
              create: (_) => _getUserId(),
              child: Consumer<String>(
                  builder: (BuildContext context, String userId, _) {
                    Widget handleAuth;
                    if (userId == null) {
                      return _circularLoading();
                    } else if (userId == 'NO_AUTH') {
                      handleAuth = LoginScreen();
                    } else {
                      handleAuth = HomeScreen(
                        userId: userId,
                      );
                    }
                    return MaterialApp(
                title: 'Flutter Diary',
                debugShowCheckedModeBanner: false,
                theme: manager.themeData,
                        home: handleAuth);
                  }),
            ),
      ),
    );
  }
}
