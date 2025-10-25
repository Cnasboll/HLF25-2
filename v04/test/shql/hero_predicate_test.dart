import 'package:v04/models/appearance_model.dart';
import 'package:v04/models/biography_model.dart';
import 'package:v04/models/connections_model.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/models/image_model.dart';
import 'package:v04/models/power_stats_model.dart';
import 'package:v04/models/work_model.dart';
import 'package:test/test.dart';
import 'package:v04/shql/calculator/calculator.dart';
import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/value_types/height.dart';
import 'package:v04/value_types/percentage.dart';
import 'package:v04/value_types/value_type.dart';
import 'package:v04/value_types/weight.dart';

final DateTime deadline = DateTime.parse("2025-10-28T18:00:00.000000Z");

Future<void> main() async {
  test('Can reason about Batman', () {
    var batman = HeroModel(
      id: "02ffbb60-762b-4552-8f41-be8aa86869c6",
      version: 1,
      timestamp: deadline,
      locked: false,
      externalId: "70",
      name: "Batman",
      powerStats: PowerStatsModel(intelligence: Percentage(5)),
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
        groupAffiliation:
            "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
        relatives:
            "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
      ),
      image: ImageModel(
        url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      ),
    );

    var robin = HeroModel(
      id: "008b98a5-3ce6-4448-99f4-d4ce296fcdfc",
      version: 1,
      timestamp: deadline,
      locked: false,
      externalId: "69",
      name: "Robin",
      powerStats: PowerStatsModel(strength: Percentage(20)),
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
      work: WorkModel(occupation: "Hero", base: "Gotham City"),
      connections: ConnectionsModel(
        groupAffiliation: "Teen Titans, Batman Family",
        relatives: "Bruce Wayne (guardian), Alfred Pennyworth (butler)",
      ),
      image: ImageModel(
        url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      ),
    );

    // Now create a new db instance, read the snapshot, and verify
    // Add Alfred, assign a id
    var alfred = HeroModel(
      id: "5a743508-8c18-4736-b966-d3a059019416",
      timestamp: deadline,
      version: 1,
      locked: false,
      externalId: "68",
      name: "Alfred",
      powerStats: PowerStatsModel(strength: Percentage(10)),
      biography: BiographyModel(
        alignment: Alignment.good,
        fullName: "Alfred Pennyworth",
      ),
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

    ConstantsSet constantsSet = Calculator.prepareConstantsSet();
    constantsSet.registerEnum<Alignment>(Alignment.values);
    constantsSet.registerEnum<Gender>(Gender.values);
    constantsSet.registerEnum<SystemOfUnits>(SystemOfUnits.values);

    // Hero scope inherits from root
    ConstantsSet heroScope = constantsSet.createChild();

    HeroModel.declareIdentifiers(heroScope);
    batman.registerIdentifiers(heroScope);

    expect(Calculator.calculate('unknown', constantsSet: heroScope), 0);
    expect(Calculator.calculate('neutral', constantsSet: heroScope), 1);
    expect(Calculator.calculate('mostlyGood', constantsSet: heroScope), 2);
    expect(Calculator.calculate('good', constantsSet: heroScope), 3);
    expect(Calculator.calculate('reasonable', constantsSet: heroScope), 4);
    expect(Calculator.calculate('notQuite', constantsSet: heroScope), 5);
    expect(Calculator.calculate('bad', constantsSet: heroScope), 6);
    expect(Calculator.calculate('ugly', constantsSet: heroScope), 7);
    expect(Calculator.calculate('evil', constantsSet: heroScope), 8);
    expect(Calculator.calculate('usingMobileSpeakerOnPublicTransport', constantsSet: heroScope), 9);

    expect(Calculator.calculate('unknown', constantsSet: heroScope), 0);
    expect(Calculator.calculate('ambiguous', constantsSet: heroScope), 1);
    expect(Calculator.calculate('male', constantsSet: heroScope), 2);
    expect(Calculator.calculate('female', constantsSet: heroScope), 3);
    expect(Calculator.calculate('nonBinary', constantsSet: heroScope), 4);
    expect(Calculator.calculate('wontSay', constantsSet: heroScope), 5);

    expect(Calculator.calculate('metric', constantsSet: heroScope), 0);
    expect(Calculator.calculate('imperial', constantsSet: heroScope), 1);

    expect(Calculator.calculate('id', constantsSet: heroScope), "02ffbb60-762b-4552-8f41-be8aa86869c6");
    expect(Calculator.calculate('version', constantsSet: heroScope), 1);
    expect(Calculator.calculate('timestamp', constantsSet: heroScope), "2025-10-28T18:00:00.000Z");
    expect(Calculator.calculate("locked", constantsSet: heroScope), 0);
    expect(Calculator.calculate('name', constantsSet: heroScope), "Batman");

    /*expect("Bruce Wayne", Calculator.calculate('biography.full_name', constantsSet: constantsSet));
    expect(5, Calculator.calculate('powerstats.intelligence', constantsSet: constantsSet));
    expect(6, Calculator.calculate('powerstats.strength', constantsSet: constantsSet));
    expect(7, Calculator.calculate('powerstats.speed', constantsSet: constantsSet));
    expect(8, Calculator.calculate('powerstats.durability', constantsSet: constantsSet));*/

    /*for (var field in HeroModel.generateSqliteColumnNameList()) {
      constantsSet.identifiers.include(field.sqlite);
    }

    final idIdentifier = constantsSet.identifiers.include("id");
    final externalIdIdentifier = constantsSet.identifiers.include("external_id");
    final versionIdentifier = constantsSet.identifiers.include("version");
    final timestampIdentifier = constantsSet.identifiers.include("timestamp");
    final lockedIdentifier = constantsSet.identifiers.include("locked");
    final nameIdentifier = constantsSet.identifiers.include("name");

    final powerStatsIdentifier = constantsSet.identifiers.include("powerstats");
    final intelligenceIdentifier = constantsSet.identifiers.include("intelligence");
    final strengthIdentifier = constantsSet.identifiers.include("strength");
    final speedIdentifier = constantsSet.identifiers.include("speed");
    final durabilityIdentifier = constantsSet.identifiers.include("durability");
    final powerIdentifier = constantsSet.identifiers.include("power");
    final combatIdentifier = constantsSet.identifiers.include("combat");

    final biographyIdentifier = constantsSet.identifiers.include("biography");
    final fullNameIdentifier = constantsSet.identifiers.include("full_name");
    final alterEgosIdentifier = constantsSet.identifiers.include("alter_egos");
    final aliasesIdentifier = constantsSet.identifiers.include("aliases");
    final placeOfBirthIdentifier = constantsSet.identifiers.include("place_of_birth");
    final firstAppearanceIdentifier = constantsSet.identifiers.include("first_appearance");
    final publisherIdentifier = constantsSet.identifiers.include("publisher");
    final alignmentIdentifier = constantsSet.identifiers.include("alignment");


    final appearanceIdentifier = constantsSet.identifiers.include("appearance");
    final genderIdentifier = constantsSet.identifiers.include("gender");
    final raceIdentifier = constantsSet.identifiers.include("race");
    final heightMetresIdentifier = constantsSet.identifiers.include("height_m");
    final heightSystemOfUnitsIdentifier = constantsSet.identifiers.include("height_system_of_units");
    final weightKilogramsIdentifier = constantsSet.identifiers.include("weight_kg");
    final weightSystemOfUnitsIdentifier = constantsSet.identifiers.include("weight_system_of_units");
    final eyeColorIdentifier = constantsSet.identifiers.include("eye_color");
    final hairColorIdentifier = constantsSet.identifiers.include("hair_color");

    final workIdentifier = constantsSet.identifiers.include("work");
    final occupationIdentifier = constantsSet.identifiers.include("occupation");
    final baseIdentifier = constantsSet.identifiers.include("base");

    final connectionsIdentifier = constantsSet.identifiers.include("connections");
    final groupAffiliationIdentifier = constantsSet.identifiers.include("group_affiliation");
    final relativesIdentifier = constantsSet.identifiers.include("relatives");

    final imageIdentifier = constantsSet.identifiers.include("image");
    final urlIdentifier = constantsSet.identifiers.include("url");

    ConstantsSet heroScope = constantsSet.createChild();
    heroScope.constants.register(batman.id, idIdentifier);
    heroScope.constants.register(batman.externalId, externalIdIdentifier);
    heroScope.constants.register(batman.version, versionIdentifier);
    heroScope.constants.register(batman.timestamp.toIso8601String(), timestampIdentifier);
    heroScope.constants.register(batman.locked, lockedIdentifier);
    heroScope.constants.register(batman.name, nameIdentifier);

    ConstantsSet powerStatsScope = heroScope.getSubModelScope(powerStatsIdentifier);
    powerStatsScope.constants.register(batman.powerStats.intelligence?.value ?? 0, intelligenceIdentifier);
    powerStatsScope.constants.register(batman.powerStats.strength?.value ?? 0, strengthIdentifier);
    powerStatsScope.constants.register(batman.powerStats.speed?.value ?? 0, speedIdentifier);
    powerStatsScope.constants.register(batman.powerStats.durability?.value ?? 0, durabilityIdentifier);
    powerStatsScope.constants.register(batman.powerStats.power?.value ?? 0, powerIdentifier);
    powerStatsScope.constants.register(batman.powerStats.combat?.value ?? 0, combatIdentifier);

    ConstantsSet biographyScope = heroScope.getSubModelScope(biographyIdentifier);
    biographyScope.constants.register(batman.biography.fullName, fullNameIdentifier);
    biographyScope.constants.register(batman.biography.alterEgos, alterEgosIdentifier);
    biographyScope.constants.register(batman.biography.aliases, aliasesIdentifier);
    biographyScope.constants.register(batman.biography.placeOfBirth, placeOfBirthIdentifier);
    biographyScope.constants.register(batman.biography.firstAppearance, firstAppearanceIdentifier);
    biographyScope.constants.register(batman.biography.publisher, publisherIdentifier);
    biographyScope.constants.register(batman.biography.alignment.name, alignmentIdentifier);

    ConstantsSet appearanceScope = heroScope.getSubModelScope(appearanceIdentifier);
    appearanceScope.constants.register(batman.appearance.gender.index, genderIdentifier);
    appearanceScope.constants.register(batman.appearance.race, raceIdentifier);
    appearanceScope.constants.register(batman.appearance.height.value, heightMetresIdentifier);
    appearanceScope.constants.register(batman.appearance.height.systemOfUnits.index, heightSystemOfUnitsIdentifier);
    appearanceScope.constants.register(batman.appearance.weight.value, weightKilogramsIdentifier);
    appearanceScope.constants.register(batman.appearance.weight.systemOfUnits.index, weightSystemOfUnitsIdentifier);
    appearanceScope.constants.register(batman.appearance.eyeColor, eyeColorIdentifier);
    appearanceScope.constants.register(batman.appearance.hairColor, hairColorIdentifier);

    ConstantsSet workScope = heroScope.getSubModelScope(workIdentifier);
    workScope.constants.register(batman.work.occupation, occupationIdentifier);
    workScope.constants.register(batman.work.base, baseIdentifier);

    ConstantsSet connectionsScope = heroScope.getSubModelScope(connectionsIdentifier);
    connectionsScope.constants.register(batman.connections.groupAffiliation, groupAffiliationIdentifier);
    connectionsScope.constants.register(batman.connections.relatives, relativesIdentifier);

    ConstantsSet imageScope = heroScope.getSubModelScope(imageIdentifier);
    imageScope.constants.register(batman.image.url, urlIdentifier);

    var heroes = [batman, robin, alfred];
    heroes.sort();
    expect(heroes[0].name, "Robin");
    expect(heroes[1].name, "Alfred");
    expect(heroes[2].name, "Batman");

    alfred = alfred.copyWith(
      powerStats: alfred.powerStats.copyWith(strength: Percentage(30)),
    );
    heroes = [batman, robin, alfred];
    heroes.sort();
    expect(heroes[0].name, "Alfred");
    expect(heroes[1].name, "Robin");
    expect(heroes[2].name, "Batman");*/
  });
}
