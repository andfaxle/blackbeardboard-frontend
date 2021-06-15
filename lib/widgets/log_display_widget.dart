

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:flutter/cupertino.dart';

// This widget can be used to display a list of log infos
// It registers to the backend itself and prints its logs
class LogDisplayWidget extends StatefulWidget {
  @override
  _LogDisplayWidgetState createState() => _LogDisplayWidgetState();
}

class _LogDisplayWidgetState extends State<LogDisplayWidget> {

  List<String> logMessages = [];
  ScrollController _controller;

  @override
  void initState() {

    // used to control to which extend a list is scrolled
    _controller = new ScrollController();
    BackendConnector connector = BackendConnectorService.instance;

    // register for log messages
    connector.registerBackendLog(onLogMessageReceived);
    super.initState();
  }

  void onLogMessageReceived(String message) async{

    // wait in case of other update calls
    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      // add new message to the list and trigger rebuild
      logMessages.add(message);
    });

    // wait for rebuild
    await Future.delayed(Duration(milliseconds: 300));

    // scroll down as far as possible
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(milliseconds: 300), curve: Curves.easeInOut
    );
  }

  // Displays a list of texts
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE8F4FF),
      child: ListView.separated(
        controller: _controller,
        itemCount: logMessages.length,
        padding: EdgeInsets.all(4),
        separatorBuilder: (BuildContext context, int index){
          return SizedBox(height: 8,);
        },
        itemBuilder: (BuildContext context, int index) {
          String text = logMessages[index];
          return Text(text);
        }
      )
    );
  }
}
