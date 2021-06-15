
import 'abstract_backend_connector.dart';

// provides a service with a singleton of the BackendConnector
// Everybody can access this singleton after initialisation
class BackendConnectorService{
  static void init(BackendType type){
    _instance = BackendConnector(type);
  }

  static BackendConnector _instance;

  static BackendConnector get instance => _instance;
}
