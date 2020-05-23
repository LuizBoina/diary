import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:diary/widgets/dialog_loading.dart';
import 'package:diary/widgets/pages_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key key, this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<DocumentSnapshot>> _futurePageList;
  List<DocumentSnapshot> _currentPageList;
  bool isFirstLoad = true;

  @override
  initState() {
    super.initState();
    _futurePageList = _getInitialPageList();
  }

  //initialize with first day of actual month
  DateTime selectedMonth =
  DateTime(DateTime
      .now()
      .year, DateTime
      .now()
      .month, 1);

  Future<DateTime> _getFirstUploadedMonth() {
    //return DateTime Obj of first uploaded page
    return Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('years')
        .limit(1)
        .getDocuments()
        .then((yearDoc) =>
    yearDoc.documents.isNotEmpty
        ? yearDoc.documents[0].reference
        .collection('months')
        .limit(1)
        .getDocuments()
        .then((monthDoc) {
      final int year = int.parse(yearDoc.documents[0].documentID);
      final int month = int.parse(monthDoc.documents[0].documentID);
      return DateTime(year, month);
    })
        : DateTime.now());
  }

  Future<List<DocumentSnapshot>> _getInitialPageList() {
    Firestore.instance
        .settings(cacheSizeBytes: 20 * 1024 * 1024, persistenceEnabled: true);
    return Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('years')
        .document(selectedMonth.year.toString())
        .collection('months')
        .document(selectedMonth.month.toString().padLeft(2, '0'))
        .collection('days')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((daysDoc) => daysDoc.documents);
  }

  _monthChangeHandle(DateTime newDate) {
    print('neo');
    DialogLoading.showLoadingDialog(context);
    selectedMonth = newDate;
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('years')
        .document(selectedMonth.year.toString())
        .collection('months')
        .document(selectedMonth.month.toString().padLeft(2, '0'))
        .collection('days')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((daysDoc) =>
        setState(() {
          print(daysDoc.documents);
          _currentPageList = daysDoc.documents;
        }))
        .catchError((err) {
      print('err');
      Navigator.of(context /*, rootNavigator: true*/).pop();
    });
    //.getDocuments().then((value) => value.documents.forEach((element) {print('TESTE _______ ${element.documentID}');}));
    Navigator.of(context /*, rootNavigator: true*/).pop();
  }

  Widget _circularLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('userId ---------- ${widget.userId}');
    return FutureProvider<DateTime>(
        create: (_) => _getFirstUploadedMonth(),
        child: Consumer<DateTime>(
            builder: (BuildContext context, DateTime firstUploadMonth, _) {
              if (firstUploadMonth == null) return _circularLoading();
              return FutureBuilder<List<DocumentSnapshot>>(
                future: _futurePageList,
                // ignore: missing_return
                builder: (context, pageListSnap) {
                  if (pageListSnap.hasData) {
                    if (isFirstLoad) {
                      isFirstLoad = false;
                      _currentPageList = pageListSnap.data;
                    }
                    bool isNewDay = _currentPageList.isEmpty ||
                        DateTime
                            .now()
                            .day !=
                            _currentPageList[0]['date']
                                .toDate()
                                .day;
                    return Scaffold(
                      appBar: AppBar(
                          elevation: 0.0,
                          automaticallyImplyLeading: false,

                          // TITLE
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  return showMonthPicker(
                                    context: context,
                                    firstDate: firstUploadMonth ??
                                        DateTime.now(),
                                    initialDate: selectedMonth,
                                    lastDate: DateTime.now(),
                                  ).then((value) {
                                    if (!value.isAtSameMomentAs(
                                        selectedMonth)) {
                                      _monthChangeHandle(
                                          DateTime(value.year, value.month));
                                    }
                                  }).catchError((err) => print('cancelado'));
                                },
                                child: Text(
                                  selectedMonth
                                      .toUtc()
                                      .month
                                      .toString(),
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
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => SettingsScreen()));
                                  },
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
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ),
                              ),
                              isNewDay
                                  ? IconButton(
                                onPressed: () =>
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                PageScreen(
                                                  userId: widget.userId,
                                                ))),
                                icon: Icon(Icons.add),
                                iconSize: 28,
                                padding: EdgeInsets.only(left: 20.0),
                              )
                                  : SizedBox(width: 53)
                            ],
                          )),
                      body: _currentPageList.isNotEmpty
                          ? InheritedPageListCards(
                        pageList: _currentPageList,
                        child: PagesCards(),
                      )
                          : Center(
                        child: Text(
                          'Nada escrito aqui',
                          style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                blurRadius: 20.0,
                                color: Colors.grey,
                                offset: Offset(0, 0),
                              ),
                            ],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else
                    return _circularLoading();
                },
              );
            }));
  }
}
