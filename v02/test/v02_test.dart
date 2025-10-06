import 'dart:io';

import 'package:v02/models/hero.dart';
import 'package:v02/persistence/hero_repository.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('DB test', () async {

    var path = "v02_test.db";
    var file = File(path);

    if (await file.exists()) {
      await file.delete();
    }

    // First create a db instance, clean it, add some heroes, then shutdown
    var repo = HeroRepository(path);
    repo.clean();
    repo.persist(Hero(id: "02ffbb60-762b-4552-8f41-be8aa86869c6", name:"Batman", strength:  12, gender:  "Male", race: "Human", alignment:  "Good"));
    repo.persist(Hero(id: "008b98a5-3ce6-4448-99f4-d4ce296fcdfc", name: "Robin", strength:  8, gender:  "Unknown", race:  "Human", alignment:  "Good"));
    await repo.dispose();

    // Now create a new db instance, read the snapshot, and verify
    repo = HeroRepository(path);
    var snapshot = repo.heroesById;
    expect(2, snapshot.length);
    var batman = repo.query("batman")[0];
    expect(batman.id, "02ffbb60-762b-4552-8f41-be8aa86869c6");
    expect(batman.name, "Batman");
    expect(batman.strength, 12);
    expect(batman.gender, "Male");
    expect(batman.alignment, "Good");
    expect(batman.race, "Human");

    var robin=repo.query("robin")[0];
    expect(robin.id, "008b98a5-3ce6-4448-99f4-d4ce296fcdfc");
    expect(robin.name, "Robin");
    expect(robin.strength, 8);
    expect(robin.gender, "Unknown");
    expect(robin.alignment, "Good");
    expect(robin.race, "Human");

    // Modify Batman's strength, , 
    batman = batman.copyWith(strength: 13);
    repo.persist( batman);
    
    // Add Alfred, assign a id
    var alfred = Hero.newId("Alfred", 9,"Unknown", "Human", "Good");
    repo.persist(alfred);

    //delete Robin
    repo.delete(robin);

    // then shutdown
    await repo.dispose();

    repo = HeroRepository(path);
    snapshot = repo.heroesById; 
    expect(2, snapshot.length);
    batman = snapshot[batman.id]!;
    expect(batman.name, "Batman");
    expect(batman.strength, 13);


    alfred=snapshot[alfred.id]!;
    expect(alfred.name, "Alfred");
    expect(alfred.strength, 9);
    await repo.dispose();

    file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  });
}
