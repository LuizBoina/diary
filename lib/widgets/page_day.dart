import 'package:flutter/material.dart';

class PageDay extends StatelessWidget {
  final String day;

  PageDay({this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Text(
          day,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w200),
        ));
  }
}
