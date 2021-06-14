

import 'dart:async';

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/tapable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlackboardWidget extends StatefulWidget {

  final Function onTap;
  final String name;

  const BlackboardWidget({Key key, this.onTap, this.name}) : super(key: key);

  @override
  _BlackboardWidgetState createState() => _BlackboardWidgetState();
}

class _BlackboardWidgetState extends State<BlackboardWidget> {

  BackendConnector backendConnector;
  StreamController<Blackboard> _streamController = StreamController<Blackboard>();

  void onBoardChanged(Blackboard blackboard){
    _streamController.add(blackboard);
  }

  @override
  void didUpdateWidget(covariant BlackboardWidget oldWidget) {
    if(oldWidget.name != widget.name){
      initBlackboard();
    }
    super.didUpdateWidget(oldWidget);
  }

  initBlackboard(){
    backendConnector.registerOnBoardChange(widget.name,onBoardChanged);
    backendConnector.getBoard(widget.name).then(
            (Blackboard blackboard){
          print("GOT BOARD");
          _streamController.add(blackboard);
        }
    );
  }

  @override
  void initState() {
    backendConnector = BackendConnectorService.instance;
    initBlackboard();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      margin: EdgeInsets.only(right: 8),
      child: Tapable(
        onTap: widget.onTap,
        child:  StreamBuilder<Blackboard>(
          stream: _streamController.stream,
          builder: (BuildContext context,
              AsyncSnapshot<Blackboard> snapshot) {
            if (snapshot.hasError) {
              return Text("Someting unexpected happend");
            }
            if (snapshot.hasData) {

              snapshot.data.onTimeout(() {
                setState(() {});
              });

              final DateFormat formatter = DateFormat("dd.MM.yyyy, HH:mm:ss");
              String dateString = "";
              int timestamp = snapshot?.data?.message?.timestamp;
              if(timestamp != null){
                dateString = "Geschrieben am " + formatter.format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
              }

              return Center(
                  child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Text(snapshot.data.name,
                            style: TextStyle(
                                color: Colors.white, fontSize: 45),
                            textAlign: TextAlign.center),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.alarm,color: Colors.white,size: 15,),
                            SizedBox(width: 4,),
                            Text(snapshot.data.deprecationTime.toString() + "s",
                              style: TextStyle(
                                color: Colors.white
                              ),
                            )
                          ],
                        ),
                        Text(
                            "— " +
                                (snapshot.data.message.content  ?? "")+
                            " —",
                            style: TextStyle(
                                color: Colors.white, fontSize: 25),
                            textAlign: TextAlign.center),
                        Text(
                            dateString,
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.center),
                        if (snapshot.data.isMessageDeprecated())
                          Icon(
                            Icons.announcement,
                            color: Colors.red,
                            size: 35,
                          ),
                        if (snapshot.data.isMessageDeprecated())
                          Text('This message is deprecated!\nClick to write an new one!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,

                              )
                          ),

                      ]));
            } else {
              return Center(
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
