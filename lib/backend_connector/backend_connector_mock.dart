
import 'package:blackbeards_board/error_handling/app_exeption.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'abstract_backend_connector.dart';

class BackendConnectorMock implements BackendConnector{

  List<Blackboard> data = [];

  Future createBlackboard(Blackboard blackboard) async {
    data.add(blackboard);
  }

  Future<Blackboard> getBoard(String name) async {
    await Future.delayed(Duration(milliseconds: 3000));

    for(Blackboard blackboard in data){
      if(blackboard.name == name){
        return blackboard;
      }
    }
    throw NotFoundException('There is no board with this name');
  }

  Future<List<String>> getAllBlackboardNames() async{

  }

  Future deleteBlackboard(String name) async {

  }

  Future deleteAllBlackboards() async{

  }

  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback){

  }

  void registerOnBoardAdded(String name,Function(String name) callback){

  }

  void registerOnBoardRemoved(String name,Function(String name) callback){

  }


}

