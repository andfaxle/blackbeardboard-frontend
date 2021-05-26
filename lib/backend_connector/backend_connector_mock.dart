
import 'package:blackbeards_board/error_handling/app_exeption.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'abstract_backend_connector.dart';

class BackendConnectorMock implements BackendConnector{

  Function(String) onMessage;

  BackendConnectorMock({Function(String) onMessage}){
    this.onMessage = onMessage;
  }

  List<Blackboard> data = [];

  @override
  Future createBlackboard(Blackboard blackboard) async {

    await Future.delayed(Duration(milliseconds: 2000));
    data.add(blackboard);
    onMessage("Board created successfully");
    onBoardAddedCallback(blackboard.name);
  }

  @override
  Future<Blackboard> getBoard(String name) async {

    await Future.delayed(Duration(milliseconds: 2000));

    for(Blackboard blackboard in data){
      if(blackboard.name == name){
        return blackboard;
      }
    }
    throw NotFoundException('There is no board with this name');
  }

  @override
  Future<List<String>> getAllBlackboardNames() async{

    await Future.delayed(Duration(milliseconds: 2000));

    List<String> names = [];

    for(Blackboard blackboard in data){
      names.add(blackboard.name);
    }

    return names;
  }


  @override
  Future updateBlackboard(Blackboard blackboardToUpdate) async {

    await Future.delayed(Duration(milliseconds: 2000));

    String nameToUpdate = blackboardToUpdate.name;

    for(Blackboard blackboard in data){
      if(nameToUpdate == blackboard.name){
        int index = data.indexOf(blackboard);
        data[index] = blackboardToUpdate;

        if(onBoardChangedName == nameToUpdate){
          onBoardChangedCallback(blackboardToUpdate);
        }

        return null;
      }
    }

    throw NotFoundException('There is no board with this name');

  }

  @override
  Future deleteBlackboard(String name) async {

    await Future.delayed(Duration(milliseconds: 2000));

    for(Blackboard blackboard in data){
      if(blackboard.name == name){
        data.remove(blackboard);

        onBoardRemovedCallback(name);

        return null;
      }
    }

    throw NotFoundException('There is no board with this name');
  }

  @override
  Future deleteAllBlackboards() async{

    await Future.delayed(Duration(milliseconds: 2000));

    for(Blackboard blackboard in data){
      onBoardRemovedCallback(blackboard.name);
    }

    data = [];
  }



  String onBoardChangedName;
  Function(Blackboard blackboard) onBoardChangedCallback;
  Function(String name) onBoardAddedCallback;
  Function(String name) onBoardRemovedCallback;

  @override
  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback){
    onBoardChangedName = name;
    onBoardChangedCallback = callback;
  }

  @override
  void registerOnBoardAdded(Function(String name) callback){
    onBoardAddedCallback = callback;
  }

  @override
  void registerOnBoardRemoved(Function(String name) callback){
    onBoardRemovedCallback = callback;
  }



}

