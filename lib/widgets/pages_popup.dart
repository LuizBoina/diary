import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/page.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/rendering.dart';

// ignore: must_be_immutable
class InheritedPageListPopup extends InheritedWidget {
  final List<DocumentSnapshot> pageList;

  InheritedPageListPopup(
      {Key key, @required this.pageList, @required Widget child})
      : assert(pageList != null),
        assert(child != null),
        super(key: key, child: child);

  static InheritedPageListPopup of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedPageListPopup>();
  }

  @override
  bool updateShouldNotify(InheritedPageListPopup oldWidget) {
    print('entrou = ${pageList.first != oldWidget.pageList.first}');
    return pageList.first != oldWidget.pageList.first;
  }
}

class PagesPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widget = InheritedPageListPopup.of(context);
    print(widget);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      child: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: ListView.builder(
              itemCount: widget.pageList.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot page = widget.pageList[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PageScreen(page: page))),
                  child: Container(
                    height: 70,
                    margin: EdgeInsets.all(5.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            child: Text(
                              page['date'].toDate().day.toString(),
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w200),
                            )),
                        Container(
                            width: 200,
                            height: 100,
                            alignment: Alignment.topLeft,
                            child: Text(
                              page['text'],
                              style: TextStyle(
                                letterSpacing: 0.25,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            )),
                        page['imageUrl'].isNotEmpty
                            ? GestureDetector(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                          child: Image.file(
                                              File(page['imageUrl']),
                                              fit: BoxFit.cover)));
                                },
                                child: CircleAvatar(
                                    radius: 25,
                                    child: ClipOval(
                                        child: SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: Image.file(
                                              File(page['imageUrl']),
                                              filterQuality: FilterQuality.low,
                                              fit: BoxFit.cover,
                                            )))),
                              )
                            : Text('')
                      ],
                    ),
                  ),
                );
              })),
    );
  }
}
