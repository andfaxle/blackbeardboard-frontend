import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'package:blackbeards_board/tapable.dart';
import 'package:flutter/material.dart';

void main() {
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

  void onBoardChanged(Blackboard blackboard){
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    backendConnector = BackendConnector(BackendType.MOCK);
    backendConnector.registerOnBoardChange("name", onBoardChanged);
    backendConnector.getAllBlackboardNames().then(
            (List<String> names){
          setState(() {
            blackboardNames = names;
          });
        }
    );

    backendConnector.registerOnBoardAdded(onBoardAdded);
    backendConnector.registerOnBoardRemoved(onBoardRemoved);
  }

  // BB was added to the server --> Notification and name of the BB is added to the internal list
  void onBoardAdded(String name){
    setState(() {
      blackboardNames.add(name);
    });
  }

  // BB was deleted from the server --> Notification and name of the BB is removed from the internal list
  void onBoardRemoved(String name){
    setState(() {
      blackboardNames.remove(name);
    });
  }

  // internal List of Strings containing all BB names
  List<String> blackboardNames = [];

  // index of the currently selected BB
  int currentSelectedBlackboard;

/*Dialog for creating an new BB
  The BB has to be given a name, the deprecation time and a message.
 */
  Future<void> _displayCreateNewBlackboardDialog(BuildContext context) async {
    TextEditingController blackboardNameController;
    TextEditingController deprecationTimeController;
    TextEditingController messageController;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Create New Blackboard"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                  });
                },
                controller: blackboardNameController = new TextEditingController(),
                decoration: InputDecoration(hintText: "Blackboard name"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                  });
                },
                controller: deprecationTimeController = new TextEditingController(),
                decoration: InputDecoration(hintText: "Deprecation Time"),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                  });
                },
                controller: messageController = new TextEditingController(),
                decoration: InputDecoration(hintText: "Message"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Create'),
              onPressed: () {
                backendConnector.createBlackboard(new Blackboard(blackboardNameController.text,
                    deprecationTime: int.parse(deprecationTimeController.text),
                    message: new Message(messageController.text)));
                Navigator.of(context).pop();
              },
            )
          ],
        ));
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
              itemBuilder: (BuildContext context, int index){
                return Container(
                  height: MediaQuery.of(context).size.width/8,
                  child: Tapable(
                    onTap: (){
                  setState(() {
                    currentSelectedBlackboard = index;
                  });
                },
                      child: Card(
                      child:
                     Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(blackboardNames[index], style: TextStyle(color: Colors.white, fontSize: 25),textAlign: TextAlign.center),
                      ),
                    ),
                    color: Colors.black,
                  ),
                  )
                );
              },
            )
          ),
          Expanded(
            flex: 3,
            child: Container (
              color: Colors.black,
              height: MediaQuery.of(context).size.width*0.375,
              margin: EdgeInsets.only(right: 8),
              child: currentSelectedBlackboard == null? Container(): FutureBuilder<Blackboard>(
                future: backendConnector.getBoard(blackboardNames[currentSelectedBlackboard]),
                builder: (BuildContext context, AsyncSnapshot<Blackboard> snapshot) {
                  if(snapshot.hasError){
                    return Text("Someting unexpected happend");
                  }
                  if(snapshot.hasData){
                      return Column (
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(snapshot.data.name,
                            style: TextStyle(color: Colors.white, fontSize: 45),
                            textAlign: TextAlign.center),
                          SizedBox(height: 50),
                          Text("— "+snapshot.data.message.content+" —",
                              style: TextStyle(color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center),
                          SizedBox(height: 100),
                          Tooltip(
                            message: 'This message is deprecated!',
                            child: Icon(
                            Icons.announcement,
                            color: Colors.red,
                            size: 35,
                          )),
                      ]);
                  }else{
                    return Center(
                        child: SizedBox(
                          width: 75,
                          height: 75,
                          child: CircularProgressIndicator(),
                        )
                    );
                  }
                },
              ),
            )
          )
        ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _displayCreateNewBlackboardDialog(context);
          },
          label: const Text('New Blackboard'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat
    );
  }
}

