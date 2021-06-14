import 'dart:convert';
import 'dart:html';

import 'package:blackbeards_board/error_handling/app_exeption.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'abstract_backend_connector.dart';
import 'package:http/http.dart' as http;

// asadmin start-domain
// asadmin list-applications
// asadmin undeploy blackbeardboard-backend-1.0-SNAPSHOT
//

class BackendConnectorReal implements BackendConnector{

  Function(String) onMessage;
  Function(String) onLog;

  String onBoardChangedName;
  Function(Blackboard blackboard) onBoardChangedCallback;
  Function(List<String> name) onBoardsAddedCallback;
  Function(List<String> name) onBoardsRemovedCallback;

  static const String url = "localhost:8080";// "10.0.2.2:8080";//
  static const _ENTRY = "/server";
  static const _KEY_ENDPOINT_BOARD = _ENTRY + "/board";
  static const _KEY_ENDPOINT_BOARDS = _ENTRY + "/boards";
  static const _KEY_ENDPOINT_LISTEN = _ENTRY + "/listen";

  static const _EVENT_BOARD_CHANGED = "board_changed";
  static const _EVENT_BOARD_ADDED = "boards_added";
  static const _EVENT_BOARD_DELETED = "boards_deleted";

  // in seconds
  static const _TIMEOUT = 10;

  static const Map<String,String> _STANDARD_HEADER = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const Map<String,String> _EVENTS_HEADER = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Cache-Control': 'no-cache',
  };

  BackendConnectorReal(){
    onLog = (data) => print(data);
    onMessage = (data) => print(data);
    registerToSEE();
  }

  EventSource eventSource;

  void onBoardAddedEvent(dynamic _data){
    String data = _data.data;
    String string_raw = data.substring(1,data.length-1);
    print(string_raw);
    List<String> nameList= string_raw.split(",");
    print(nameList);

    onBoardsAddedCallback(nameList);
  }

  void onBoardRemovedEvent(dynamic _data){
    String data = _data.data;
    String string_raw = data.substring(1,data.length-1);
    print(string_raw);
    List<String> nameList= string_raw.split(",");
    print(nameList);

    onBoardsRemovedCallback(nameList);
  }

  void registerToSEE() async{

    String url = "http://localhost:8080/server/listen";
    EventSource source = EventSource(url,withCredentials: false);
    source.addEventListener(_EVENT_BOARD_ADDED, onBoardAddedEvent);
    source.addEventListener(_EVENT_BOARD_DELETED, onBoardRemovedEvent);

  }
  /*
  http.Client client = http.Client();

http.Request request = http.Request("GET", Uri.parse('your url'));
request.headers["Accept"] = "text/event-stream";
request.headers["Cache-Control"] = "no-cache";

Future<http.StreamedResponse> response = client.send(request);
print("Subscribed!");
response.then((streamedResponse) => streamedResponse.stream.listen((value) {
  final parsedData = utf8.decode(value);
  print(parsedData);

  //event:heartbeat
  //data:{"type":"heartbeat"}
        
  final eventType = parsedData.split("\n")[0].split(":")[1];
  print(eventType);
  //heartbeat
  final realParsedData = json.decode(parsedData.split("data:")[1]) as Map<String, dynamic>;
  if (realParsedData != null) {
  // do something
  }
}, onDone: () => print("The streamresponse is ended"),),);
   */

  List<String> boardListToNames(List<dynamic> boards){
    return boards.map((value) => (Blackboard.fromJson(value)).name).toList();
  }



  @override
  Future createBlackboard(Blackboard blackboard) async {
    Map<String,String> params = {};
    params[Blackboard.KEY_NAME] = blackboard.name;
    params[Blackboard.KEY_DEPRECATION_TIME] = blackboard.deprecationTime.toString();

    Uri uri =  Uri.http(url,  _KEY_ENDPOINT_BOARD,params);
    sendLogMessage(_KEY_ENDPOINT_BOARD, "Sending create request to server",parameters: params);

    Response response = await http.post(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: The Server timed out",parameters: params);
      throw FetchDataException("The Server timed out");
    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to connect to the server",parameters: params);
      throw FetchDataException("Unable to connect to the server");
    });
    if(response.statusCode == 201){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "Board created successfully",parameters: params);
      onMessage("Board created successfully");
    }else if(response.statusCode == 400){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Missing parameters, name or deprecation time",parameters: params);
      throw BadRequestException("Please define name and deprecation time");
    }else if(response.statusCode == 409){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: There is already a board with this name",parameters: params);
      throw BadRequestException("There is already a board with this name");
    }

  }

  @override
  Future<Blackboard> getBoard(String name) async{
    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };
    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,params);
    sendLogMessage(_KEY_ENDPOINT_BOARD, "Requesting board from server",parameters: params);

    Response response = await http.get(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: The Server timed out",parameters: params);
      throw FetchDataException("The Server timed out");
    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to connect to the server",parameters: params);
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){

      try{
        String body = response.body;
        Map<String,dynamic> jsonBody = jsonDecode(body);
        Blackboard blackboard = Blackboard.fromJson(jsonBody);
        sendLogMessage(_KEY_ENDPOINT_BOARD, "Board retrieved from the server",parameters: params);
        return blackboard;

      }catch(error){
        print(error);
        sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to compute server answer",parameters: params);
        throw FetchDataException("Unable to compute server answer");
      }
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No board found",parameters: params);
      throw NotFoundException("There is now board with this name");
    }
  }



  @override
  Future<List<String>> getAllBlackboardNames() async{

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARDS);
    sendLogMessage(_KEY_ENDPOINT_BOARDS, "Loading boards from the server");

    Response response = await http.get(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARDS, "ERROR: The Server timed out");
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARDS, "ERROR: Unable to connect to the server");
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      String body = response.body;

      try{
        List<dynamic> jsonBody = jsonDecode(body);
        List<String> boardNames =  jsonBody.map((value) => value as String).toList();
        sendLogMessage(_KEY_ENDPOINT_BOARDS, "Retrieved list of boards");
        return boardNames;

      }catch(error){
        sendLogMessage(_KEY_ENDPOINT_BOARDS, "ERROR: Unable to compute server answer");
        throw FetchDataException("Unable to compute server answer");
      }
    }
  }

  @override
  Future updateBlackboard(Blackboard blackboard) async {

    Map<String,dynamic> params = {};
    params[Blackboard.KEY_MESSAGE] = blackboard.message.content;
    params[Blackboard.KEY_NAME] = blackboard.name;

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,params);
    sendLogMessage(_KEY_ENDPOINT_BOARD, "Sending update request to the server",parameters: params);

    Response response = await http.put(
      uri,
      headers: _STANDARD_HEADER,
      body: jsonEncode(blackboard.toJson()),
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: The Server timed out");
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to connect to the server");
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "Board was updated successfully");
      onMessage("Board was updated successfully");
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: There is no board with this name");
      throw NotFoundException("There is no board with this name");
    }

  }

  @override
  Future deleteBlackboard(String name) async {
    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };
    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,params);
    sendLogMessage(_KEY_ENDPOINT_BOARD, "Sending delete request to the server",parameters: params);
    Response response = await http.delete(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: The Server timed out",parameters: params);
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to connect to the server",parameters: params);
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "Board deleted successfully",parameters: params);
      onMessage("Board deleted successfully");
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: There is no board with this name",parameters: params);
      throw NotFoundException("There is now board with this name");
    }
  }

  @override
  Future deleteAllBlackboards()async {

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARDS);
    sendLogMessage(_KEY_ENDPOINT_BOARDS, "Sending delete request for all boards to the server");

    Response response = await http.delete(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_BOARDS, "ERROR: The Server timed out");
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_BOARDS, "ERROR: Unable to connect to the serverThe Server timed out");
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      sendLogMessage(_KEY_ENDPOINT_BOARDS, "All boards deleted successfully");
      onMessage("All boards deleted successfully");
    }

  }

  @override
  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback){
    onBoardChangedName = name;
    onBoardChangedCallback = callback;
  }

  @override
  void registerOnBoardsAdded(Function(List<String> name) callback){
    onBoardsAddedCallback = callback;
  }

  @override
  void registerOnBoardsRemoved(Function(List<String> name) callback){
    onBoardsRemovedCallback = callback;
  }

  String sendLogMessage(String endpoint,String message,{Map<String,dynamic> parameters}){
    DateTime dateTime = DateTime.now();
    final DateFormat formatter = DateFormat("dd.MM.yyyy HH:mm:s");
    String dateString = formatter.format(dateTime);

    String parametersString = "";
    if(parameters != null){
      for(String key in parameters.keys){
        parametersString += "$key=${parameters[key]} ";
      }
    }

    String logMessage =  dateString + ": @" + endpoint + " - " + parametersString + " "+ message;
    onLog(logMessage);
  }

  @override
  Future<bool> checkBlackboardLock(String name) {
    // TODO: implement checkBlackboardLock
    throw UnimplementedError();
  }

  @override
  void registerBackendInfo(Function(String p1) onBackendInfoMessage) {
    this.onMessage = onBackendInfoMessage;
  }

  @override
  void registerBackendLog(Function(String p1) onBackendLogMessage) {
    this.onLog = onBackendLogMessage;
  }

}