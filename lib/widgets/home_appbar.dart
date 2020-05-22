import 'package:diary/screens/page.dart';
import 'package:diary/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class InheritedHomeAppBar extends InheritedWidget {
  final DateTime selectedMonth;
  final DateTime firstUploadMonth;
  final String userId;
  final bool isNewDay;

  InheritedHomeAppBar(
      {Key key,
      @required this.selectedMonth,
      @required this.userId,
      @required this.isNewDay,
      @required this.firstUploadMonth,
      @required Widget child})
      : assert(selectedMonth != null),
        assert(userId != null),
        assert(isNewDay != null),
        assert(firstUploadMonth != null),
        assert(child != null),
        super(key: key, child: child);

  static InheritedHomeAppBar of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedHomeAppBar>();
  }

  @override
  bool updateShouldNotify(InheritedHomeAppBar oldWidget) {
    return selectedMonth.isAtSameMomentAs(oldWidget.selectedMonth);
  }
}

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final widget = InheritedHomeAppBar.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () {
              return showMonthPicker(
                context: context,
                firstDate: widget.firstUploadMonth ?? DateTime.now(),
                initialDate: widget.selectedMonth,
                lastDate: DateTime.now(),
              ).then((value) {
                if (!value.isAtSameMomentAs(widget.selectedMonth)) {
                  /*_monthChangeHandle(
                        widget.userId,
                        DateTime(
                            value.year, value.month));*/
                }
              });
            },
            child: Text(
              widget.selectedMonth.toUtc().month.toString(),
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
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsScreen())),
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
        widget.isNewDay
            ? IconButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => PageScreen())),
                icon: Icon(Icons.add),
                iconSize: 28,
                padding: EdgeInsets.only(left: 20.0),
              )
            : SizedBox(width: 53)
      ],
    );
  }
}
