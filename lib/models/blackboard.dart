
import 'message.dart';

// Model of the Blackboard object
// Each Blackboard has one Message
// Implements logic to callback on deprecation and transformation from and to json
class Blackboard{

  Blackboard(String name,{int deprecationTime,Message message}){
    this.name = name;
    // if deprecation time is null, set it to 60s
    this.deprecationTime = deprecationTime ?? 60;
    this.message = message;
  }

  // The name of a blackboard, also unique identifier
  String name;

  // The time after a message on the blackboard is deprecated
  int deprecationTime;

  // The content of a blackboard
  Message message;

  // waits till the message is deprecated to call a callback function
  void onTimeout(Function callback) async{


    // won't be deprecated if the message is null or got no timestamp or content
    if (message == null) return null;
    if (message.timestamp == null) return null;
    if (message.content == null) return null;

    int messageTime = message.timestamp + deprecationTime;
    int now = (DateTime.now().millisecondsSinceEpoch / 1000.0).round();

    // in time till the message will timeout in seconds
    int timeToTimeout = messageTime - now;

    // only wait if the time to wait is positive
    if(timeToTimeout > 0){

      // wait
      await Future.delayed(Duration(seconds: timeToTimeout));
      callback();
    }

  }

  // is not implemented as a variable to avoid two values representing
  // the same
  bool isMessageDeprecated(){

    // not deprecated if the message is null or got no timestamp or content
    if (message == null) return false;
    if (message.timestamp == null) return false;
    if (message.content == null) return false;

    // Time to message will be marked as deprecated afterwards
    int messageDeprecationTime = message.timestamp + deprecationTime;

    // The server uses secondsSinceEpoch, which is not supported by dart
    // using millisecondsSinceEpoch and converting
    int now = (DateTime.now().millisecondsSinceEpoch / 1000.0).round();

    // if the time the message will be marked as deprecated is after to current time
    // mark the message as deprecated
    if(messageDeprecationTime <= now) return true;
    return false;

  }

  // Keys for transformation from and to json
  static const KEY_NAME = "name";
  static const KEY_DEPRECATION_TIME = "deprecationTime";
  static const KEY_MESSAGE_TIMESTAMP = "timestamp";
  static const KEY_MESSAGE = "message";

  // Transforms a JSON object to a new instance of the Blackboard class
  // static to be used without having an instance of a Blackboard already
  // --> alternative contractors, as dart doesnt support multiple contractors
  // in other ways
  static Blackboard fromJson(Map<String,dynamic> json){
    String name = json[KEY_NAME];
    int deprecationTime = json[KEY_DEPRECATION_TIME];
    Message message = Message.fromJson(json[KEY_MESSAGE]);

    return Blackboard(name,deprecationTime: deprecationTime,message: message);
  }

  // Transforms an instance of the class Blackboard to json
  Map<String,dynamic> toJson(){

    Map<String,dynamic> messageDoc = {};
    if(message != null) messageDoc = message.toJson();

    return {
      KEY_NAME: name,
      KEY_DEPRECATION_TIME: deprecationTime,
      KEY_MESSAGE: messageDoc,
    };
  }

  // Used for better console prining
  @override
  String toString() {
    return 'Blackboard: {name: ${name}, deprecationTime: ${deprecationTime}, message: ${message}}';
  }
}
