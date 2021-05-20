import 'dart:convert';

import 'package:blackbeards_board/models/blackboard.dart';
import 'abstract_backend_connector.dart';
import 'package:http/http.dart' as http;



class BackendConnectorReal implements BackendConnector{

  String url = "localhost:8080";

  static const _KEY_ENDPOINT_BOARD = "/board";
  static const _KEY_ENDPOINT_BOARDS = "/boards";

  static const _KEY_ENDPOINT_BOARD_CHANGED = "/board_changed";
  static const _KEY_ENDPOINT_BOARD_ADDED = "/board_added";
  static const _KEY_ENDPOINT_BOARD_DELETED = "/board_deleted";



  @override
  Future createBlackboard(Blackboard blackboard) async {
    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD);
    print(uri);
    http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(blackboard.toJson()),
    );
    print(response);
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