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
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Das ist Tile $index"),
                  ),
                );
              },

            )
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.red,
              height: 100,
            ),
          )
        ]));
  }
}
