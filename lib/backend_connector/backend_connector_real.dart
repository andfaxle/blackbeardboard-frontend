import 'dart:convert';
import 'dart:html';

import 'package:blackbeards_board/error_handling/app_exeption.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'abstract_backend_connector.dart';
import 'package:http/http.dart' as http;

// *** START BACKEND *** :
// asadmin start-domain
// asadmin list-applications
// asadmin undeploy server
// asadmin deploy server


// *** DEPLOY ON AWS ***:

// ssh connection:
// ssh -i "aws_ec2_key.pem" ec2-user@ec2-3-120-228-180.eu-central-1.compute.amazonaws.com
// scp upload:
// scp -i "aws_ec2_key.pem" C:\Informatik\workspaces\flutter_workspace\blackbeardboard_frontend\build\web.zip ec2-user@ec2-3-120-228-180.eu-central-1.compute.amazonaws.com:~
// start frontend server:
// nohup python3 -m http.server & (in "web" directory)

// backend available on 3.120.228.180:8080
// frontend available on 3.120.228.180:8000


// Implementation of an abstract server interface, connects to standard server
class BackendConnectorReal implements BackendConnector{

  // callback functions to receive server log and info messages
  Function(String) onMessage;
  Function(String) onLog;

  // the name of the board for which to listen to updates
  String onBoardChangedName;

  // callbacks functions to receive information when a board has changed or
  // a boards have been added or removed
  Function(Blackboard blackboard) onBoardChangedCallback;
  Function(List<String> name) onBoardsAddedCallback;
  Function(List<String> name) onBoardsRemovedCallback;

  // The port the backend server runs on
  static const String port = "8080";

  // The IP the backend server runs on
  // change IP to 127.0.0.1 to connect to server running on local host
  static const String url = "3.120.228.180" + ":" + port;

  // Entry points of different server functionalities, see documentation
  static const _ENTRY = "/server";
  static const _KEY_ENDPOINT_BOARD = _ENTRY + "/board";
  static const _KEY_ENDPOINT_BOARDS = _ENTRY + "/boards";
  static const _KEY_ENDPOINT_LOCKING = _ENTRY + "/locking";
  static const _KEY_ENDPOINT_LISTEN = "http://"+ url+ _ENTRY + "/listen";

  static const _EVENT_BOARD_CHANGED = "boards_changed";
  static const _EVENT_BOARD_ADDED = "boards_added";
  static const _EVENT_BOARD_DELETED = "boards_deleted";

  // Max time to wait for a server answer in seconds
  static const _TIMEOUT = 10;

  // header for http requests
  // only allow json
  static const Map<String,String> _STANDARD_HEADER = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  BackendConnectorReal(){

    // initialize onLog and onMessage
    // if nobody registers on those callbacks, the Information will be printed
    // to the console
    onLog = (data) => print(data);
    onMessage = (data) => print(data);

    // register to server sided events
    registerToSEE();
  }

  // called if a add event is received by SEE
  void onBoardsAddedEvent(dynamic _data){

    sendLogMessage(_KEY_ENDPOINT_LISTEN,"Received on boards added event");

    // no need to compute is there is no callback registered anyway
    if(onBoardsAddedCallback == null) return;

    // Extract list of boards from the data
    String data = _data.data;
    String string_raw = data.substring(1,data.length-1);
    List<String> nameList= string_raw.split(",");

    // call callback
    onBoardsAddedCallback(nameList);
  }

  // called if a remove event is received by SEE
  void onBoardsRemovedEvent(dynamic _data){

    sendLogMessage(_KEY_ENDPOINT_LISTEN,"Received on boards removed event");

    // no need to compute is there is no callback registered anyway
    if(onBoardsRemovedCallback == null) return;

    // Extract list of boards from the data
    String data = _data.data;
    String string_raw = data.substring(1,data.length-1);
    List<String> nameList= string_raw.split(",");

    // call callback
    onBoardsRemovedCallback(nameList);
  }

  // called if an update event is received by SEE
  void onBoardsChangedEvent(dynamic _data){

    sendLogMessage(_KEY_ENDPOINT_LISTEN,"Received on boards updated event");

    // no need to compute is there is no callback registered anyway
    if(onBoardChangedCallback == null) return;

    // transfer string data to an instance of Blackboard
    String data = _data.data;
    Map<String,dynamic> json = jsonDecode(data)[0];
    Blackboard blackboard = Blackboard.fromJson(json);

    // only call callback if name of the board is the board that the frontend has registered for
    if(blackboard.name == this.onBoardChangedName){
      onBoardChangedCallback(blackboard);
    }
  }

  // start listening to Server Sent Events, register computing functions
  void registerToSEE() async{
    print(_KEY_ENDPOINT_LISTEN);
    EventSource source = EventSource(_KEY_ENDPOINT_LISTEN,withCredentials: false);
    source.addEventListener(_EVENT_BOARD_ADDED, onBoardsAddedEvent);
    source.addEventListener(_EVENT_BOARD_DELETED, onBoardsRemovedEvent);
    source.addEventListener(_EVENT_BOARD_CHANGED, onBoardsChangedEvent);

  }

  // Sends an create blackboard request to the server
  // For status code info, see https://developer.mozilla.org/de/docs/Web/HTTP/Status
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

  // Gets data on an specific board from the server
  // For status code info, see https://developer.mozilla.org/de/docs/Web/HTTP/Status
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
        String body = utf8.decode(response.bodyBytes);
        Map<String,dynamic> jsonBody = jsonDecode(body);
        Blackboard blackboard = Blackboard.fromJson(jsonBody);
        sendLogMessage(_KEY_ENDPOINT_BOARD, "Board retrieved from the server",parameters: params);
        return blackboard;

      }catch(error){
        sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: Unable to compute server answer",parameters: params);
        throw FetchDataException("Unable to compute server answer");
      }
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No board found",parameters: params);
      throw NotFoundException("There is now board with this name");
    }
  }



  // Gets a list of all blackboards, that are currently there
  // For status code info, see https://developer.mozilla.org/de/docs/Web/HTTP/Status
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
      String body = utf8.decode(response.bodyBytes);
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

  // Allows to update the message of a blackboard
  // The message creation timestamp is set by the server
  // For status code info, see https://developer.mozilla.org/de/docs/Web/HTTP/Status
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

  // Deletes a blackboard with the given name
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

  // Deletes all blackboards
  // USE WITH CAUTION!
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

  // frontend can listen for changes of a given blackboard identified by the name
  @override
  void registerOnBoardChange(String name,Function(Blackboard blackboard) callback){
    onBoardChangedName = name;
    onBoardChangedCallback = callback;
  }

  // frontend can listen for new blackboards added
  @override
  void registerOnBoardsAdded(Function(List<String> name) callback){
    onBoardsAddedCallback = callback;
  }

  // frontend can listen for blackboards removed
  @override
  void registerOnBoardsRemoved(Function(List<String> name) callback){
    onBoardsRemovedCallback = callback;
  }

  // formats and sends a log message
  Future sendLogMessage(String endpoint,String message,{Map<String,dynamic> parameters}) async{
    DateTime dateTime = DateTime.now();
    final DateFormat formatter = DateFormat("dd.MM.yyyy HH:mm:ss");
    String dateString = formatter.format(dateTime);

    // if there are parameters, add them to the log message
    String parametersString = "";
    if(parameters != null){
      for(String key in parameters.keys){
        parametersString += "$key=${parameters[key]}\n";
      }
    }

    String logMessage =  dateString + ": @" + endpoint + "\n" + parametersString + message;
    onLog(logMessage);
  }

  // locks the blackboard, so no other user can update it while you are updating it
  // REMEMBER TO CALL UNLOCK BLACKBOARD after finishing!
  @override
  Future<bool> requestBlackboardLock(String name) async{

    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_LOCKING,params);
    sendLogMessage(_KEY_ENDPOINT_LOCKING, "Requesting locking for blackboard",parameters: params);

    Response response = await http.get(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "ERROR: The Server timed out",parameters: params);
      throw FetchDataException("The Server timed out");
    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "ERROR: Unable to connect to the server",parameters: params);
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "Locking permission received",parameters: params);
      return true;
    }else if(response.statusCode ==  400){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No name defined",parameters: params);
      throw BadRequestException(" No name defined");
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No board found",parameters: params);
      throw NotFoundException("There is now board with this name");
    }
    else if(response.statusCode == 403){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "The board is currently locked by another person",parameters: params);
    }

    return false;
  }

  // unlocks a blackboard for others
  @override
  Future requestBlackboardUnlock(String name) async{

    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_LOCKING,params);
    sendLogMessage(_KEY_ENDPOINT_LOCKING, "Requesting to unlock blackboard",parameters: params);

    Response response = await http.post(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "ERROR: The Server timed out",parameters: params);
      throw FetchDataException("The Server timed out");
    }).onError((error, stackTrace){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "ERROR: Unable to connect to the server",parameters: params);
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      sendLogMessage(_KEY_ENDPOINT_LOCKING, "Unlocked board",parameters: params);
    }else if(response.statusCode ==  400){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No name defined",parameters: params);
      throw BadRequestException(" No name defined");
    }else if(response.statusCode == 404){
      sendLogMessage(_KEY_ENDPOINT_BOARD, "ERROR: No board found",parameters: params);
      throw NotFoundException("There is now board with this name");
    }
  }

  // frontend can register here to display info messages
  @override
  void registerBackendInfo(Function(String p1) onBackendInfoMessage) {
    this.onMessage = onBackendInfoMessage;
  }

  // frontend can register here to display log messages
  @override
  void registerBackendLog(Function(String p1) onBackendLogMessage) {
    this.onLog = onBackendLogMessage;
  }

}