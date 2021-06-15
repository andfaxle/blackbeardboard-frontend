import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'widgets/tapable.dart';
import 'package:blackbeards_board/widgets/blackboard_widget.dart';
import 'package:blackbeards_board/widgets/log_display_widget.dart';
import 'package:blackbeards_board/widgets/main_create_new_blackboard_dialog.dart';
import 'package:blackbeards_board/widgets/main_delete_all_blackboards_dialog.dart';
import 'package:blackbeards_board/widgets/main_floating_action_button.dart';
import 'package:blackbeards_board/widgets/main_update_blackboard_dialog.dart';
import 'package:flutter/material.dart';
import 'backend_connector/backend_connector_service.dart';

//Top Level Widget for the App
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBB',
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

  @override
  void initState() {
    super.initState();
    backendConnector = BackendConnectorService.instance;

    // Gets all boards that are available
    // First all current boards will be get as a List from the server
    // After that, only updates to that list are transmitted
    // via registerOnBoardsAdded and onBoardsRemoved
    backendConnector.getAllBlackboardNames().then((List<String> names) {
      setState(() {
        blackboardNames = names;
      });
    });

    // registration on add or remove boards
    backendConnector.registerOnBoardsAdded(onBoardsAdded);
    backendConnector.registerOnBoardsRemoved(onBoardsRemoved);

    // Register listener to the Infos provided by the backendconnector
    backendConnector.registerBackendInfo(onBackendInfo);
  }

  void onBackendInfo(String content){
    // Display server messages as snackbar
    // see https://material.io/components/snackbars
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  // BB was added to the server --> Notification and name of the BB is added to the internal list
  void onBoardsAdded(List<String> names) {
    setState(() {
      blackboardNames.addAll(names);
    });
  }

  // BB was deleted from the server --> Notification and name of the BB is removed from the internal list
  void onBoardsRemoved(List<String> names) {
    setState(() {

      for (String name in names) {
        if(name == currentSelectedBlackboardName){
          currentSelectedBlackboardName = null;
        }
        blackboardNames.remove(name);
      }
    });
  }

  // internal List of Strings containing all BB names
  List<String> blackboardNames = [];

  // index of the currently selected BB
  String currentSelectedBlackboardName;


/* Displays the Create New Blackboard Dialog --> .\widgets\main_create_new_blackboard_dialog.dart
  The BB has to be given a name, the deprecation time and a message.
 */
  Future<void> _displayCreateNewBlackboardDialog(BuildContext context) async {

    TextEditingController blackboardNameController =
    new TextEditingController();
    TextEditingController deprecationTimeController =
    new TextEditingController();

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => new MainCreateNewBlackboardDialog(
        formKey: _formKey,
        blackboardNameController: blackboardNameController,
        deprecationTimeController: deprecationTimeController,
        onCancelPressed: () {
          Navigator.of(context).pop(); //exit dialog
        },
        onCreatePressed: () {

          if(!_formKey.currentState.validate()) return;

          backendConnector.createBlackboard(new Blackboard(
            blackboardNameController.text,
            deprecationTime: int.parse(deprecationTimeController.text),
          ));
          Navigator.of(context).pop(); //exit dialog
        },
      ),
    );
  }

  /* Displays the Update Blackboard Dialog --> .\widgets\main_update_blackboard_dialog.dart
  The BB has to be given a new deprecation time and a new message.
 */
  Future<void> _displayUpdateBlackboardDialog(BuildContext context) async {

    String name = currentSelectedBlackboardName;
    bool editingAllowed = await backendConnector.requestBlackboardLock(name);

    if(editingAllowed){
      TextEditingController messageController = new TextEditingController();
      await showDialog(
          context: context,
          builder: (_) => new MainUpdateBlackboardDialog(
            blackboardName: name,
            messageController: messageController,
            onDeletePressed: () {
              backendConnector.deleteBlackboard(name);
              currentSelectedBlackboardName = null;
              setState(() {});
              Navigator.of(context).pop(); //exit dialog
            },
            onCancelPressed: () {
              Navigator.of(context).pop();
            },
            onUpdatePressed: () {
              Blackboard newBlackboard = new Blackboard(
                  currentSelectedBlackboardName,
                  message: new Message(messageController.text));
              backendConnector.updateBlackboard(newBlackboard);
              setState(() {});
              Navigator.of(context).pop(); //exit dialog
            },
          ));

      backendConnector.requestBlackboardUnlock(name);//exit dialog

    }else{
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("In bearbeitung"),
            content: Text("Das Blackboard wird gerade von jemand anderen bearbeitet, versuche es später erneut"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop(); //exit dialog
                },
                child: Text("Ok"),
              )
            ],
          ));
    }


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
          currentSelectedBlackboardName = null;
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
            child: Container(
                color: Color(0xFFE8F4FF),
                child: ListView.builder(
                  itemCount: blackboardNames.length,
                  padding: EdgeInsets.all(4),
                  itemBuilder: (BuildContext context, int index) {
                    int indexSelected = blackboardNames.indexOf(currentSelectedBlackboardName);
                    bool selected = indexSelected == index;
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: !selected?null:Border.all(
                              color: Colors.orange,
                              width: 5,
                            )
                        ),
                        height: MediaQuery.of(context).size.width / 8,
                        child: Tapable(
                          onTap: () {
                            print(index);
                            print(indexSelected);
                            if(indexSelected == index) return;
                            setState(() {
                              currentSelectedBlackboardName = blackboardNames[index];
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
          ),
          Expanded(
              flex: 3,
              child: currentSelectedBlackboardName == null?
              SizedBox.shrink()
                  :
              BlackboardWidget(
                  onTap: () => _displayUpdateBlackboardDialog(context),
                  name: currentSelectedBlackboardName
              )
          ),
          Expanded(
              flex: 1,
              child: LogDisplayWidget()
          ),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: MainFloatingActionButton(
          onAddBlackboardPressed: () {
            _displayCreateNewBlackboardDialog(context);
          },
          onDeleteAllBlackboardsPressed: () {
            _displayDeleteAllBlackboardsDialog(context);
          },
        ));
  }
}
