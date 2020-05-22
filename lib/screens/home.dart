import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/auth/google_auth.dart';
import 'package:diary/screens/login.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:diary/widgets/dialog_loading.dart';
import 'package:diary/widgets/home_appbar.dart';
import 'package:diary/widgets/pages_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _currentPageList;

  //initialize with first day of actual month
  DateTime selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  Future<DateTime> _getFirstUploadedMonth(String userId) {
    //return DateTime Obj of first uploaded page
    return Firestore.instance
        .collection('users')
        .document(userId)
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

  Future<List<DocumentSnapshot>> _getInitialPageList(String userId) {
    return Firestore.instance
        .collection('users')
        .document(userId)
        .collection('years')
        .document(selectedMonth.year.toString())
        .collection('months')
        .document(selectedMonth.month.toString().padLeft(2, '0'))
        .collection('days')
        .getDocuments()
        .then((daysDoc) {
      _currentPageList = daysDoc.documents;
      return daysDoc.documents;
    });
  }

  _monthChangeHandle(String userId, [DateTime newDate]) async {
    DialogLoading.showLoadingDialog(context);
    DateTime previousSelectedMonth =
    DateTime(selectedMonth.year, selectedMonth.month);
    if (newDate != null) selectedMonth = newDate;
    List<DocumentSnapshot> newPageList = List<DocumentSnapshot>();
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('years')
        .document(selectedMonth.year.toString())
        .collection('months')
        .document(selectedMonth.month.toString().padLeft(2, '0'))
        .collection('days')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((daysDoc) => newPageList.addAll(daysDoc.documents))
        .catchError((err) {
      print('err');
      Navigator.of(context /*, rootNavigator: true*/).pop();
    });

    //.getDocuments().then((value) => value.documents.forEach((element) {print('TESTE _______ ${element.documentID}');}));

    setState(() {
      print('entrou state');
      if (newPageList.isNotEmpty) {
        print('entrou if state');
        _currentPageList = newPageList;
      };
    });
    if (newPageList.isEmpty) {
      selectedMonth = previousSelectedMonth;
      /*Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Nothing in this month'),
            duration: Duration(seconds: 3),
          )
        );*/
    }
    Navigator.of(context /*, rootNavigator: true*/).pop();
    return newPageList;
  }

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
    return FutureProvider<String>(
        create: (_) => _getUserId(),
        child: Consumer<String>(
          // ignore: missing_return
          builder: (BuildContext context, String userId, _) {
            if (userId == null) {
              return _circularLoading();
            } else if (userId == 'NO_AUTH') {
              signOutGoogle();
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              return FutureProvider<DateTime>(
                  create: (_) => _getFirstUploadedMonth(userId),
                  child: Consumer<DateTime>(builder:
                      (BuildContext context, DateTime firstUploadMonth, _) {
                    if (firstUploadMonth == null) return _circularLoading();
                    return FutureProvider<List<DocumentSnapshot>>(
                      create: (_) => _getInitialPageList(userId),
                      child: Consumer<List<DocumentSnapshot>>(
                        builder: (BuildContext context, pageList, _) {
                          if (pageList != null) {
                            bool isNewDay = pageList.isEmpty ||
                                DateTime
                                    .now()
                                    .day !=
                                    pageList[0]['date']
                                        .toDate()
                                        .day;
                            return Scaffold(
                              appBar: AppBar(
                                  elevation: 0.0,
                                  automaticallyImplyLeading: false,
                                  title: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: GestureDetector(
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
                                                    userId,
                                                    DateTime(value.year,
                                                        value.month));
                                              }
                                            }).catchError((err) =>
                                                print('cancelado'));
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
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: GestureDetector(
                                          onTap: () =>
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          SettingsScreen())),
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
                                                        PageScreen())),
                                        icon: Icon(Icons.add),
                                        iconSize: 28,
                                        padding:
                                        EdgeInsets.only(left: 20.0),
                                      )
                                          : SizedBox(width: 53)
                                    ],
                                  )
                                /*title: InheritedHomeAppBar(
                                      selectedMonth: selectedMonth,
                                      isNewDay: isNewDay,
                                      userId: userId,
                                      firstUploadMonth: firstUploadMonth,
                                      child: HomeAppBar(),
                                    ),*/
                              ),
                              body: _currentPageList.isNotEmpty
                                  ? InheritedPageListCards(
                                pageList: _currentPageList,
                                child: PagesCards(),
                              )
                                  : Center(
                                child: Text(
                                  'Escreva algo em seu diário',
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
                          } else if (pageList == null)
                            return _circularLoading();
                          else {
                            return Scaffold(
                              appBar: AppBar(
                                centerTitle: true,
                                elevation: 0.0,
                                title: Text('Error'),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Error when trying to get pages.\n'
                                        'Please try Log In again. '
                                        'if problems persist please contact us.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }));
            }
          },
        ));
  }
}
