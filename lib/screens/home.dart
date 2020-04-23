import 'package:diary/models/page.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:diary/widgets/pages_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    DateTime.now().month.toString(),
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w200,
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
              ),
              Padding(
                padding: EdgeInsets.only(left: 45.0),
                child: Text(
                  '日葵',
                  style: TextStyle(
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.grey,
                        offset: Offset(0, 0),
                      ),
                    ],
                    color: Colors.white70,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              DateTime.now().day > 2 // == pages.first.date.day
                  ? IconButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PageScreen())),
                      icon: Icon(Icons.add),
                      iconSize: 28,
                      color: Colors.grey,
                      padding: EdgeInsets.only(left: 20.0),
                    )
                  : SizedBox(width: 53)
            ],
          ),
        ),
      ),
      body: PagesPopup(),
    );
  }
}
