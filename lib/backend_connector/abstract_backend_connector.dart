
import 'package:blackbeards_board/backend_connector/backend_connector_mock.dart';
import 'package:blackbeards_board/backend_connector/backend_connector_real.dart';
import 'package:blackbeards_board/models/blackboard.dart';


enum BackendType {
  MOCK,
  REAL
}

abstract class BackendConnector{

  factory BackendConnector(BackendType type,{Function(String) onMessage}){

    Function(String) nullSaveOnMessage = (String message){
      if(onMessage != null){
        onMessage(message);
      }
    };

    switch(type){
      case BackendType.MOCK: return BackendConnectorMock(onMessage:nullSaveOnMessage);
      case BackendType.REAL: return BackendConnectorReal(onMessage:nullSaveOnMessage);
      default: return null;
    }
  }

  Future createBlackboard(Blackboard blackboard);

  Future<Blackboard> getBoard(String name);

  Future<List<String>> getAllBlackboardNames();

  Future updateBlackboard(Blackboard blackboard);

  Future deleteBlackboard(String name);

  Future deleteAllBlackboards();

  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback);

  void registerOnBoardAdded(Function(String name) callback);

  void registerOnBoardRemoved(Function(String name) callback);

}

