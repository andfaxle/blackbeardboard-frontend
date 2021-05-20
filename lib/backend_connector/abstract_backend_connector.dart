
import 'package:blackbeards_board/backend_connector/backend_connector_mock.dart';
import 'package:blackbeards_board/backend_connector/backend_connector_real.dart';
import 'package:blackbeards_board/models/blackboard.dart';


enum BackendType {
  MOCK,
  REAL
}

abstract class BackendConnector{

  factory BackendConnector(BackendType type){
    switch(type){
      case BackendType.MOCK: return BackendConnectorMock();
      case BackendType.REAL: return BackendConnectorReal();
      default: return null;
    }
  }

  Future createBlackboard(Blackboard blackboard);

  Future<Blackboard> getBoard(String name);

  Future<List<String>> getAllBlackboardNames();

  Future deleteBlackboard(String name);

  Future deleteAllBlackboards();

  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback);

  void registerOnBoardAdded(String name,Function(String name) callback);

  void registerOnBoardRemoved(String name,Function(String name) callback);

}

