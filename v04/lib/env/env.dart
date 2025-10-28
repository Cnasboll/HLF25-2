import 'package:v04/terminal/prompt.dart';
import 'package:dart_dotenv/dart_dotenv.dart';

class Env {
  static Future<Env> createAsync() async {
    final dotEnv = DotEnv(filePath: filePath);
    var env = dotEnv.getDotEnv();
    bool saveNeeded = false;
    var apiKey = env[apiKeyName] ?? '';
    if (apiKey.isEmpty) {
      apiKey = await promptFor('Enter your API key: ');
      if (apiKey.isEmpty) {
        throw Exception("API key is required");
      }
      saveNeeded = true;
    }

    var apiEndpoint = env[apiHostName] ?? '';
    if (apiEndpoint.isEmpty) {
      apiEndpoint = await promptFor(
        'Enter API host or press enter to accept default ("$defaultApiHost)": ',
        defaultApiHost,
      );
      saveNeeded = true;
    }

    if (saveNeeded) {
      dotEnv.set(apiKeyName, apiKey);
      dotEnv.set(apiHostName, apiEndpoint);
      if (!dotEnv.exists()) {
        dotEnv.createNew();
      }
      dotEnv.saveDotEnv();
    }

    return Env.create(apiKey: apiKey, apiHost: apiEndpoint);
  }

  Env.create({required this.apiKey, required this.apiHost});

  static const String filePath = '.env';
  static const apiKeyName = 'API_KEY';
  static const apiHostName = 'API_HOST';
  static const defaultApiHost = 'www.superheroapi.com';

  final String apiKey;
  final String apiHost;
}
