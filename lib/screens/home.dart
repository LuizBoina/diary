import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:diary/widgets/pages_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> currentPageList = List<DocumentSnapshot>();

  //initialize with first day of actual month
  DateTime selectedMoth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  //get date from the first updated page
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

  _updatePageList(newPageList) {
    if (newPageList != currentPageList)
      setState(() {
        currentPageList = newPageList;
      });
  }

  _getPageListMonth(DateTime selectedMoth) async {
    Timestamp selectedMothTimestamp = Timestamp.fromDate(selectedMoth);
    final Timestamp firstDayNextMonth =
        Timestamp.fromDate(DateTime(selectedMoth.year, selectedMoth.month + 1));

    List<DocumentSnapshot> result = await Firestore.instance
        .collection('diaries')
        .document('myDiary')
        .collection('pages')
        .where('date',
            isGreaterThanOrEqualTo: selectedMothTimestamp,
            isLessThan: firstDayNextMonth)
        .orderBy('date', descending: true)
        .getDocuments()
        .then((value) => value.documents);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: firstPage,
        builder: (context, firstPageSnap) {
          return FutureBuilder<dynamic>(
              future: _getPageListMonth(selectedMoth),
              builder: (context, pagesListSnap) {
                if (pagesListSnap.hasData) {
                  List<DocumentSnapshot> currentPageList =
                      pagesListSnap.data as List<DocumentSnapshot>;
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
                                  return showMonthPicker(
                                    context: context,
                                    firstDate: firstPageSnap.data,
                                    initialDate: DateTime.now(),
                                    lastDate: DateTime.now(),
                                  ).then((value) async {
                                    if (!value.isAtSameMomentAs(selectedMoth)) {
                                      print('selectedMoth = $selectedMoth');
                                      selectedMoth =
                                          DateTime(value.year, value.month);
                                      print('selectedMoth = $selectedMoth');
                                      print(
                                          'currentPageList = $currentPageList');
                                      var newPageList =
                                          await _getPageListMonth(selectedMoth);
                                      _updatePageList(newPageList);
                                      print(
                                          'currentPageList = $currentPageList');
                                    }
                                  });
                                },
                                child: Text(
                                  selectedMoth.toUtc().month.toString(),
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
                            pagesListSnap.data.isEmpty ||
                                    DateTime.now().toUtc().day !=
                                        pagesListSnap.data[0]['date']
                                            .toDate()
                                            .toUtc()
                                            .day
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
                    body: pagesListSnap.data.isNotEmpty
                        ? InheritedPageListPopup(
                            pageList: currentPageList,
                            child: PagesPopup(),
                          )
                        : Text('Escreva algo em seu diário'),
                  );
                } else if (pagesListSnap.hasError) {
                  return Text(
                    'Erro ao recuperar paginas ${pagesListSnap.error}',
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
