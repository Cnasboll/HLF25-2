import 'dart:io';

import 'package:v03/models/appearance.dart';
import 'package:v03/models/biography.dart';
import 'package:v03/models/connections.dart';
import 'package:v03/models/hero.dart';
import 'package:v03/models/image.dart';
import 'package:v03/models/power_stats.dart';
import 'package:v03/models/work.dart';
import 'package:v03/persistence/hero_repository.dart';
import 'package:test/test.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/value_types/weight.dart';

Future<void> main() async {
  test('DB test', () async {
    var path = "v03_test.db";
    var file = File(path);

    if (await file.exists()) {
      await file.delete();
    }

    // First create a db instance, clean it, add some heroes, then shutdown
    var repo = HeroRepository(path);
    repo.clean();
    repo.persist(
      Hero(
        id: "02ffbb60-762b-4552-8f41-be8aa86869c6",
        version: 1,
        serverId: 70,
        name: "Batman",
        powerStats: PowerStats(
          intelligence: 100,
          strength: 26,
          speed: 27,
          durability: 50,
          power: 47,
          combat: 100,
        ),
        biography: Biography(
          fullName: "Bruce Wayne",
          alterEgos: "No alter egos found.",
          aliases: ["Insider", "Matches Malone"],
          placeOfBirth: "Crest Hill, Bristol Township; Gotham County",
          firstAppearance: "Detective Comics #27",
          publisher: "DC Comics",
          alignment: Alignment.mostlyGood,
        ),
        appearance: Appearance(
          gender: Gender.male,
          race: "Human",
          height: Height.parseList(["6'2", "188 cm"]),
          weight: Weight.parseList(["209 lb", "95 kg"]),
          eyeColor: 'blue',
          hairColor: 'black',
        ),
        work: Work(
          occupation: "CEO of Wayne Enterprises",
          base: "Gotham City",
        ),
        connections: Connections(
          groupAffiliation: "Batman Family, Batman Incorporated, Justice League, Outsiders, Wayne Enterprises, Club of Heroes, formerly White Lantern Corps, Sinestro Corps",
          relatives: "Damian Wayne (son), Dick Grayson (adopted son), Tim Drake (adopted son), Jason Todd (adopted son), Cassandra Cain (adopted ward), Martha Wayne (mother, deceased)",
        ),
        image: Image(url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg")
      ),
    );
    repo.persist(
      Hero(
        id: "008b98a5-3ce6-4448-99f4-d4ce296fcdfc",
        version: 1,
        serverId: 69,
        name: "Robin",
        powerStats: PowerStats(
          intelligence: 110,
          strength: 23,
          speed: 28,
          durability: 57,
          power: 30,
          combat: 99,
        ),
        biography: Biography(
          fullName: "Dick Grayson",
          alterEgos: "Nightwing",
          aliases: ["Robin", "Nightwing"],
          placeOfBirth: "Gotham City",
          firstAppearance: "Detective Comics #38",
          publisher: "DC Comics",
          alignment: Alignment.reasonable,
        ),
        appearance: Appearance(
          gender: Gender.unknown,
          race: "Human",
          height: Height.parseList(["5'10", "178 cm"]),
          weight: Weight.parseList(["159 lb", "72 kg"]),
          eyeColor: 'blue',
          hairColor: 'black',
        ),
        work: Work(
          occupation: "Hero",
          base: "Gotham City",
        ),
        connections: Connections(
          groupAffiliation: "Teen Titans, Batman Family",
          relatives: "Bruce Wayne (guardian), Alfred Pennyworth (butler)",
        ),
        image: Image(url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg")
      ),
    );
    await repo.dispose();

    // Now create a new db instance, read the snapshot, and verify
    repo = HeroRepository(path);
    var snapshot = repo.heroesById;
    expect(2, snapshot.length);
    var batman = repo.query("batman")[0];
    expect(batman.id, "02ffbb60-762b-4552-8f41-be8aa86869c6");
      expect(batman.version, 1);
    expect(batman.serverId, 70);
    expect(batman.name, "Batman");
    expect(batman.powerStats!.strength, 26);
    expect(batman.appearance!.gender, Gender.male);
    expect(batman.biography!.alignment, Alignment.mostlyGood);
    expect(batman.appearance!.race, "Human");

    var robin = repo.query("robin")[0];
    expect(robin.id, "008b98a5-3ce6-4448-99f4-d4ce296fcdfc");
    expect(robin.version, 1);
    expect(robin.serverId, 69);
    expect(robin.name, "Robin");
    expect(robin.powerStats!.strength, 23);
    expect(robin.appearance!.gender, Gender.unknown);
    expect(robin.biography!.alignment, Alignment.reasonable);
    expect(robin.appearance!.race, "Human");

    // Modify Batman's strength and aligment
    batman = batman.copyWith(
      powerStats: batman.powerStats!.copyWith(strength: 13),
      biography: batman.biography!.copyWith(alignment: Alignment.good),
    );
    repo.persist(batman);

    // Add Alfred, assign a id
    var alfred = Hero.newId(
      3,
      "Alfred",
      PowerStats(strength: 9),
      Biography(alignment: Alignment.good, fullName: "Alfred Pennyworth"),
      Appearance(
        gender: Gender.wontSay,
        race: "Human",
        height: Height.parseList(["5'9", "175 cm"]),
        weight: Weight.parseList(["155 lb", "70 kg"]),
      ),
      Work(occupation: "Butler", base: "Wayne Manor"),
      Connections(
        groupAffiliation: "Wayne Manor",
        relatives: "Bruce Wayne (employer)",
      ),
      Image(
        url: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg",
      ),
    );
    repo.persist(alfred);

    //delete Robin
    repo.delete(robin);

    // then shutdown
    await repo.dispose();

    repo = HeroRepository(path);
    snapshot = repo.heroesById;
    expect(2, snapshot.length);
    batman = snapshot[batman.id]!;
    expect(batman.version, 2);
    expect(batman.name, "Batman");
    expect(batman.powerStats!.strength, 13);

    alfred = snapshot[alfred.id]!;
    expect(alfred.version, 1);
    expect(alfred.name, "Alfred");
    expect(alfred.powerStats!.strength, 9);
    await repo.dispose();

    file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  });
}
