import 'package:v04/models/appearance_model.dart';
import 'package:v04/models/biography_model.dart';
import 'package:v04/models/connections_model.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/models/image_model.dart';
import 'package:v04/models/power_stats_model.dart';
import 'package:v04/models/work_model.dart';
import 'package:test/test.dart';
import 'package:v04/shql/engine/engine.dart';
import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/value_types/height.dart';
import 'package:v04/value_types/percentage.dart';
import 'package:v04/value_types/value_type.dart';
import 'package:v04/value_types/weight.dart';

final DateTime deadline = DateTime.parse("2025-10-28T18:00:00.000000Z");

Future<void> main() async {
  test('Can reason about Batman', () async {
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
        height: await Height.parseList(["6'2", "188 cm"]),
        weight: await Weight.parseList(["209 lb", "95 kg"]),
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

    ConstantsSet constantsSet = Engine.prepareConstantsSet();
    constantsSet.registerEnum<Alignment>(Alignment.values);
    constantsSet.registerEnum<Gender>(Gender.values);
    constantsSet.registerEnum<SystemOfUnits>(SystemOfUnits.values);
    HeroModel.declareIdentifiers(constantsSet);

    // Hero scope inherits from root
    ConstantsSet heroScope = constantsSet.createChild();

    batman.registerIdentifiers(heroScope);

    // These are all identifiers registered for a HeroModel in SHQL™
    expect(heroScope.identifiers.constants, [
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
    ]);

    expect(Engine.calculate('UNKNOWN', constantsSet: heroScope), 0);
    expect(Engine.calculate('NEUTRAL', constantsSet: heroScope), 1);
    expect(Engine.calculate('MOSTLY_GOOD', constantsSet: heroScope), 2);
    expect(Engine.calculate('GOOD', constantsSet: heroScope), 3);
    expect(Engine.calculate('REASONABLE', constantsSet: heroScope), 4);
    expect(Engine.calculate('NOT_QUITE', constantsSet: heroScope), 5);
    expect(Engine.calculate('BAD', constantsSet: heroScope), 6);
    expect(Engine.calculate('UGLY', constantsSet: heroScope), 7);
    expect(Engine.calculate('EVIL', constantsSet: heroScope), 8);
    expect(
      Engine.calculate(
        'USING_MOBILE_SPEAKER_ON_PUBLIC_TRANSPORT',
        constantsSet: heroScope,
      ),
      9,
    );

    expect(Engine.calculate('UNKNOWN', constantsSet: heroScope), 0);
    expect(Engine.calculate('AMBIGUOUS', constantsSet: heroScope), 1);
    expect(Engine.calculate('MALE', constantsSet: heroScope), 2);
    expect(Engine.calculate('FEMALE', constantsSet: heroScope), 3);
    expect(Engine.calculate('NON_BINARY', constantsSet: heroScope), 4);
    expect(Engine.calculate('WONT_SAY', constantsSet: heroScope), 5);

    expect(Engine.calculate('METRIC', constantsSet: heroScope), 0);
    expect(Engine.calculate('IMPERIAL', constantsSet: heroScope), 1);

    expect(
      Engine.calculate('id', constantsSet: heroScope),
      "02ffbb60-762b-4552-8f41-be8aa86869c6",
    );
    expect(Engine.calculate('version', constantsSet: heroScope), 1);
    expect(
      Engine.calculate('timestamp', constantsSet: heroScope),
      "2025-10-28T18:00:00.000Z",
    );
    expect(Engine.calculate("locked", constantsSet: heroScope), 0);
    expect(Engine.calculate('external_id', constantsSet: heroScope), "70");
    expect(Engine.calculate('name', constantsSet: heroScope), "Batman");

    expect(
      Engine.calculate('biography.full_name', constantsSet: heroScope),
      "Bruce Wayne",
    );
    expect(
      Engine.calculate('biography.alter_egos', constantsSet: heroScope),
      null,
    );
    expect(Engine.calculate('biography.aliases', constantsSet: heroScope), [
      "Insider",
      "Matches Malone",
    ]);
    expect(
      Engine.calculate('biography.place_of_birth', constantsSet: heroScope),
      "Crest Hill, Bristol Township; Gotham County",
    );
    expect(
      Engine.calculate('biography.first_appearance', constantsSet: heroScope),
      "Detective Comics #27",
    );
    expect(
      Engine.calculate('biography.publisher', constantsSet: heroScope),
      "DC Comics",
    );
    expect(
      Engine.calculate('biography.alignment', constantsSet: heroScope),
      Alignment.mostlyGood.index,
    );

    expect(
      Engine.calculate('powerstats.intelligence', constantsSet: heroScope),
      5,
    );
    expect(
      Engine.calculate('powerstats.strength', constantsSet: heroScope),
      null,
    );
    expect(Engine.calculate('powerstats.speed', constantsSet: heroScope), null);
    expect(
      Engine.calculate('powerstats.durability', constantsSet: heroScope),
      null,
    );

    expect(
      Engine.calculate('appearance.race', constantsSet: heroScope),
      "Human",
    );
    expect(
      Engine.calculate('appearance.gender', constantsSet: heroScope),
      Gender.male.index,
    );
    expect(
      Engine.calculate('appearance.height.m', constantsSet: heroScope),
      1.8796,
    );
    expect(
      Engine.calculate(
        'appearance.height.system_of_units',
        constantsSet: heroScope,
      ),
      SystemOfUnits.imperial.index,
    );
    expect(
      Engine.calculate('appearance.weight.kg', constantsSet: heroScope),
      94.80080533,
    );
    expect(
      Engine.calculate(
        'appearance.weight.system_of_units',
        constantsSet: heroScope,
      ),
      SystemOfUnits.imperial.index,
    );
    expect(
      Engine.calculate('appearance.eye_colour', constantsSet: heroScope),
      "blue",
    );
    expect(
      Engine.calculate('appearance.hair_colour', constantsSet: heroScope),
      "black",
    );

    expect(
      Engine.calculate('work.occupation', constantsSet: heroScope),
      "CEO of Wayne Enterprises",
    );
    expect(
      Engine.calculate('work.base', constantsSet: heroScope),
      "Gotham City",
    );

    expect(
      Engine.calculate(
        'connections.group_affiliation',
        constantsSet: heroScope,
      ),
      "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
    );
    expect(
      Engine.calculate('connections.relatives', constantsSet: heroScope),
      "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
    );

    expect(
      Engine.calculate('image.url', constantsSet: heroScope),
      "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
    );

    expect(Engine.calculate('name ~ "Batman"', constantsSet: heroScope), 1);

    expect(Engine.calculate('name = "Batman"', constantsSet: heroScope), 1);

    expect(
      Engine.calculate('name in ["Batman", "Robin"]', constantsSet: heroScope),
      1,
    );

    expect(
      Engine.calculate(
        'lowercase(name) in ["batman", "robin"]',
        constantsSet: heroScope,
      ),
      1,
    );

    expect(
      Engine.calculate('biography.alignment = bad', constantsSet: heroScope),
      0,
    );

    expect(
      Engine.calculate('biography.alignment > good', constantsSet: heroScope),
      0,
    );

    expect(
      Engine.calculate('biography.alignment = good', constantsSet: heroScope),
      0,
    );

    expect(
      Engine.calculate(
        'appearance.weight.kg / pow(appearance.height.m, 2)',
        constantsSet: heroScope,
      ),
      26.8337366955048,
    );

    expect(
      Engine.calculate(
        'appearance.weight.kg / pow(appearance.height.m, 2) >= 25',
        constantsSet: heroScope,
      ),
      1, // TRUE - Batman is indeed obese as per WHO standards
    );

    expect(
      Engine.calculate('work.base ~ "cave"', constantsSet: heroScope),
      0, // False, no mentionon of Batcave, batman is no troglodyte
    );

    expect(
      Engine.calculate('"cave" in work.base', constantsSet: heroScope),
      0, // False, no mentionon of Batcave, batman is no troglodyte
    );
  });
}
