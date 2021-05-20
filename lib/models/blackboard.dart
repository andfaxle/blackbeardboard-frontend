
import 'message.dart';

class Blackboard{

  Blackboard(String name,{int deprecationTime,Message message}){
    this.name = name;
    this.deprecationTime = deprecationTime ?? 60;
    this.message = message;
  }

  // The name of a blackboard, also unique identifier
  String name;

  // The time after a message on the blackboard is deprecated
  int deprecationTime;

  // The content of a blackboard
  Message message;

  static const _KEY_NAME = "name";
  static const _KEY_DEPRECATION_TIME = "deprecationTime";
  static const _KEY_MESSAGE = "message";

  static Blackboard fromJson(Map<String,dynamic> json){
    String name = json[_KEY_NAME];
    int deprecationTime = json[_KEY_DEPRECATION_TIME];
    Message message = Message.fromJson(json[_KEY_MESSAGE]);

    return Blackboard(name,deprecationTime: deprecationTime,message: message);
  }

  Map<String,dynamic> toJson(){

    Map<String,dynamic> messageDoc = {};
    if(message != null) messageDoc = message.toJson();

    return {
      _KEY_NAME: name,
      _KEY_DEPRECATION_TIME: deprecationTime,
      _KEY_MESSAGE: messageDoc,
    };
  }
}
