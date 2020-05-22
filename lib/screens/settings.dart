import 'package:diary/auth/google_auth.dart';
import 'package:diary/screens/login.dart';
import 'package:diary/theme/manager.dart';
import 'package:diary/theme/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  List<Widget> _themeDataToRaisedButtons(BuildContext context) {
    List<RaisedButton> _buttons = List<RaisedButton>();
    appThemeData.forEach((key, value) =>
        _buttons.add(RaisedButton(
          color: value.primaryColor,
          onPressed: () =>
          // This will trigger notifyListeners and rebuild UI
          // because of ChangeNotifierProvider in ThemeApp
          Provider.of<ThemeManager>(context, listen: false).setTheme(key),
          child: Text(
            enumName(key),
            style: value.textTheme.bodyText1,
          ),
        )));
    return _buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 21,
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 30.0,
                  color: Colors.grey,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Color Theme'),
                  ButtonBar(children: _themeDataToRaisedButtons(context))
                ],
              ),
              Divider(),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: ListTile(
                  onTap: () {
                    signOutGoogle();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                          return LoginScreen();
                        }), ModalRoute.withName('/'));
                  },
                  title: Text(
                    'Sign Out',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
