import 'package:blackbeards_board/backend_connector/abstract_backend_connector.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'backend_connector/backend_connector_service.dart';

// entrypoint of the application
void main() {

  //initialize Backend
  BackendConnectorService.init(BackendType.REAL);

  //Start UI
  runApp(App());
}
