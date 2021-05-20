
import 'message.dart';

class Blackboard{

  Blackboard(this.name,this.deprecationTime,this.message);

  // The name of a blackboard, also unique identifier
  String name;

  // The time after a message on the blackboard is deprecated
  int deprecationTime;

  // The content of a blackboard
  Message message;
}
