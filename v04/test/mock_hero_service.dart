import 'dart:convert';
import 'dart:io';

import 'package:v04/services/hero_servicing.dart';

class MockHeroService implements HeroServicing {
  MockHeroService() : _jsonByHeroId = getJsonByHeroId();

  static Map<String, String> getJsonByHeroId() {
    final dir = Directory('test/heroes');
    final List<FileSystemEntity> entities = dir.listSync().toList();
    Map<String, String> jsonByHeroId = {};
    for (var entity in entities) {
      final fileName = entity.uri.pathSegments.last;
      final List<String> parts = fileName.split('.');
      if (parts.last != 'json' || parts.length < 2) {
        continue;
      }

      final heroId = parts.first;
      final jsonContent = File(entity.path).readAsStringSync();
      jsonByHeroId[heroId] = jsonContent;
    }
    return jsonByHeroId;
  }

  @override
  Future<(Map<String, dynamic>?, String?)> search(String name) async {
    List<Map<String, dynamic>> results = [];
    _jsonByHeroId.forEach((id, json) {
      var decoded = jsonDecode(json) as Map<String, dynamic>;
      if ((decoded['name'] as String).toLowerCase().contains(
        name.toLowerCase(),
      )) {
        results.add(decoded);
      }
    });

    Map<String, dynamic> searchResult;

    if (results.isEmpty) {
      searchResult = {
        "response": "error",
        "error": "character with given name not found",
      };
    } else {
      searchResult = {
        "response": "success",
        "results-for": name,
        "results": results,
      };
    }

    return Future.value((searchResult, null));
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getById(String id) async {
    var json = _jsonByHeroId[id];
    if (json == null) {
      return (null, "Hero not found");
    }

    var hero = jsonDecode(json) as Map<String, dynamic>;
    return Future.value((hero, null));
  }

  final Map<String, String> _jsonByHeroId;
}
