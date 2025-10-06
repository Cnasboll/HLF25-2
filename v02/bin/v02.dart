import 'dart:io';

import 'package:v02/models/hero.dart';
import 'package:v02/persistence/hero_repository.dart';

Future<void> main() async {
  print("Welcome to the Hero Manager!");
  var repo = HeroRepository('v02.db');

  var doWOrk = true;
  Map<String, (Function, String)> commands = {
    "a": (() => createHero(repo), "[A]dd a new hero (will prompt for details)"),
    "l": (() => listHeroes(repo), "[L]ist all heroes"),
    "t": (
      () => listTopNHeroes(repo),
      "List [T]op n heroes (will prompt for n)",
    ),
    "s": (
      () => listMatchingHeroes(repo),
      "[S]earch matching heroes (will prompt for a search string)",
    ),
    "u": (() => updateHero(repo), "[U]pdate a hero"),
    "d": (() => deleteHero(repo), "[D]elete a hero"),
    "c": (() => deleteAllHeroes(repo), "[C]lean database (delete all heroes)"),
    "q": (
      () => {
        if (promptQuit()) {doWOrk = false},
      },
      "[Q]uit (exit the program)",
    ),
  };

  var prompt = generatePrompt(commands);

  while (doWOrk) {
    print(prompt);
    try {
      await mainMenu(repo, commands);
    } catch (e) {
      print("Unexpected error: $e");
    }

    // allow any pending async operations to complete to save changes
    await Future.delayed(Duration.zero);
  }
}

String generatePrompt(Map<String, (Function, String)> commands) {
  StringBuffer promptBuffer = StringBuffer();
  promptBuffer.write("""
Enter a menu option (""");
  for (int i = 0; i < commands.length; i++) {
    if (i > 0) {
      if (i == commands.length - 1) {
        promptBuffer.write(" or ");
      } else {
        promptBuffer.write(", ");
      }
    }
    promptBuffer.write(commands.keys.elementAt(i).toUpperCase());
  }
  promptBuffer.writeln(") and press enter:");

  for (var entry in commands.entries) {
    promptBuffer.writeln(entry.value.$2);
  }
  return promptBuffer.toString();
}

Future<void> mainMenu(
  HeroRepository repo,
  Map<String, (Function, String)> commands,
) async {
  var input = (stdin.readLineSync() ?? "").toLowerCase().trim();
  var command = commands[input]?.$1;
  if (command == null) {
    print("Invalid command, please try again");
    return;
  }
  command();
}

bool promptQuit() {
  if (promptForYesNo("Do you really want to exit?") == YesNo.no) {
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
  if (promptForYesNo("Do you really want to delete all heroes?") == YesNo.no) {
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

YesNoCancel promptForYesNoCancel(String prompt) {
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

  if (promptForYesNo(
        '''Do you really want to delete hero with the following details?$hero''',
      ) ==
      YesNo.no) {
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

  if (promptForYesNo('''Save new hero with the following details?$hero''') ==
      YesNo.no) {
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
  var updatedHero = promptForUpdated(hero);
  if (updatedHero != null) {
    repo.persist(updatedHero);
    print('''Updated hero:
$updatedHero''');
  }
}

List<Hero>? search(HeroRepository repo) {
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

Hero? promptForUpdated(Hero hero) {
  List<(String, String)> hintsAndCurrent = [];
  for (int i = 1; i < Hero.fields.length; i++) {
    var field = Hero.fields[i];
    var value = hero.props[i];
    hintsAndCurrent.add((field, value.toString()));
  }

  var update = promptForUpdate(hintsAndCurrent);

  var updatedHero = Hero(
    id: hero.id,
    name: update[0],
    strength: int.tryParse(update[1]) ?? hero.strength,
    gender: update[2],
    race: update[3],
    alignment: update[4],
  );

  if (hero == updatedHero) {
    print("No changes made");
    return null;
  }

  if (promptForYesNo(
        '''Save the following changes?${hero.sideBySide(updatedHero)}''',
      ) ==
      YesNo.no) {
    return null;
  }

  return updatedHero;
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
  var values = promptForValues([
    "name",
    "strength (integer)",
    "gender",
    "race",
    "alignment",
  ]);
  if (values == null) {
    return null;
  }
  var strength = int.tryParse(values[1]) ?? 0;
  return Hero.newId(values[0], strength, values[2], values[3], values[4]);
}
