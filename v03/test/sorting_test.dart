import 'dart:io';

import 'package:v03/managers/hero_data_manager.dart';
import 'package:v03/models/appearance_model.dart';
import 'package:v03/models/biography_model.dart';
import 'package:v03/models/connections_model.dart';
import 'package:v03/models/hero_model.dart';
import 'package:v03/models/image_model.dart';
import 'package:v03/models/power_stats_model.dart';
import 'package:v03/models/work_model.dart';
import 'package:v03/persistence/hero_repository.dart';
import 'package:test/test.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/value_types/weight.dart';

Future<void> main() async {
  test('Sorting test', () {
    
    var batman = HeroModel(
        id: "02ffbb60-762b-4552-8f41-be8aa86869c6",
        version: 1,
        serverId: "70",
        name: "Batman",
        powerStats: PowerStatsModel(
          intelligence: 5
        ),
        biography: BiographyModel(
          fullName: "Bruce Wayne",
          alterEgos: "No alter egos found.",
          aliases: ["Insider", "Matches Malone"],
          placeOfBirth: "Crest Hill, Bristol Township; Gotham County",
          firstAppearance: "Detective Comics #27",
          publisher: "DC Comics",
          alignment: Alignment.mostlyGood,
        ),
        appearance: AppearanceModel(
          gender: Gender.male,
          race: "Human",
          height: Height.parseList(["6'2", "188 cm"]),
          weight: Weight.parseList(["209 lb", "95 kg"]),
          eyeColor: 'blue',
          hairColor: 'black',
        ),
        work: WorkModel(
          occupation: "CEO of Wayne Enterprises",
          base: "Gotham City",
        ),
        connections: ConnectionsModel(
          groupAffiliation: "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
          relatives: "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
        ),
        image: ImageModel(url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg")
      );

    var robin = HeroModel(
        id: "008b98a5-3ce6-4448-99f4-d4ce296fcdfc",
        version: 1,
        serverId: "69",
        name: "Robin",
        powerStats: PowerStatsModel(
          strength: 20,          
        ),
        biography: BiographyModel(
          fullName: "Dick Grayson",
          alterEgos: "Nightwing",
          aliases: ["Robin", "Nightwing"],
          placeOfBirth: "Gotham City",
          firstAppearance: "Detective Comics #38",
          publisher: "DC Comics",
          alignment: Alignment.reasonable,
        ),
        appearance: AppearanceModel(
          gender: Gender.unknown,
          race: "Human",
          height: Height.parseList(["5'10", "178 cm"]),
          weight: Weight.parseList(["159 lb", "72 kg"]),
          eyeColor: 'blue',
          hairColor: 'black',
        ),
        work: WorkModel(
          occupation: "Hero",
          base: "Gotham City",
        ),
        connections: ConnectionsModel(
          groupAffiliation: "Teen Titans, Batman Family",
          relatives: "Bruce Wayne (guardian), Alfred Pennyworth (butler)",
        ),
        image: ImageModel(url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg")
      );

    // Now create a new db instance, read the snapshot, and verify
    // Add Alfred, assign a id
    var alfred = HeroModel(
      id: "5a743508-8c18-4736-b966-d3a059019416",
      version: 1,
      serverId: "68",
      name: "Alfred",
      powerStats: PowerStatsModel(strength: 10),
      biography: BiographyModel(alignment: Alignment.good, fullName: "Alfred Pennyworth"),
      appearance: AppearanceModel(
        gender: Gender.wontSay,
        race: "Human",
        height: Height.parseList(["5'9", "175 cm"]),
        weight: Weight.parseList(["155 lb", "70 kg"]),
      ),
      work: WorkModel(occupation: "Butler", base: "Wayne Manor"),
      connections: ConnectionsModel(
        groupAffiliation: "Wayne Manor",
        relatives: "Bruce Wayne (employer)",
      ),
      image: ImageModel(
        url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      ),
    );

    var heroes = [batman, robin, alfred];
    heroes.sort();
    expect(heroes[0].name, "Robin");
    expect(heroes[1].name, "Alfred");
    expect(heroes[2].name, "Batman");

    alfred = alfred.copyWith(powerStats: alfred.powerStats.copyWith(strength: 30));
    heroes = [batman, robin, alfred];
    heroes.sort();
    expect(heroes[0].name, "Alfred");
    expect(heroes[1].name, "Robin");
    expect(heroes[2].name, "Batman");
  });
}
