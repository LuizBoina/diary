import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/widgets/page_day.dart';
import 'package:diary/widgets/page_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/rendering.dart';

class InheritedPageListCards extends InheritedWidget {
  final List<DocumentSnapshot> pageList;

  InheritedPageListCards(
      {Key key, @required this.pageList, @required Widget child})
      : assert(pageList != null),
        assert(child != null),
        super(key: key, child: child);

  static InheritedPageListCards of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedPageListCards>();
  }

  @override
  bool updateShouldNotify(InheritedPageListCards oldWidget) {
    return pageList.first != oldWidget.pageList.first;
  }
}

class PagesCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widget = InheritedPageListCards.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      child: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          child: ListView.builder(
              itemCount: widget.pageList.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot page = widget.pageList[index];
                return Container(
                  height: 70,
                  margin: EdgeInsets.all(5.0),
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .backgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      PageDay(day: page['date']
                          .toDate()
                          .day
                          .toString()),

                      //Text preview
                      GestureDetector(
                        onTap: () =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PageScreen(page: page))),
                        child: Container(
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
                      ),

                      page['imageUrl'].isNotEmpty
                          ? PageImage(imageUrl: page['imageUrl'])
                          : Container(width: 50)
                    ],
                  ),
                );
              })),
    );
  }
}
