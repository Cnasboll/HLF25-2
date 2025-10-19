import 'package:test/test.dart';
import 'package:v04/managers/hero_data_manager.dart';
import 'package:v04/models/search_response_model.dart';

import 'mock_hero_repository.dart';
import 'mock_hero_service.dart';

void main() async {
  test('Can download Batman', () async {
    var heroService = MockHeroService();
    var heroDataManager = HeroDataManager(MockHeroRepository());
    await heroService.getById("70").then((batmanJsonTuple) {
      var batman = heroDataManager.heroFromJson(batmanJsonTuple.$1!);
      expect(batman, isNotNull);
      expect(batman.name, "Batman");
    });
  });

  test('Can parse all heros', () async {
    var heroService = MockHeroService();
    var heroDataManager = HeroDataManager(MockHeroRepository());
    List<String> failures = [];
    for (int i = 1; i < 731; ++i) {
      await heroService.getById(i.toString()).then((heroJsonTuple) {
        try {
          var hero = heroDataManager.heroFromJson(heroJsonTuple.$1!);
          print("Downloaded hero id $i: ${hero.name}");
        } catch (e) {
          var name = heroJsonTuple.$1!['name'];
          failures.add("Failed to parse hero id $i: $name: $e");
        }
      });
    }
    print("Total failures: ${failures.length}");
    for (var failure in failures) {
      print(failure);
    }
  });

  test('Can search Q', () async {
    var heroService = MockHeroService();
    var heroDataManager = HeroDataManager(MockHeroRepository());
    await heroService.search("q").then((searchResponseJsonTuple) {
      var searchResult = SearchResponseModel.fromJson(
        heroDataManager,
        searchResponseJsonTuple.$1!,
      );
      print(searchResult.results);
    });
  });
}
