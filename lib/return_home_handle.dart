import 'package:diary/screens/home.dart';
import 'package:flutter/material.dart';

class HomeArguments {
  final String userId;

  HomeArguments(this.userId);
}

class ReturnHomeHandleScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final HomeArguments args = ModalRoute.of(context).settings.arguments;

    return HomeScreen(
      userId: args.userId,
    );
  }
}
