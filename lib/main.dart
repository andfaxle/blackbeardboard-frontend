import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'package:blackbeards_board/tapable.dart';
import 'package:flutter/material.dart';

void main() {
  foo(j: 5);

  runApp(MyApp());
}

void foo({int index, int j}) {
  print(index);
}

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

  void onBoardAdded(String name){
    setState(() {
      blackboardNames.add(name);
    });
  }

  void onBoardRemoved(String name){
    setState(() {
      blackboardNames.remove(name);
    });
  }

  List<String> blackboardNames = [];
  int currentSelectedBlackboard;

/*Dialog for creating an new Blackboard
  The Blackboard has to be given a name and optionally the deprecation time and a message.
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
              TextField(
                onChanged: (value) {
                  setState(() {
                  });
                },
                controller: blackboardNameController = new TextEditingController(),
                decoration: InputDecoration(hintText: "Blackboard name"),
              ),
              TextField(
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
                    deprecationTime: int.parse(deprecationTimeController.text), message: new Message(messageController.text)));
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
                    return Center(child: Text(snapshot.data.name, style: TextStyle(color: Colors.white, fontSize: 40),textAlign: TextAlign.center));
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

