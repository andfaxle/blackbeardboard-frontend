

class BackendConnector{

  Future<Blackboard> getBoard(String name) async {
    await Future.delayed(Duration(milliseconds: 3000));
    return Blackboard("Toller Name");
  }

  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback){

  }

}

class Blackboard{

  Blackboard(this.name);

  final String name;

}