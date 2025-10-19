import 'dart:convert';

import 'package:v04/env/env.dart';
import 'package:v04/services/hero_servicing.dart';
import 'package:http/http.dart' as http;

class HeroService implements HeroServicing {
  HeroService(this._env);

  String applyApiKey(String path) {
    return "/api.php/${_env.apiKey}/$path";
  }

  Future<(String, int)> fetchRawAsync(String path) async {
    final httpPackageUrl = Uri.https(_env.apiHost, applyApiKey(path));
    return http.get(httpPackageUrl).then((httpPackageResponse) {
      return (httpPackageResponse.body, httpPackageResponse.statusCode);
    });
  }

  Future<(Map<String, dynamic>?, String?)> fetchAsync(String path) async {
    return fetchRawAsync(path).then((bodyAndStatusCode) {
      final (body, statusCode) = bodyAndStatusCode;
      if (statusCode == 200) {
        return (
          json.decode(body) as Map<String, dynamic>,
          null,
        );
      }
      return (null, body);
    });
  }

  @override
  Future<(Map<String, dynamic>?, String?)> search(String name) async {
    return fetchAsync("search/$name");
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getById(String id) async {
    return fetchAsync(id);
  }

  final Env _env;
}
