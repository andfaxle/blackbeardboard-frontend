

import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';

void main(){
  BackendConnector backendConnector = BackendConnector(BackendType.REAL);

  Blackboard blackboard = new Blackboard("Testname");
  backendConnector.createBlackboard(blackboard);
}