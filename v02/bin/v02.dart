import 'dart:io';

import 'package:v02/models/hero.dart';
import 'package:v02/persistence/hero_repository.dart';

Future<void> main() async {
  var repo = HeroRepository('v02.db');
  for (;;) {    
      print(
        """
Enter a menu option (A, L, T, U, D, C or Q) and press enter:
[A]dd a new hero (will prompt for details)
[L]ist all heroes
List [T]op n heroes (will prompt for n)
[S]earch matching heroes (will prompt for a search string)
[U]pdate a hero
[D]elete a hero
[C]lean database (delete all heroes)
[Q]uit (exit the program)
      """);

    try {
      await mainMenu(repo);
    } catch (e) {
      print("Unexpected rror: $e");
    }

    // allow any pending async operations to complete to save changes
    await Future.delayed(Duration.zero);
  }
}

Future<void> mainMenu(HeroRepository repo) async {
  var input = (stdin.readLineSync() ?? "").toLowerCase().trim();
  
  switch (input) {
    case "a":
      {
        createHero(repo);
        break;
      }
      case "l":
      {
        listHeroes(repo);
        break;
      }
      case "t":
      {
        listTopNHeroes(repo);
        break;
      } 
      case "s":
      {
        listMatchingHeroes(repo);
        break;
      }       
      case "u":
      {
        updateHero(repo);
        break;
      }
      case "d":
      {
        deleteHero(repo);
        break;
      }  
      case "c":
      {
        deleteAllHeroes(repo);
        break;
      }
      case "q":
      {
        if (promptQuit()) {
          await repo.dispose();
          exit(0);
        }
      }
  }
}

bool promptQuit() {
  if (promptForYesNo( "Do you really want to exit?") == YesNo.no) {
    return false;
  }
  print("Exiting...");
  return true;
}

void listHeroes(HeroRepository repo) {
  var heroes = repo.heroes;
  if (heroes.isEmpty) {
    print("No heroes found");
  } else {
    print("Found ${heroes.length} heroes:");
    for (var hero in heroes) {
      print(hero);
    }
  }
}

void listTopNHeroes(HeroRepository repo) {
  print("Enter number of heroes to list:");
  var input = (stdin.readLineSync() ?? "").trim();
  var n = int.tryParse(input) ?? 0;
  if (n <= 0) {
    print("Invalid number");
    return;
  }
  var snapshot = repo.heroes;
  for (int i = 0; i < n; i++) {
    if (i >= snapshot.length) {
      break;
    }
    print(snapshot[i]);
  }
}

void listMatchingHeroes(HeroRepository repo) {
  var result = search(repo);
  if (result == null) {
    return;
  }
  for (var hero in result) {
    print(hero);
  }
}

void deleteAllHeroes(HeroRepository repo) {
  if (promptForYesNo("Do you really want to delete all heroes?") ==
      YesNo.no) {
        return;
  }
  repo.clean();
    print("Deleted all heroes");
}

enum YesNo { yes, no }
YesNo promptForYesNo(String prompt) {
  for (;;) {
    print('''

$prompt (y/n)''');
    var input = (stdin.readLineSync() ?? "").trim().toLowerCase();
    if (input.startsWith("y")) {
      return YesNo.yes;
    }
    if (input.startsWith("n")) {
      return YesNo.no;
    }
    print("Invalid answer, please enter y or n");
  }
}

enum YesNoCancel { yes, no, cancel }
YesNoCancel promptForYesNoCancel(String prompt)
{
  for (;;) {
    print("$prompt (y = yes, n = no, c = cancel)");
    var input = (stdin.readLineSync() ?? "").trim().toLowerCase();
    if (input.startsWith("y")) {
      return YesNoCancel.yes;
    }
    if (input.startsWith("n")) {
      return YesNoCancel.no;
    }
    if (input.startsWith("c")) {
      return YesNoCancel.cancel;
    }
    print("Invalid answer, please enter y, n or c");
  }
}

void deleteHero(HeroRepository repo) {
  Hero? hero = query(repo, "Delete");
  if (hero == null) {
    return;
  }

  if (promptForYesNo('''Do you really want to delete hero with the following details?$hero''') == YesNo.no) {
    return;
  }

  repo.delete(hero);
  print('''Deleted hero:
$hero''');
}

void createHero(HeroRepository repo) {
  Hero? hero = promptForNew();
  if (hero == null) {
    print("Aborted");
    return;
  }

  if (promptForYesNo('''Save new hero with the following details?$hero''') == YesNo.no) {
    return;
  }

  repo.persist(hero);
  print('''Created hero:
$hero''');
}

void updateHero(HeroRepository repo) {
  Hero? hero = query(repo, "Update");
  if (hero == null) {
    return;
  }
  if (promptForUpdated(hero)) {
    repo.persist(hero);
    print('''Updated hero:
$hero''');
  }
}

List<Hero>? search(HeroRepository repo)
{
  print("Enter a search string:");
  var query = (stdin.readLineSync() ?? "").trim();
  var results = repo.query(query);
  if (results.isEmpty) {
    print("No heroes found");
    return null;
  }
  print("Found ${results.length} heroes:");
  return results;
}

Hero? query(HeroRepository repo, String what) {
  var results = search(repo);
  if (results == null) {
    return null;
  }
  for (var hero in results) {
    switch (promptForYesNoCancel('''

$what the following hero?$hero''')) {
      case YesNoCancel.yes:
        return hero;
      case YesNoCancel.no:
        continue;
      case YesNoCancel.cancel:
        return null;
    }
  }
  return null;
}

List<String> promptForUpdate(List<(String, String)> hintsAndCurrent) {
  List<String> values = [];
  for (var (hint, current) in hintsAndCurrent) {
    print("Enter $hint or enter to keep current value ($current):");
    var input = (stdin.readLineSync() ?? "").trim();
    if (input.isEmpty) {
      values.add(current);
    } else {
      values.add(input);
    }
  }
  return values;
}

bool promptForUpdated(Hero hero) {
  var update = promptForUpdate([
    ("name", hero.name),
    ("strength (integer)", hero.strength.toString()),
    ("gender", hero.gender),
    ("race", hero.race),
    ("alignment", hero.alignment)
  ]);


  hero.name = update[0];
  hero.strength = int.tryParse(update[1]) ?? hero.strength;
  hero.gender = update[2];
  hero.race = update[3];
  hero.alignment = update[4];
  if (promptForYesNo('''Save changes?$hero''') == YesNo.no) { 
    return false;
  }

  return true;
}

List<String>? promptForValues(List<String> hints) {
  List<String> values = [];
  for (var hint in hints) {
    print("Enter $hint or enter to abort:");
    var input = (stdin.readLineSync() ?? "").trim();
    if (input.isEmpty) {
      return null;
    }
    values.add(input);
  }
  return values;
}

Hero? promptForNew() {
  var values = promptForValues(
      ["name", "strength (integer)", "gender", "race", "alignment"]);
  if (values == null) {
    return null;
  }
  var strength = int.tryParse(values[1]) ?? 0;
  return Hero.newId(values[0], strength, values[2], values[3], values[4]);
}
