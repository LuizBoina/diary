import 'dart:io';

import 'package:flutter/material.dart';

class PageImage extends StatelessWidget {
  final String imageUrl;

  PageImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (_) =>
                Dialog(child: Image.file(File(imageUrl), fit: BoxFit.cover)));
      },
      child: CircleAvatar(
          radius: 25,
          child: ClipOval(
              child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.file(
                    File(imageUrl),
                    filterQuality: FilterQuality.low,
                    fit: BoxFit.cover,
                  )))),
    );
  }
}
