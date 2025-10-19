import 'package:v04/managers/hero_data_managing.dart';
import 'package:v04/models/hero_model.dart';

class SearchResponseModel {
  SearchResponseModel({
    required this.response,
    required this.resultsFor,
    required this.results,
  });

  factory SearchResponseModel.fromJson(
    HeroDataManaging heroDataManaging,
    Map<String, dynamic> json,
  ) {
    var response = json['response'] as String;

    List<HeroModel> results = [];

    if (response == "success") {
      for (var h in (json['results'] as List<dynamic>)) {
        var heroJson = h as Map<String, dynamic>;
        try {
          results.add(heroDataManaging.heroFromJson(heroJson));
        } catch (e) {
          // ignore errors parsing individual heroes
          print("Error parsing hero in search results: $e");
        }
      }
    }

    return SearchResponseModel(
      response: json['response'] as String,
      resultsFor: json['results-for'] as String,
      results: results,
    );
  }

  String response;
  String resultsFor;
  List<HeroModel> results;
}
