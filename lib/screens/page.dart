import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/screens/camera.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';


class PageScreen extends StatefulWidget {
  final DocumentSnapshot page;

  PageScreen({this.page});

  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.page != null ? widget.page['text'] : null;
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.page != null
                ? Text(
                    DateFormat('dd/MM/yyyy').format(widget.page['date'].toDate()),
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
                  )
                : IconButton(
                    onPressed: () {
                      if(_textController.text.isNotEmpty) {
                        try {
                          final DateTime date = DateTime.now();
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => CameraScreen(
                                      date: date,
                                      text: _textController.text
                                  )
                              ));
                        }
                        catch (err) {
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Erro com camera',
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
                                  textAlign: TextAlign.center,
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Theme.of(context).dialogBackgroundColor,
                              )
                          );
                        }
                      }
                      else {
                        _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Como foi seu dia?',
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
                                  textAlign: TextAlign.center,
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Theme.of(context).dialogBackgroundColor,
                            )
                        );
                      }
                      },
                    icon: Icon(Icons.check),
                    iconSize: 28,
                    color: Colors.grey,
                  )
          ],
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
          topLeft: Radius.circular(15.0),
        ),
        child: Container(
          height: 700,
          width: 700,
          color: Colors.white30,
          child: Container(
              margin: EdgeInsets.all(10.0),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                readOnly: widget.page != null ? true : false,
                keyboardType: TextInputType.multiline,
                maxLines: 1000,
                decoration: InputDecoration.collapsed(
                  hintText: 'Como foi seu dia?',
                ),
                controller: _textController,
              )),
        ),
      ),
    );
  }
}
