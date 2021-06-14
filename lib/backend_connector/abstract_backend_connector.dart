
import 'package:blackbeards_board/backend_connector/backend_connector_mock.dart';
import 'package:blackbeards_board/backend_connector/backend_connector_real.dart';
import 'package:blackbeards_board/models/blackboard.dart';


enum BackendType {
  MOCK,
  REAL
}

class BackendConnectorService{
  static void init(BackendType type,{Function(String) onMessage,Function(String) onLog}){
    _instance = BackendConnector(type,onMessage: onMessage,onLog: onLog);
  }

  static BackendConnector _instance;

  static BackendConnector get instance => _instance;
}

abstract class BackendConnector{

  factory BackendConnector(BackendType type,{Function(String) onMessage,Function(String) onLog}){
    switch(type){
      case BackendType.MOCK: return BackendConnectorMock();
      case BackendType.REAL: return BackendConnectorReal();
      default: return null;
    }
  }

  Future createBlackboard(Blackboard blackboard);

  Future<Blackboard> getBoard(String name);

  Future<List<String>> getAllBlackboardNames();

  Future updateBlackboard(Blackboard blackboard);

  Future deleteBlackboard(String name);

  Future<bool> requestBlackboardLock(String name);

  Future requestBlackboardUnlock(String name);

  Future deleteAllBlackboards();

  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback);

  void registerOnBoardsAdded(Function(List<String> name) callback);

  void registerOnBoardsRemoved(Function(List<String> name) callback);

  void registerBackendLog(Function(String) onBackendLogMessage);

  void registerBackendInfo(Function(String) onBackendInfoMessage);

}

