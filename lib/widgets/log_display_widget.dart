

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:flutter/cupertino.dart';

class LogDisplayWidget extends StatefulWidget {
  @override
  _LogDisplayWidgetState createState() => _LogDisplayWidgetState();
}

class _LogDisplayWidgetState extends State<LogDisplayWidget> {

  List<String> logMessages = [];
  ScrollController _controller;

  @override
  void initState() {
    _controller = new ScrollController();
    BackendConnector connector = BackendConnectorService.instance;
    connector.registerBackendLog(onLogMessageReceived);
    super.initState();
  }

  void onLogMessageReceived(String message) async{



    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      logMessages.add(message);
    });
    await Future.delayed(Duration(milliseconds: 300));

    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(milliseconds: 300), curve: Curves.easeInOut
    );
  }

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
