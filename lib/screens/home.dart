import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:diary/widgets/pages_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Timestamp firstDayMonth = Timestamp.fromDate(
        DateTime(DateTime.now().year, DateTime.now().month, 1));

    final Query pagesList = Firestore.instance
        .collection('diaries')
        .document('myDiary')
        .collection('pages')
        .where('date', isGreaterThanOrEqualTo: firstDayMonth)
        .orderBy('date', descending: true);

    final Future<dynamic> firstPage = Firestore.instance
        .collection('diaries')
        .document('myDiary')
        .collection('pages')
        .orderBy('date')
        .limit(1)
        .getDocuments()
        .then((value) => value.documents.first['date'].toDate())
        .catchError((err) {
      print('erro primeiro dia $err');
      throw err;
    });

    //can be DateTime or null
    final Future<dynamic> lastPage = pagesList
        .getDocuments()
        .then((value) => value.documents.first['date'].toDate())
        .catchError((err) {
      print('erro primeiro dia $err');
      throw err;
    });

    return FutureBuilder<dynamic>(
        future: firstPage,
        builder: (context, snapshotFirstPage) {
          return FutureBuilder<dynamic>(
              future: lastPage,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Scaffold(
                    backgroundColor: Theme.of(context).primaryColor,
                    appBar: AppBar(
                      centerTitle: true,
                      elevation: 0.0,
                      automaticallyImplyLeading: false,
                      title: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SettingsScreen())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 3.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (snapshotFirstPage.hasData) {
                                    return showMonthPicker(
                                      context: context,
                                      firstDate: snapshotFirstPage.data,
                                      initialDate: snapshot.data,
                                      lastDate: snapshot.data,
                                    ).then((value) async {
                                      Firestore.instance
                                          .collection('diaries')
                                          .document('myDiary')
                                          .collection('pages')
                                          .where('date',
                                              isGreaterThanOrEqualTo:
                                                  Timestamp.fromDate(DateTime(
                                                      value.year, value.month)))
                                          .orderBy('date', descending: true);
                                      pagesList
                                          .getDocuments()
                                          .then((value) => value);
                                    });
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      'Erro ao recuperar primeiro mes ${snapshot.error}',
                                      textAlign: TextAlign.center,
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    );
                                  }
                                },
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
                            lastPage != null ||
                                    true // && DateTime.now().toUtc().day != lastPage.toUtc().day
                                ? IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => PageScreen())),
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
                    body: PagesPopup(initialPages: pagesList),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Erro ao recuperar paginas ${snapshot.error}',
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).primaryColorDark,
                    ),
                  );
                }
              });
        });
  }
}
