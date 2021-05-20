
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:blackbeards_board/models/message.dart';
import 'abstract_backend_connector.dart';

class BackendConnectorMock implements BackendConnector{

  Future createBlackboard(Blackboard blackboard) async {

  }

  Future<Blackboard> getBoard(String name) async {
    await Future.delayed(Duration(milliseconds: 3000));

    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    Message message = Message("Das ist eine Testnachricht",timestampNow);
    return Blackboard("Toller Name",60,message);
  }

  Future<List<String>> getAllBlackboardNames(){

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