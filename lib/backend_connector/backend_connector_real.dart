import 'dart:convert';

import 'package:blackbeards_board/error_handling/app_exeption.dart';
import 'package:blackbeards_board/models/blackboard.dart';
import 'package:http/http.dart';
import 'abstract_backend_connector.dart';
import 'package:http/http.dart' as http;



class BackendConnectorReal implements BackendConnector{

  Function(String) onMessage;

  BackendConnectorReal({Function(String) onMessage}){
    this.onMessage = onMessage;
    registerToSEE();
  }

  void registerToSEE(){

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_LISTEN);

    Stream<Response> stream = http.get(uri,headers: _EVENTS_HEADER).asStream();
    stream.listen((event) { 
      print(event);
    });
  }

  static const String url = "localhost:8080";

  static const _KEY_ENDPOINT_BOARD = "/board";
  static const _KEY_ENDPOINT_BOARDS = "/boards";
  static const _KEY_ENDPOINT_LISTEN = "/listen";

  static const _KEY_EVENT_BOARD_CHANGED = "board_changed";
  static const _KEY_EVENT_BOARD_ADDED = "board_added";
  static const _KEY_EVENT_BOARD_DELETED = "board_deleted";

  // in seconds
  static const _TIMEOUT = 10;

  static const Map<String,String> _STANDARD_HEADER = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static const Map<String,String> _EVENTS_HEADER = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Cache-Control': 'no-cache',
  };

  @override
  Future createBlackboard(Blackboard blackboard) async {

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,blackboard.toParams());

    Response response = await http.post(
      uri,
      headers: _STANDARD_HEADER,
      body: jsonEncode(blackboard.toJson()),

    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      onMessage("Board created successfully");
    }else if(response.statusCode == 400){
      throw BadRequestException("Please define name and deprecation time");
    }else if(response.statusCode == 409){
      throw BadRequestException("There is already a board with this name");
    }

  }

  @override
  Future<Blackboard> getBoard(String name) async{
    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };
    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,params);

    Response response = await http.get(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      String body = response.body;

      try{
        Map<String,dynamic> jsonBody = jsonDecode(body);
        Blackboard blackboard = Blackboard.fromJson(jsonBody);
        return blackboard;

      }catch(error){
        throw FetchDataException("Unable to compute server answer");
      }
    }else if(response.statusCode == 404){
      throw NotFoundException("There is now board with this name");
    }
  }



  @override
  Future<List<String>> getAllBlackboardNames() async{

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARDS);

    Response response = await http.get(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      String body = response.body;

      try{
        List<dynamic> jsonBody = jsonDecode(body);
        return jsonBody.map((value) => value as String).toList();

      }catch(error){
        print(error);
        throw FetchDataException("Unable to compute server answer");
      }
    }
  }

  @override
  Future updateBlackboard(Blackboard blackboard) async {

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,blackboard.toParams());

    Response response = await http.put(
      uri,
      headers: _STANDARD_HEADER,
      body: jsonEncode(blackboard.toJson()),

    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      onMessage("Board was updated successfully");
    }else if(response.statusCode == 404){
      throw NotFoundException("There is no board with this name");
    }

  }

  @override
  Future deleteBlackboard(String name) async {
    Map<String,String> params = {
      Blackboard.KEY_NAME: name
    };
    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARD,params);

    Response response = await http.delete(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      onMessage("Board deleted successfully");
    }else if(response.statusCode == 404){
      throw NotFoundException("There is now board with this name");
    }
  }

  @override
  Future deleteAllBlackboards()async {

    Uri uri =  Uri.http(url, _KEY_ENDPOINT_BOARDS);

    Response response = await http.delete(
      uri,
      headers: _STANDARD_HEADER,
    ).timeout(Duration(seconds: _TIMEOUT),onTimeout: (){
      throw FetchDataException("The Server timed out");

    }).onError((error, stackTrace){
      throw FetchDataException("Unable to connect to the server");
    });

    if(response.statusCode == 200){
      onMessage("All boards deleted successfully");
    }

  }

  @override
  void registerOnBoardsAdded(Function(List<String> name) callback) {

  }

  @override
  void registerOnBoardChange(String name, Function(Blackboard blackboard) callback) {

  }

  @override
  void registerOnBoardsRemoved(Function(List<String> name) callback) {

  }




}