import 'dart:convert';
import 'package:v04/models/appearance_model.dart';
import 'package:v04/models/biography_model.dart';
import 'package:v04/models/hero_model.dart';
import 'package:test/test.dart';
import 'package:v04/utils/json_parsing.dart';
import 'package:v04/value_types/value_type.dart';

void main() {
  test('Can parse batman himself', () {
    final rawJson = '''
{
  "response": "success",
  "id": "70",
  "name": "Batman",
  "powerstats": {
    "intelligence": "100",
    "strength": "26",
    "speed": "27",
    "durability": "50",
    "power": "47",
    "combat": "100"
  },
  "biography": {
    "full-name": "Bruce Wayne",
    "alter-egos": "No alter egos found.",
    "aliases": ["Insider", "Matches Malone"],
    "place-of-birth": "Crest Hill, Bristol Township; Gotham County",
    "first-appearance": "Detective Comics #27",
    "publisher": "DC Comics",
    "alignment": "good"
  },
  "appearance": {
    "gender": "Male",
    "race": "Human",
    "height": ["6'2", "188 cm"],
    "weight": ["210 lb", "95 kg"],
    "eye-color": "blue",
    "hair-color": "black"
  },
  "work": {
    "occupation": "Businessman",
    "base": "Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower"
  },
  "connections": {
    "group-affiliation": "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    "relatives": "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)"
  },
  "image": {
    "url": "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"
  }
}
''';

    var decoded = json.decode(rawJson);
    final batman = HeroModel.fromJsonAndId(decoded, "02ffbb60-762b-4552-8f41-be8aa86869c6");
    expect(batman.id, "02ffbb60-762b-4552-8f41-be8aa86869c6");
    expect(batman.externalId, "70");
    expect(batman.version, 1);
    expect(batman.name, "Batman");

    var powerStats = batman.powerStats;
    expect(powerStats.strength, 26);
    expect(powerStats.speed, 27);
    expect(powerStats.intelligence, 100);
    expect(powerStats.durability, 50);
    expect(powerStats.power, 47);
    expect(powerStats.combat, 100);

    var biography = batman.biography;
    expect(biography.fullName, "Bruce Wayne");
    // Special string literal in the API to indicate no alter egos exist -- treat as null
    expect(biography.alterEgos, null);
    expect(biography.aliases, ["Insider", "Matches Malone"]);
    expect(
      biography.placeOfBirth,
      "Crest Hill, Bristol Township; Gotham County",
    );
    expect(biography.firstAppearance, "Detective Comics #27");
    expect(biography.publisher, "DC Comics");
    expect(biography.alignment, Alignment.good);

    var appearance = batman.appearance;
    expect(appearance.gender, Gender.male);
    expect(appearance.race, "Human");
    var height = appearance.height!;
    // This parsing and verification of integrity between representations of Height and Weight is really the biggest part of this assignment for me.
    // Of couurse it is internally represented in metric but for purposes of formatting the system of units is tied to the value object
    // so the database mapping does write it in the same format as it was original read from the json.
    expect(height.wholeFeetAndWholeInches, (6, 2));
    expect(height.wholeCentimeters, 188);
    expect(height.systemOfUnits, SystemOfUnits.imperial);
    var weight = appearance.weight!;
    expect(weight.wholePounds, 210);
    expect(weight.wholeKilograms, 95);
    expect(weight.systemOfUnits, SystemOfUnits.imperial);
    expect(appearance.eyeColor, "blue");
    expect(appearance.hairColor, "black");

    var work = batman.work;
    expect(work.occupation, "Businessman");
    expect(
      work.base,
      "Batcave, Stately Wayne Manor, Gotham City; Hall of Justice, Justice League Watchtower",
    );
    var connections = batman.connections;
    expect(
      connections.groupAffiliation,
      "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    );
    expect(
      connections.relatives,
      "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
    );
    var image = batman.image;
    expect(
      image.url,
      "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
    );
  });

  test('Can parse single JSON string as list of strings', () {
    final rawJson = '{"weight": "10 kg"}';
    var decoded = json.decode(rawJson);
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg']);
  });

  test('Can parse single String object as list', () {
    var decoded = <String, Object?>{'weight': '10 kg'};
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg']);
  });


  // Special case when the user actually enters a JSON-encoded string on the prompt
  test('Can parse json-encoded String list object as list', () {
    var decoded = <String, Object?>{'weight': '["10 kg", "22 lb"]'};
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg', '22 lb']);
  });

  /// A consequence of the special handling of JSON-encoded strings is that
  /// if the user enters a single JSON-encoded string, that is later wrapped
  /// in JSON, it will be decoded too
  test('Can parse single JSON string encoded as JSON as list of strings', () {
    var decoded = <String, Object?>{'weight': '"10 kg"'};
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg']);
  });

  test('Can parse single in-representating String object as list', () {
    var decoded = <String, Object?>{'height': '188'};
    final result = getNullableStringListFromMap(decoded, 'height');
    expect(result, ['188']);
  });

  test('Can parse json list', () {
    final rawJson = '{"weight": ["10 kg", "22 lb"]}';
    var decoded = json.decode(rawJson);
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg', '22 lb']);
  });

  test('Can parse String list literal', () {
    var decoded = <String, Object?>{'weight': ['10 kg', '22 lb']};
    final result = getNullableStringListFromMap(decoded, 'weight');
    expect(result, ['10 kg', '22 lb']);
  });
}
