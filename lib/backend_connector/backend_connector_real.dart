import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'abstract_backend_connector.dart';

class BackendConnectorReal implements BackendConnector{

  @override
  Future createBlackboard(Blackboard blackboard) {
    // TODO: implement createBlackboard
    throw UnimplementedError();
  }

  @override
  Future deleteAllBlackboards() {
    // TODO: implement deleteAllBlackboards
    throw UnimplementedError();
  }

  @override
  Future deleteBlackboard(String name) {
    // TODO: implement deleteBlackboard
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getAllBlackboardNames() {
    // TODO: implement getAllBlackboardNames
    throw UnimplementedError();
  }

  @override
  Future<Blackboard> getBoard(String name) {
    // TODO: implement getBoard
    throw UnimplementedError();
  }

  @override
  void registerOnBoardAdded(String name, Function(String name) callback) {
    // TODO: implement registerOnBoardAdded
  }

  @override
  void registerOnBoardChange(String name, Function(Blackboard blackboard) callback) {
    // TODO: implement registerOnBoardChange
  }

  @override
  void registerOnBoardRemoved(String name, Function(String name) callback) {
    // TODO: implement registerOnBoardRemoved
  }

}