import 'package:blackbeards_board/backend_connector.dart';
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
    backendConnector = BackendConnector();
    backendConnector.registerOnBoardChange("name", onBoardChanged);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text("Titel"),
        ),
        body: Row(children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemBuilder: (BuildContext context, int index){
                return Container(
                  height: MediaQuery.of(context).size.width/8,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text("Das ist Tile $index", style: TextStyle(color: Colors.white),textAlign: TextAlign.center),
                      ),
                    ),
                    color: Colors.black,
                  ),
                );
              },

            )
          ),
          Expanded(
            flex: 3,
            child: Container (
              color: Colors.black,
              height: MediaQuery.of(context).size.width*0.375,
              //padding: EdgeInsets.only(right: 600),
              child: FutureBuilder<Blackboard>(
                future: backendConnector.getBoard("Test"),
                builder: (BuildContext context, AsyncSnapshot<Blackboard> snapshot) {
                  if(snapshot.hasError){
                    return Text("Someting unexpected happend");
                  }
                  if(snapshot.hasData){
                    return Center(child: Text(snapshot.data.name, style: TextStyle(color: Colors.white),textAlign: TextAlign.center));
                  }else{
                    return SizedBox(
                      width: 75,
                      height: 75,
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          )
        ]));
  }
}
