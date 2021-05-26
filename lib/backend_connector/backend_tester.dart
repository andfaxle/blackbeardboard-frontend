

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

void main() async{
  BackendConnector backendConnector = BackendConnector(BackendType.REAL,onMessage: (String message){
    print(message);
  });

  Blackboard blackboard = new Blackboard("Testname");
  backendConnector.createBlackboard(blackboard);

  Blackboard b = await backendConnector.getBoard("Testname");
  print(b);

  List<String> names = await backendConnector.getAllBlackboardNames();
  print(names);
}