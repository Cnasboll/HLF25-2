import 'package:v04/prompts/prompt.dart';
import 'package:dart_dotenv/dart_dotenv.dart';

class Env {
  factory Env() {
    final dotEnv = DotEnv(filePath: filePath);
    var env = dotEnv.getDotEnv();
    bool saveNeeded = false;
    var apiKey = env[apiKeyName] ?? '';
    if (apiKey.isEmpty) {
      apiKey = promptFor('Enter your API key: ');
      if (apiKey.isEmpty) {
        throw Exception("API key is required");
      }
      saveNeeded = true;
    }

    var apiEndpoint = env[apiEndpointName] ?? '';
    if (apiEndpoint.isEmpty) {
      apiEndpoint = promptFor(
        'Enter API endpoint or press enter to accept default ($defaultApiEndpoint): ',
        defaultApiEndpoint,
      );
      saveNeeded = true;
    }

    if (saveNeeded) {
      dotEnv.set(apiKeyName, apiKey);
      dotEnv.set(apiEndpointName, apiEndpoint);
      if (!dotEnv.exists()) {
        dotEnv.createNew();
      }
      dotEnv.saveDotEnv();
    }

    return Env.create(apiKey: apiKey, apiEndpoint: apiEndpoint);
  }

  Env.create({required this.apiKey, required this.apiEndpoint});

  static const String filePath = '.env';
  static const apiKeyName = 'API_KEY';
  static const apiEndpointName = 'API_ENDPOINT';
  static const defaultApiEndpoint = 'https://www.superheroapi.com';

  final String apiKey;
  final String apiEndpoint;
}
