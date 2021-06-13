import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'package:blackbeards_board/tapable.dart';
import 'package:blackbeards_board/widgets/main_create_new_blackboard_dialog.dart';
import 'package:blackbeards_board/widgets/main_delete_all_blackboards_dialog.dart';
import 'package:blackbeards_board/widgets/main_floating_action_button.dart';
import 'package:blackbeards_board/widgets/main_update_blackboard_dialog.dart';
import 'package:flutter/material.dart';

void main() {
  BackendConnectorService.init(BackendType.MOCK);
  runApp(MyApp());
}

//Top Level Widget for the App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

// Widget for the Website
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BackendConnector backendConnector;

  void onBoardChanged(Blackboard blackboard) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    backendConnector = BackendConnectorService.instance;
    // TODO:backendConnector.registerOnBoardChange("name", onBoardChanged);
    backendConnector.getAllBlackboardNames().then((List<String> names) {
      setState(() {
        blackboardNames = names;
      });
    });

    backendConnector.registerOnBoardsAdded(onBoardsAdded);
    backendConnector.registerOnBoardsRemoved(onBoardsRemoved);
  }

  // BB was added to the server --> Notification and name of the BB is added to the internal list
  void onBoardsAdded(List<String> names) {
    setState(() {
      blackboardNames.addAll(names);
    });
  }

  void onBackendMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: Text(message)));
  }

  // BB was deleted from the server --> Notification and name of the BB is removed from the internal list
  void onBoardsRemoved(List<String> names) {
    setState(() {
      for (String name in names) {
        blackboardNames.remove(name);
      }
    });
  }

  // internal List of Strings containing all BB names
  List<String> blackboardNames = [];

  // index of the currently selected BB
  int currentSelectedBlackboard;

  // returns the name of the current blackboard
  String getcurrentBlackboardName() {
    return blackboardNames[currentSelectedBlackboard];
  }

/* Displays the Create New Blackboard Dialog --> .\widgets\main_create_new_blackboard_dialog.dart
  The BB has to be given a name, the deprecation time and a message.
 */
  Future<void> _displayCreateNewBlackboardDialog(BuildContext context) async {
    TextEditingController blackboardNameController =
        new TextEditingController();
    TextEditingController deprecationTimeController =
        new TextEditingController();
    TextEditingController messageController = new TextEditingController();
    showDialog(
      context: context,
      builder: (_) => new MainCreateNewBlackboardDialog(
        blackboardNameController: blackboardNameController,
        deprecationTimeController: deprecationTimeController,
        messageController: messageController,
        onCancelPressed: () {
          Navigator.of(context).pop(); //exit dialog
        },
        onCreatePressed: () {
          backendConnector.createBlackboard(new Blackboard(
              blackboardNameController.text,
              deprecationTime: int.parse(deprecationTimeController.text),
              message: new Message(messageController.text)));
          Navigator.of(context).pop(); //exit dialog
        },
      ),
    );
  }

  /* Displays the Update Blackboard Dialog --> .\widgets\main_update_blackboard_dialog.dart
  The BB has to be given a new deprecation time and a new message.
 */
  Future<void> _displayUpdateBlackboardDialog(BuildContext context) async {
    TextEditingController deprecationTimeController =
        new TextEditingController();
    TextEditingController messageController = new TextEditingController();
    showDialog(
        context: context,
        builder: (_) => new MainUpdateBlackboardDialog(
              messageController: messageController,
              deprecationTimeController: deprecationTimeController,
              onDeletePressed: () {
                backendConnector.deleteBlackboard(getcurrentBlackboardName());
                currentSelectedBlackboard = null;
                setState(() {});
                Navigator.of(context).pop(); //exit dialog
              },
              onCancelPressed: () {
                Navigator.of(context).pop(); //exit dialog
              },
              onUpdatePressed: () {
                Blackboard newBlackboard = new Blackboard(
                    getcurrentBlackboardName(),
                    deprecationTime: int.parse(deprecationTimeController.text),
                    message: new Message(messageController.text));
                backendConnector.updateBlackboard(newBlackboard);
                setState(() {});
                Navigator.of(context).pop(); //exit dialog
              },
            ));
  }

  // Displays the Delete all Blackboards Dialog --> .\widgets\main_delete_all_blackboards_dialog.dart

  Future<void> _displayDeleteAllBlackboardsDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => new MainDeleteAllBlackboardsDialog(
        onCancelPressed: () {
          Navigator.of(context).pop(); //exit dialog
        },
        onDeleteAllPressed: () {
          backendConnector.deleteAllBlackboards();
          currentSelectedBlackboard = null;
          setState(() {});
          Navigator.of(context).pop(); //exit dialog
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BlackBeardBoard"),
        ),
        body: Row(children: <Widget>[
          Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: blackboardNames.length,
                padding: EdgeInsets.all(4),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: MediaQuery.of(context).size.width / 8,
                      child: Tapable(
                        onTap: () {
                          setState(() {
                            currentSelectedBlackboard = index;
                          });
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(blackboardNames[index],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          color: Colors.black,
                        ),
                      ));
                },
              )),
          Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.width * 0.375,
                margin: EdgeInsets.only(right: 8),
                child: Tapable(
                  onTap: currentSelectedBlackboard != null
                      ? () {
                          _displayUpdateBlackboardDialog(context);
                        }
                      : null,
                  child: currentSelectedBlackboard == null
                      ? Container()
                      : FutureBuilder<Blackboard>(
                          future: backendConnector
                              .getBoard(getcurrentBlackboardName()),
                          builder: (BuildContext context,
                              AsyncSnapshot<Blackboard> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Someting unexpected happend");
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              snapshot.data.onTimeout(() {
                                setState(() {});
                              });
                              return Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    Text(snapshot.data.name,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 45),
                                        textAlign: TextAlign.center),
                                    SizedBox(height: 50),
                                    Text(
                                        "— " +
                                            snapshot.data.message.content +
                                            " —",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                        textAlign: TextAlign.center),
                                    SizedBox(height: 100),
                                    if (snapshot.data.isMessageDeprecated())
                                      Icon(
                                        Icons.announcement,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                    if (snapshot.data.isMessageDeprecated())
                                      Text('This message is deprecated!',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 11)),
                                    if (snapshot.data.isMessageDeprecated())
                                      Text('Click to write an new one!',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 11)),
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
              )),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: MainFloatingActinButton(
          onAddBlackboardPressed: () {
            _displayCreateNewBlackboardDialog(context);
          },
          onDeleteAllBlackboardsPressed: () {
            _displayDeleteAllBlackboardsDialog(context);
          },
        ));
  }
}
