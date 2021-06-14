
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

  void onTimeout(Function callback) async{

    if (message.content == null) return;

    int messageTime = message.timestamp + deprecationTime;
    int now = (DateTime.now().millisecondsSinceEpoch / 1000.0).round();

    // in millisecs
    int timeToTimeout = messageTime - now;

    if(timeToTimeout > 0){

      await Future.delayed(Duration(seconds: timeToTimeout));
      callback();
    }

  }

  bool isMessageDeprecated(){

    if (message == null) return false;
    if (message.timestamp == null) return false;
    if (message.content == null) return false;

    int messageTime = message.timestamp + deprecationTime;
    int now = (DateTime.now().millisecondsSinceEpoch / 1000.0).round();

    if(messageTime <= now) return true;

    return false;

  }

  static const KEY_NAME = "name";
  static const KEY_DEPRECATION_TIME = "deprecationTime";
  static const KEY_MESSAGE_TIMESTAMP = "timestamp";
  static const KEY_MESSAGE = "message";

  static Blackboard fromJson(Map<String,dynamic> json){
    String name = json[KEY_NAME];
    int deprecationTime = json[KEY_DEPRECATION_TIME];
    Message message = Message.fromJson(json[KEY_MESSAGE]);

    return Blackboard(name,deprecationTime: deprecationTime,message: message);
  }

  Map<String,dynamic> toJson(){

    Map<String,dynamic> messageDoc = {};
    if(message != null) messageDoc = message.toJson();

    return {
      KEY_NAME: name,
      KEY_DEPRECATION_TIME: deprecationTime,
      KEY_MESSAGE: messageDoc,
    };
  }

  @override
  String toString() {
    return 'Blackboard: {name: ${name}, deprecationTime: ${deprecationTime}, message: ${message}}';
  }
}
