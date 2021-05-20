import 'package:blackbeards_board/models/blackboard.dart';
import 'abstract_backend_connector.dart';
import 'package:http/http.dart' as http;



class BackendConnectorReal implements BackendConnector{

  String url = "127.0.0.1";
  int port = 8080;

  static const _KEY_ENDPOINT_BOARD = "board";
  static const _KEY_ENDPOINT_BOARDS = "boards";

  static const _KEY_ENDPOINT_BOARD_CHANGED = "board_changed";
  static const _KEY_ENDPOINT_BOARD_ADDED = "board_added";
  static const _KEY_ENDPOINT_BOARD_DELETED = "board_deleted";

  Uri getUrl(){

  }

  @override
  Future createBlackboard(Blackboard blackboard) {

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
  void registerOnBoardAdded(Function(String name) callback) {
    // TODO: implement registerOnBoardAdded
  }

  @override
  void registerOnBoardChange(String name, Function(Blackboard blackboard) callback) {
    // TODO: implement registerOnBoardChange
  }

  @override
  void registerOnBoardRemoved(Function(String name) callback) {
    // TODO: implement registerOnBoardRemoved
  }

  @override
  Future updateBlackboard(Blackboard blackboard) {
    // TODO: implement updateBlackboard
    throw UnimplementedError();
  }


}