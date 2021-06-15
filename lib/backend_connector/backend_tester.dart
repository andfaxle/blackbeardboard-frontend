

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';


// used to test the backend during development
// written only in dart, so testing doesnt need flutter
void main() async{


  BackendConnector backendConnector = BackendConnector(BackendType.REAL);

  await Future.delayed(Duration(milliseconds: 500));

  await backendConnector.deleteAllBlackboards();

  Blackboard blackboard = new Blackboard("Testname");
  await backendConnector.createBlackboard(blackboard);

  List<String> getBoards = await backendConnector.getAllBlackboardNames();


  return;
  Blackboard b = await backendConnector.getBoard("Testname");
  print(b);
  b.message = Message("Das ist eine Nachricht");

  await backendConnector.updateBlackboard(b);
  print(b);

  List<String> names = await backendConnector.getAllBlackboardNames();
  print(names);
}