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

    // These are all identifiers registered for a HeroModel in SHQL™
    expect([
      "NULL",
      "ANSWER",
      "TRUE",
      "FALSE",
      "E",
      "LN10",
      "LN2",
      "LOG2E",
      "LOG10E",
      "PI",
      "SQRT1_2",
      "SQRT2",
      "AVOGADRO",
      "SIN",
      "COS",
      "TAN",
      "ACOS",
      "ASIN",
      "ATAN",
      "SQRT",
      "EXP",
      "LOG",
      "LOWERCASE",
      "UPPERCASE",
      "MIN",
      "MAX",
      "ATAN2",
      "POW",
      "UNKNOWN",
      "NEUTRAL",
      "MOSTLY_GOOD",
      "GOOD",
      "REASONABLE",
      "NOT_QUITE",
      "BAD",
      "UGLY",
      "EVIL",
      "USING_MOBILE_SPEAKER_ON_PUBLIC_TRANSPORT",
      "AMBIGUOUS",
      "MALE",
      "FEMALE",
      "NON_BINARY",
      "WONT_SAY",
      "METRIC",
      "IMPERIAL",
      "ID",
      "VERSION",
      "TIMESTAMP",
      "LOCKED",
      "EXTERNAL_ID",
      "NAME",
      "POWERSTATS",
      "INTELLIGENCE",
      "STRENGTH",
      "SPEED",
      "DURABILITY",
      "POWER",
      "COMBAT",
      "BIOGRAPHY",
      "FULL_NAME",
      "ALTER_EGOS",
      "ALIASES",
      "PLACE_OF_BIRTH",
      "FIRST_APPEARANCE",
      "PUBLISHER",
      "ALIGNMENT",
      "APPEARANCE",
      "GENDER",
      "RACE",
      "HEIGHT",
      "M",
      "SYSTEM_OF_UNITS",
      "WEIGHT",
      "KG",
      "EYE_COLOUR",
      "HAIR_COLOUR",
      "WORK",
      "OCCUPATION",
      "BASE",
      "CONNECTIONS",
      "GROUP_AFFILIATION",
      "RELATIVES",
      "IMAGE",
      "URL",
    ], heroScope.identifiers.constants);

    expect(Calculator.calculate('UNKNOWN', constantsSet: heroScope), 0);
    expect(Calculator.calculate('NEUTRAL', constantsSet: heroScope), 1);
    expect(Calculator.calculate('MOSTLY_GOOD', constantsSet: heroScope), 2);
    expect(Calculator.calculate('GOOD', constantsSet: heroScope), 3);
    expect(Calculator.calculate('REASONABLE', constantsSet: heroScope), 4);
    expect(Calculator.calculate('NOT_QUITE', constantsSet: heroScope), 5);
    expect(Calculator.calculate('BAD', constantsSet: heroScope), 6);
    expect(Calculator.calculate('UGLY', constantsSet: heroScope), 7);
    expect(Calculator.calculate('EVIL', constantsSet: heroScope), 8);
    expect(
      Calculator.calculate(
        'USING_MOBILE_SPEAKER_ON_PUBLIC_TRANSPORT',
        constantsSet: heroScope,
      ),
      9,
    );

    expect(Calculator.calculate('UNKNOWN', constantsSet: heroScope), 0);
    expect(Calculator.calculate('AMBIGUOUS', constantsSet: heroScope), 1);
    expect(Calculator.calculate('MALE', constantsSet: heroScope), 2);
    expect(Calculator.calculate('FEMALE', constantsSet: heroScope), 3);
    expect(Calculator.calculate('NON_BINARY', constantsSet: heroScope), 4);
    expect(Calculator.calculate('WONT_SAY', constantsSet: heroScope), 5);

    expect(Calculator.calculate('METRIC', constantsSet: heroScope), 0);
    expect(Calculator.calculate('IMPERIAL', constantsSet: heroScope), 1);

    expect(
      Calculator.calculate('id', constantsSet: heroScope),
      "02ffbb60-762b-4552-8f41-be8aa86869c6",
    );
    expect(Calculator.calculate('version', constantsSet: heroScope), 1);
    expect(
      Calculator.calculate('timestamp', constantsSet: heroScope),
      "2025-10-28T18:00:00.000Z",
    );
    expect(Calculator.calculate("locked", constantsSet: heroScope), 0);
    expect(Calculator.calculate('external_id', constantsSet: heroScope), "70");
    expect(Calculator.calculate('name', constantsSet: heroScope), "Batman");

    expect(
      Calculator.calculate('biography.full_name', constantsSet: heroScope),
      "Bruce Wayne",
    );
    expect(
      Calculator.calculate('biography.alter_egos', constantsSet: heroScope),
      null,
    );
    expect(Calculator.calculate('biography.aliases', constantsSet: heroScope), [
      "Insider",
      "Matches Malone",
    ]);
    expect(
      Calculator.calculate('biography.place_of_birth', constantsSet: heroScope),
      "Crest Hill, Bristol Township; Gotham County",
    );
    expect(
      Calculator.calculate(
        'biography.first_appearance',
        constantsSet: heroScope,
      ),
      "Detective Comics #27",
    );
    expect(
      Calculator.calculate('biography.publisher', constantsSet: heroScope),
      "DC Comics",
    );
    expect(
      Calculator.calculate('biography.alignment', constantsSet: heroScope),
      Alignment.mostlyGood.index,
    );

    expect(
      Calculator.calculate('powerstats.intelligence', constantsSet: heroScope),
      5,
    );
    expect(
      Calculator.calculate('powerstats.strength', constantsSet: heroScope),
      null,
    );
    expect(
      Calculator.calculate('powerstats.speed', constantsSet: heroScope),
      null,
    );
    expect(
      Calculator.calculate('powerstats.durability', constantsSet: heroScope),
      null,
    );

    expect(
      Calculator.calculate('appearance.race', constantsSet: heroScope),
      "Human",
    );
    expect(
      Calculator.calculate('appearance.gender', constantsSet: heroScope),
      Gender.male.index,
    );
    expect(
      Calculator.calculate('appearance.height.m', constantsSet: heroScope),
      1.8796,
    );
    expect(
      Calculator.calculate(
        'appearance.height.system_of_units',
        constantsSet: heroScope,
      ),
      SystemOfUnits.imperial.index,
    );
    expect(
      Calculator.calculate('appearance.weight.kg', constantsSet: heroScope),
      94.80080533,
    );
    expect(
      Calculator.calculate(
        'appearance.weight.system_of_units',
        constantsSet: heroScope,
      ),
      SystemOfUnits.imperial.index,
    );
    expect(
      Calculator.calculate('appearance.eye_colour', constantsSet: heroScope),
      "blue",
    );
    expect(
      Calculator.calculate('appearance.hair_colour', constantsSet: heroScope),
      "black",
    );

    expect(
      Calculator.calculate('work.occupation', constantsSet: heroScope),
      "CEO of Wayne Enterprises",
    );
    expect(
      Calculator.calculate('work.base', constantsSet: heroScope),
      "Gotham City",
    );

    expect(
      Calculator.calculate(
        'connections.group_affiliation',
        constantsSet: heroScope,
      ),
      "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    );
    expect(
      Calculator.calculate('connections.relatives', constantsSet: heroScope),
      "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
    );

    expect(
      Calculator.calculate('image.url', constantsSet: heroScope),
      "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
    );

    expect(Calculator.calculate('name ~ "Batman"', constantsSet: heroScope), 1);

    expect(Calculator.calculate('name = "Batman"', constantsSet: heroScope), 1);

    expect(
      Calculator.calculate(
        'name in ["Batman", "Robin"]',
        constantsSet: heroScope,
      ),
      1,
    );

    expect(
      Calculator.calculate(
        'lowercase(name) in ["batman", "robin"]',
        constantsSet: heroScope,
      ),
      1,
    );

    expect(
      Calculator.calculate(
        'biography.alignment = bad',
        constantsSet: heroScope,
      ),
      0,
    );

    expect(
      Calculator.calculate(
        'biography.alignment > good',
        constantsSet: heroScope,
      ),
      0,
    );

    expect(
      Calculator.calculate(
        'biography.alignment = good',
        constantsSet: heroScope,
      ),
      0,
    );

    expect(
      Calculator.calculate(
        'appearance.weight.kg / pow(appearance.height.m, 2)',
        constantsSet: heroScope,
      ),
      26.8337366955048,
    );

    expect(
      Calculator.calculate(
        'appearance.weight.kg / pow(appearance.height.m, 2) >= 25',
        constantsSet: heroScope,
      ),
      1, // TRUE - Batman is indeed obese as per WHO standards
    );

    expect(
      Calculator.calculate('work.base ~ "cave"', constantsSet: heroScope),
      0, // False, no mentionon of Batcave, batman is no troglodyte
    );

    expect(
      Calculator.calculate('"cave" in work.base', constantsSet: heroScope),
      0, // False, no mentionon of Batcave, batman is no troglodyte
    );
  });
}
