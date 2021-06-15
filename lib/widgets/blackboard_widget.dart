

import 'dart:async';

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/backend_connector/backend_connector_service.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'tapable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A widget to display a blackboard
// also listens for changes on itself as it registers on the backend
class BlackboardWidget extends StatefulWidget {

  final Function onTap;
  final String name;

  const BlackboardWidget({Key key, this.onTap, this.name}) : super(key: key);

  @override
  _BlackboardWidgetState createState() => _BlackboardWidgetState();
}

class _BlackboardWidgetState extends State<BlackboardWidget> {

  // connection to the backend
  BackendConnector backendConnector;
  // Using a stream as the blackboard could be updated
  StreamController<Blackboard> _streamController = StreamController<Blackboard>();

  // If a newer version of the blackboard is available
  // put it in the stream
  // StreamBuilder will update automatically, so no need for setState
  void onBoardChanged(Blackboard blackboard){
    _streamController.add(blackboard);
  }

  // If setState was called above this widget, the name of the blackboard to display
  // could have changed
  // If so, initialize the blackboard data as new
  @override
  void didUpdateWidget(covariant BlackboardWidget oldWidget) {
    if(oldWidget.name != widget.name){
      initBlackboard();
    }
    super.didUpdateWidget(oldWidget);
  }

  // loads data from the server and also registers for updates
  initBlackboard(){
    backendConnector.getBoard(widget.name).then((Blackboard blackboard){
        // add board to the stream to trigger rebuild with new data
        _streamController.add(blackboard);
      }
    );
    backendConnector.registerOnBoardChange(widget.name,onBoardChanged);
  }

  @override
  void initState() {
    // get connection to the blackboard and register on updates
    backendConnector = BackendConnectorService.instance;
    initBlackboard();
    super.initState();
  }

  @override
  void dispose() {
    // _streamController needs to be closed manually
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
        // A StreamBuilder will update everytime a new object is added to
        // the Steam, which makes it perfect for asynchronous dataflow
        child:  StreamBuilder<Blackboard>(
          stream: _streamController.stream,
          builder: (BuildContext context,
              AsyncSnapshot<Blackboard> snapshot) {
            if (snapshot.hasError) {
              return Text("Someting unexpected happend");
            }

            // display blackboard, if available already
            if (snapshot.hasData) {

              // register to trigger a rebuild if the message of the board is
              // deprecated
              // More info on Blackboard.onTimout
              snapshot.data.onTimeout(() {
                setState(() {});
              });

              final DateFormat formatter = DateFormat("dd.MM.yyyy, HH:mm:ss");
              String dateString = "";
              int timestamp = snapshot?.data?.message?.timestamp;
              if(timestamp != null){
                dateString = "Posted on " + formatter.format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
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
                                // If the message of the board is null, display an empty string
                                // define placeholder for null with "??"
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

                        // Show the user if a message is deprecated
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
              // if there is no data yet, display loading symbol
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
