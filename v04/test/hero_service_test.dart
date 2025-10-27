import 'package:test/test.dart';
import 'package:v04/managers/hero_data_manager.dart';
import 'package:v04/models/search_response_model.dart';
import 'package:v04/value_types/height.dart';
import 'package:v04/value_types/weight.dart';
import 'auto_conflict_resolver.dart';
import 'mock_hero_repository.dart';
import 'mock_hero_service.dart';

void main() async {
  test('Can download Batman', () async {
    var heroService = MockHeroService();
    var heroDataManager = HeroDataManager(MockHeroRepository());
    await heroService.getById("70").then((batmanJsonTuple) {
      var batman = heroDataManager.heroFromJson(batmanJsonTuple.$1!, DateTime.timestamp());
      expect(batman, isNotNull);
      expect(batman.name, "Batman");
    });
  });

  test('Can parse most heros', () async {
    try {
      var heightConflictResolver = Height.conflictResolver = AutoConflictResolver<Height>();
      var weightConflictResolver = Weight.conflictResolver = AutoConflictResolver<Weight>();

      var heroService = MockHeroService();
      var heroDataManager = HeroDataManager(MockHeroRepository());
      List<String> failures = [];
      var timestamp = DateTime.timestamp();
      for (int i = 1; i < 731; ++i) {
        await heroService.getById(i.toString()).then((heroJsonTuple) {
          try {
            heroDataManager.heroFromJson(heroJsonTuple.$1!, timestamp);
          } catch (e) {
            var name = heroJsonTuple.$1!['name'];
            failures.add("Failed to parse hero id $i: $name: $e");
          }
        });
      }
      
      // No conflicts for height expected
      expect(heightConflictResolver.resolutionLog, []);

      // Plenty of conflicts for weight expected
      expect(weightConflictResolver.resolutionLog, ["Conflicting weight information: metric '441 kg' corresponds to '972 lb' after converting back to imperial -- expecting '444 kg' in order to match first value of '980 lb'. Resolving by using first provided (imperial) value for weight: '980 lb'.",
"Conflicting weight information: metric '441 kg' corresponds to '972 lb' after converting back to imperial -- expecting '444 kg' in order to match first value of '980 lb'. Resolving by using first provided (imperial) value for weight: '980 lb'.",
"Conflicting weight information: metric '81 kg' corresponds to '179 lb' after converting back to imperial -- expecting '82 kg' in order to match first value of '181 lb'. Resolving by using first provided (imperial) value for weight: '181 lb'.",
"Conflicting weight information: metric '90 kg' corresponds to '198 lb' after converting back to imperial -- expecting '91 kg' in order to match first value of '201 lb'. Resolving by using first provided (imperial) value for weight: '201 lb'.",
"Conflicting weight information: metric '169 kg' corresponds to '373 lb' after converting back to imperial -- expecting '170 kg' in order to match first value of '375 lb'. Resolving by using first provided (imperial) value for weight: '375 lb'.",
"Conflicting weight information: metric '173 kg' corresponds to '381 lb' after converting back to imperial -- expecting '174 kg' in order to match first value of '385 lb'. Resolving by using first provided (imperial) value for weight: '385 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '358 kg' corresponds to '789 lb' after converting back to imperial -- expecting '360 kg' in order to match first value of '795 lb'. Resolving by using first provided (imperial) value for weight: '795 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '146 kg' corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb'. Resolving by using first provided (imperial) value for weight: '325 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '126 kg' corresponds to '278 lb' after converting back to imperial -- expecting '127 kg' in order to match first value of '280 lb'. Resolving by using first provided (imperial) value for weight: '280 lb'.",
"Conflicting weight information: metric '180 kg' corresponds to '397 lb' after converting back to imperial -- expecting '181 kg' in order to match first value of '400 lb'. Resolving by using first provided (imperial) value for weight: '400 lb'.",
"Conflicting weight information: metric '181 kg' corresponds to '399 lb' after converting back to imperial -- expecting '182 kg' in order to match first value of '402 lb'. Resolving by using first provided (imperial) value for weight: '402 lb'.",
"Conflicting weight information: metric '216 kg' corresponds to '476 lb' after converting back to imperial -- expecting '217 kg' in order to match first value of '480 lb'. Resolving by using first provided (imperial) value for weight: '480 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '155 kg' corresponds to '342 lb' after converting back to imperial -- expecting '156 kg' in order to match first value of '345 lb'. Resolving by using first provided (imperial) value for weight: '345 lb'.",
"Conflicting weight information: metric '230 kg' corresponds to '507 lb' after converting back to imperial -- expecting '231 kg' in order to match first value of '510 lb'. Resolving by using first provided (imperial) value for weight: '510 lb'.",
"Conflicting weight information: metric '495 kg' corresponds to '1091 lb' after converting back to imperial -- expecting '498 kg' in order to match first value of '1100 lb'. Resolving by using first provided (imperial) value for weight: '1100 lb'.",
"Conflicting weight information: metric '110 kg' corresponds to '243 lb' after converting back to imperial -- expecting '111 kg' in order to match first value of '245 lb'. Resolving by using first provided (imperial) value for weight: '245 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '81 kg' corresponds to '179 lb' after converting back to imperial -- expecting '82 kg' in order to match first value of '181 lb'. Resolving by using first provided (imperial) value for weight: '181 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '170 kg' corresponds to '375 lb' after converting back to imperial -- expecting '171 kg' in order to match first value of '378 lb'. Resolving by using first provided (imperial) value for weight: '378 lb'.",
"Conflicting weight information: metric '225 kg' corresponds to '496 lb' after converting back to imperial -- expecting '226 kg' in order to match first value of '500 lb'. Resolving by using first provided (imperial) value for weight: '500 lb'.",
"Conflicting weight information: metric '173 kg' corresponds to '381 lb' after converting back to imperial -- expecting '174 kg' in order to match first value of '385 lb'. Resolving by using first provided (imperial) value for weight: '385 lb'.",
"Conflicting weight information: metric '817 kg' corresponds to '1801 lb' after converting back to imperial -- expecting '823 kg' in order to match first value of '1815 lb'. Resolving by using first provided (imperial) value for weight: '1815 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '90 kg' corresponds to '198 lb' after converting back to imperial -- expecting '91 kg' in order to match first value of '201 lb'. Resolving by using first provided (imperial) value for weight: '201 lb'.",
"Conflicting weight information: metric '178 kg' corresponds to '392 lb' after converting back to imperial -- expecting '179 kg' in order to match first value of '395 lb'. Resolving by using first provided (imperial) value for weight: '395 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '383 kg' corresponds to '844 lb' after converting back to imperial -- expecting '385 kg' in order to match first value of '850 lb'. Resolving by using first provided (imperial) value for weight: '850 lb'.",
"Conflicting weight information: metric '171 kg' corresponds to '377 lb' after converting back to imperial -- expecting '172 kg' in order to match first value of '380 lb'. Resolving by using first provided (imperial) value for weight: '380 lb'.",
"Conflicting weight information: metric '187 kg' corresponds to '412 lb' after converting back to imperial -- expecting '188 kg' in order to match first value of '415 lb'. Resolving by using first provided (imperial) value for weight: '415 lb'.",
"Conflicting weight information: metric '110 kg' corresponds to '243 lb' after converting back to imperial -- expecting '111 kg' in order to match first value of '245 lb'. Resolving by using first provided (imperial) value for weight: '245 lb'.",
"Conflicting weight information: metric '412 kg' corresponds to '908 lb' after converting back to imperial -- expecting '415 kg' in order to match first value of '915 lb'. Resolving by using first provided (imperial) value for weight: '915 lb'.",
"Conflicting weight information: metric '306 kg' corresponds to '675 lb' after converting back to imperial -- expecting '308 kg' in order to match first value of '680 lb'. Resolving by using first provided (imperial) value for weight: '680 lb'.",
"Conflicting weight information: metric '203 kg' corresponds to '448 lb' after converting back to imperial -- expecting '205 kg' in order to match first value of '452 lb'. Resolving by using first provided (imperial) value for weight: '452 lb'.",
"Conflicting weight information: metric '96 kg' corresponds to '212 lb' after converting back to imperial -- expecting '97 kg' in order to match first value of '214 lb'. Resolving by using first provided (imperial) value for weight: '214 lb'.",
"Conflicting weight information: metric '18 tons' corresponds to '39683 lb' after converting back to imperial -- expecting '18143 kg' in order to match first value of '40000 lb'. Resolving by using first provided (imperial) value for weight: '40000 lb'.",
"Conflicting weight information: metric '16 tons' corresponds to '35274 lb' after converting back to imperial -- expecting '16510 kg' in order to match first value of '36400 lb'. Resolving by using first provided (imperial) value for weight: '36400 lb'.",
"Conflicting weight information: metric '630 kg' corresponds to '1389 lb' after converting back to imperial -- expecting '635 kg' in order to match first value of '1400 lb'. Resolving by using first provided (imperial) value for weight: '1400 lb'.",
"Conflicting weight information: metric '268 kg' corresponds to '591 lb' after converting back to imperial -- expecting '269 kg' in order to match first value of '595 lb'. Resolving by using first provided (imperial) value for weight: '595 lb'.",
"Conflicting weight information: metric '90,000 tons' corresponds to '198416036 lb' after converting back to imperial -- expecting '90718474 kg' in order to match first value of '200000000 lb'. Resolving by using first provided (imperial) value for weight: '200000000 lb'.",
"Conflicting weight information: metric '270 kg' corresponds to '595 lb' after converting back to imperial -- expecting '272 kg' in order to match first value of '600 lb'. Resolving by using first provided (imperial) value for weight: '600 lb'.",
"Conflicting weight information: metric '115 kg' corresponds to '254 lb' after converting back to imperial -- expecting '116 kg' in order to match first value of '256 lb'. Resolving by using first provided (imperial) value for weight: '256 lb'.",
"Conflicting weight information: metric '4 tons' corresponds to '8818 lb' after converting back to imperial -- expecting '3719 kg' in order to match first value of '8200 lb'. Resolving by using first provided (imperial) value for weight: '8200 lb'.",
"Conflicting weight information: metric '225 kg' corresponds to '496 lb' after converting back to imperial -- expecting '226 kg' in order to match first value of '500 lb'. Resolving by using first provided (imperial) value for weight: '500 lb'.",
"Conflicting weight information: metric '146 kg' corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb'. Resolving by using first provided (imperial) value for weight: '325 lb'.",
"Conflicting weight information: metric '630 kg' corresponds to '1389 lb' after converting back to imperial -- expecting '635 kg' in order to match first value of '1400 lb'. Resolving by using first provided (imperial) value for weight: '1400 lb'.",
"Conflicting weight information: metric '77 kg' corresponds to '170 lb' after converting back to imperial -- expecting '78 kg' in order to match first value of '172 lb'. Resolving by using first provided (imperial) value for weight: '172 lb'.",
"Conflicting weight information: metric '119 kg' corresponds to '262 lb' after converting back to imperial -- expecting '120 kg' in order to match first value of '265 lb'. Resolving by using first provided (imperial) value for weight: '265 lb'.",
"Conflicting weight information: metric '207 kg' corresponds to '456 lb' after converting back to imperial -- expecting '208 kg' in order to match first value of '460 lb'. Resolving by using first provided (imperial) value for weight: '460 lb'.",
"Conflicting weight information: metric '191 kg' corresponds to '421 lb' after converting back to imperial -- expecting '192 kg' in order to match first value of '425 lb'. Resolving by using first provided (imperial) value for weight: '425 lb'.",
"Conflicting weight information: metric '2 tons' corresponds to '4409 lb' after converting back to imperial -- expecting '1918 kg' in order to match first value of '4230 lb'. Resolving by using first provided (imperial) value for weight: '4230 lb'.",
"Conflicting weight information: metric '14 kg' corresponds to '31 lb' after converting back to imperial -- expecting '13 kg' in order to match first value of '30 lb'. Resolving by using first provided (imperial) value for weight: '30 lb'.",
"Conflicting weight information: metric '90 kg' corresponds to '198 lb' after converting back to imperial -- expecting '91 kg' in order to match first value of '201 lb'. Resolving by using first provided (imperial) value for weight: '201 lb'.",
"Conflicting weight information: metric '86 kg' corresponds to '190 lb' after converting back to imperial -- expecting '87 kg' in order to match first value of '192 lb'. Resolving by using first provided (imperial) value for weight: '192 lb'.",
"Conflicting weight information: metric '855 kg' corresponds to '1885 lb' after converting back to imperial -- expecting '861 kg' in order to match first value of '1900 lb'. Resolving by using first provided (imperial) value for weight: '1900 lb'.",
"Conflicting weight information: metric '356 kg' corresponds to '785 lb' after converting back to imperial -- expecting '358 kg' in order to match first value of '790 lb'. Resolving by using first provided (imperial) value for weight: '790 lb'.",
"Conflicting weight information: metric '324 kg' corresponds to '714 lb' after converting back to imperial -- expecting '326 kg' in order to match first value of '720 lb'. Resolving by using first provided (imperial) value for weight: '720 lb'.",
"Conflicting weight information: metric '9,000 tons' corresponds to '19841604 lb' after converting back to imperial -- expecting '9071847 kg' in order to match first value of '20000000 lb'. Resolving by using first provided (imperial) value for weight: '20000000 lb'.",
"Conflicting weight information: metric '203 kg' corresponds to '448 lb' after converting back to imperial -- expecting '204 kg' in order to match first value of '450 lb'. Resolving by using first provided (imperial) value for weight: '450 lb'.",
"Conflicting weight information: metric '360 kg' corresponds to '794 lb' after converting back to imperial -- expecting '362 kg' in order to match first value of '800 lb'. Resolving by using first provided (imperial) value for weight: '800 lb'.",
"Conflicting weight information: metric '230 kg' corresponds to '507 lb' after converting back to imperial -- expecting '231 kg' in order to match first value of '510 lb'. Resolving by using first provided (imperial) value for weight: '510 lb'.",
"Conflicting weight information: metric '288 kg' corresponds to '635 lb' after converting back to imperial -- expecting '290 kg' in order to match first value of '640 lb'. Resolving by using first provided (imperial) value for weight: '640 lb'.",
"Conflicting weight information: metric '236 kg' corresponds to '520 lb' after converting back to imperial -- expecting '238 kg' in order to match first value of '525 lb'. Resolving by using first provided (imperial) value for weight: '525 lb'.",
"Conflicting weight information: metric '191 kg' corresponds to '421 lb' after converting back to imperial -- expecting '192 kg' in order to match first value of '425 lb'. Resolving by using first provided (imperial) value for weight: '425 lb'.",
"Conflicting weight information: metric '383 kg' corresponds to '844 lb' after converting back to imperial -- expecting '385 kg' in order to match first value of '850 lb'. Resolving by using first provided (imperial) value for weight: '850 lb'.",
"Conflicting weight information: metric '225 kg' corresponds to '496 lb' after converting back to imperial -- expecting '226 kg' in order to match first value of '500 lb'. Resolving by using first provided (imperial) value for weight: '500 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '128 kg' corresponds to '282 lb' after converting back to imperial -- expecting '129 kg' in order to match first value of '285 lb'. Resolving by using first provided (imperial) value for weight: '285 lb'.",
"Conflicting weight information: metric '338 kg' corresponds to '745 lb' after converting back to imperial -- expecting '340 kg' in order to match first value of '750 lb'. Resolving by using first provided (imperial) value for weight: '750 lb'.",
"Conflicting weight information: metric '248 kg' corresponds to '547 lb' after converting back to imperial -- expecting '249 kg' in order to match first value of '550 lb'. Resolving by using first provided (imperial) value for weight: '550 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '125 kg' corresponds to '276 lb' after converting back to imperial -- expecting '126 kg' in order to match first value of '278 lb'. Resolving by using first provided (imperial) value for weight: '278 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '99 kg' corresponds to '218 lb' after converting back to imperial -- expecting '100 kg' in order to match first value of '221 lb'. Resolving by using first provided (imperial) value for weight: '221 lb'.",
"Conflicting weight information: metric '293 kg' corresponds to '646 lb' after converting back to imperial -- expecting '294 kg' in order to match first value of '650 lb'. Resolving by using first provided (imperial) value for weight: '650 lb'.",
"Conflicting weight information: metric '191 kg' corresponds to '421 lb' after converting back to imperial -- expecting '192 kg' in order to match first value of '425 lb'. Resolving by using first provided (imperial) value for weight: '425 lb'.",
"Conflicting weight information: metric '405 kg' corresponds to '893 lb' after converting back to imperial -- expecting '408 kg' in order to match first value of '900 lb'. Resolving by using first provided (imperial) value for weight: '900 lb'.",
"Conflicting weight information: metric '234 kg' corresponds to '516 lb' after converting back to imperial -- expecting '235 kg' in order to match first value of '520 lb'. Resolving by using first provided (imperial) value for weight: '520 lb'.",
"Conflicting weight information: metric '630 kg' corresponds to '1389 lb' after converting back to imperial -- expecting '635 kg' in order to match first value of '1400 lb'. Resolving by using first provided (imperial) value for weight: '1400 lb'.",
"Conflicting weight information: metric '146 kg' corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb'. Resolving by using first provided (imperial) value for weight: '325 lb'.",
"Conflicting weight information: metric '320 kg' corresponds to '705 lb' after converting back to imperial -- expecting '322 kg' in order to match first value of '710 lb'. Resolving by using first provided (imperial) value for weight: '710 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '171 kg' corresponds to '377 lb' after converting back to imperial -- expecting '172 kg' in order to match first value of '380 lb'. Resolving by using first provided (imperial) value for weight: '380 lb'.",
"Conflicting weight information: metric '203 kg' corresponds to '448 lb' after converting back to imperial -- expecting '204 kg' in order to match first value of '450 lb'. Resolving by using first provided (imperial) value for weight: '450 lb'.",
"Conflicting weight information: metric '900 kg' corresponds to '1984 lb' after converting back to imperial -- expecting '907 kg' in order to match first value of '2000 lb'. Resolving by using first provided (imperial) value for weight: '2000 lb'.",
"Conflicting weight information: metric '310 kg' corresponds to '683 lb' after converting back to imperial -- expecting '312 kg' in order to match first value of '689 lb'. Resolving by using first provided (imperial) value for weight: '689 lb'.",
"Conflicting weight information: metric '315 kg' corresponds to '694 lb' after converting back to imperial -- expecting '317 kg' in order to match first value of '700 lb'. Resolving by using first provided (imperial) value for weight: '700 lb'.",
"Conflicting weight information: metric '153 kg' corresponds to '337 lb' after converting back to imperial -- expecting '154 kg' in order to match first value of '340 lb'. Resolving by using first provided (imperial) value for weight: '340 lb'.",
"Conflicting weight information: metric '191 kg' corresponds to '421 lb' after converting back to imperial -- expecting '192 kg' in order to match first value of '425 lb'. Resolving by using first provided (imperial) value for weight: '425 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '180 kg' corresponds to '397 lb' after converting back to imperial -- expecting '181 kg' in order to match first value of '400 lb'. Resolving by using first provided (imperial) value for weight: '400 lb'.",
"Conflicting weight information: metric '437 kg' corresponds to '963 lb' after converting back to imperial -- expecting '440 kg' in order to match first value of '971 lb'. Resolving by using first provided (imperial) value for weight: '971 lb'.",
"Conflicting weight information: metric '405 kg' corresponds to '893 lb' after converting back to imperial -- expecting '408 kg' in order to match first value of '900 lb'. Resolving by using first provided (imperial) value for weight: '900 lb'.",
"Conflicting weight information: metric '91 kg' corresponds to '201 lb' after converting back to imperial -- expecting '92 kg' in order to match first value of '203 lb'. Resolving by using first provided (imperial) value for weight: '203 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '146 kg' corresponds to '322 lb' after converting back to imperial -- expecting '147 kg' in order to match first value of '325 lb'. Resolving by using first provided (imperial) value for weight: '325 lb'.",
"Conflicting weight information: metric '198 kg' corresponds to '437 lb' after converting back to imperial -- expecting '199 kg' in order to match first value of '440 lb'. Resolving by using first provided (imperial) value for weight: '440 lb'.",
"Conflicting weight information: metric '443 kg' corresponds to '977 lb' after converting back to imperial -- expecting '446 kg' in order to match first value of '985 lb'. Resolving by using first provided (imperial) value for weight: '985 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '225 kg' corresponds to '496 lb' after converting back to imperial -- expecting '226 kg' in order to match first value of '500 lb'. Resolving by using first provided (imperial) value for weight: '500 lb'.",
"Conflicting weight information: metric '288 kg' corresponds to '635 lb' after converting back to imperial -- expecting '290 kg' in order to match first value of '640 lb'. Resolving by using first provided (imperial) value for weight: '640 lb'.",
"Conflicting weight information: metric '101 kg' corresponds to '223 lb' after converting back to imperial -- expecting '102 kg' in order to match first value of '225 lb'. Resolving by using first provided (imperial) value for weight: '225 lb'.",
"Conflicting weight information: metric '288 kg' corresponds to '635 lb' after converting back to imperial -- expecting '290 kg' in order to match first value of '640 lb'. Resolving by using first provided (imperial) value for weight: '640 lb'.",
"Conflicting weight information: metric '203 kg' corresponds to '448 lb' after converting back to imperial -- expecting '204 kg' in order to match first value of '450 lb'. Resolving by using first provided (imperial) value for weight: '450 lb'.",
"Conflicting weight information: metric '331 kg' corresponds to '730 lb' after converting back to imperial -- expecting '333 kg' in order to match first value of '735 lb'. Resolving by using first provided (imperial) value for weight: '735 lb'.",
"Conflicting weight information: metric '58 tons' corresponds to '127868 lb' after converting back to imperial -- expecting '58059 kg' in order to match first value of '128000 lb'. Resolving by using first provided (imperial) value for weight: '128000 lb'.",
"Conflicting weight information: metric '214 kg' corresponds to '472 lb' after converting back to imperial -- expecting '215 kg' in order to match first value of '475 lb'. Resolving by using first provided (imperial) value for weight: '475 lb'.",
"Conflicting weight information: metric '334 kg' corresponds to '736 lb' after converting back to imperial -- expecting '336 kg' in order to match first value of '742 lb'. Resolving by using first provided (imperial) value for weight: '742 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '162 kg' corresponds to '357 lb' after converting back to imperial -- expecting '163 kg' in order to match first value of '360 lb'. Resolving by using first provided (imperial) value for weight: '360 lb'.",
"Conflicting weight information: metric '473 kg' corresponds to '1043 lb' after converting back to imperial -- expecting '476 kg' in order to match first value of '1050 lb'. Resolving by using first provided (imperial) value for weight: '1050 lb'.",
"Conflicting weight information: metric '135 kg' corresponds to '298 lb' after converting back to imperial -- expecting '136 kg' in order to match first value of '300 lb'. Resolving by using first provided (imperial) value for weight: '300 lb'.",
"Conflicting weight information: metric '171 kg' corresponds to '377 lb' after converting back to imperial -- expecting '172 kg' in order to match first value of '380 lb'. Resolving by using first provided (imperial) value for weight: '380 lb'.",]);

      // There are two known parsing failures for powerstats fields over 100%:
      expect(failures, [
        "Failed to parse hero id 43: Ares: FormatException: Percentage value must be between 0 and 100, got: 101",
        "Failed to parse hero id 631: Stardust: FormatException: Percentage value must be between 0 and 100, got: 110",
      ]);
    } finally {
      Height.conflictResolver = null;
      Weight.conflictResolver = null;
    }
  });
}
