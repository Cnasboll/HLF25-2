import 'dart:io';

import 'package:v03/models/hero.dart';
import 'package:v03/persistence/hero_repository.dart';
import 'package:v03/prompts/prompt.dart';

Future<void> main() async {
  print("Welcome to the Hero Manager!");
  var repo = HeroRepository('v03.db');

  var doWOrk = true;
  Map<String, (Function, String)> commands = {
    "c": (() => createHero(repo), "[C]reate a new hero (will prompt for details)"),
    "l": (() => listHeroes(repo), "[L]ist all heroes"),
    "t": (
      () => listTopNHeroes(repo),
      "List [T]op n heroes (will prompt for n)",
    ),
    "s": (
      () => listMatchingHeroes(repo),
      "[S]earch matching heroes (will prompt for a search string)",
    ),
    "a": (() => amendHero(repo), "[A]mend a hero"),
    "d": (() => deleteHero(repo), "[D]elete a hero"),
    "e": (() => deleteAllHeroes(repo), "[E]rase database (delete all heroes)"),
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
  if (input.isEmpty) {
    print("Please enter a command");
    return;
  }
  var command = commands[input.substring(0, 1)]?.$1;
  if (command == null) {
    print("Invalid command, please try again");
    return;
  }
  command();
}

bool promptQuit() {
  if (!promptForYesNo("Do you really want to exit?")) {
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
  if (!promptForYesNo("Do you really want to delete all heroes?")) {
    return;
  }
  repo.clean();
  print("Deleted all heroes");
}

void deleteHero(HeroRepository repo) {
  Hero? hero = query(repo, "Delete");
  if (hero == null) {
    return;
  }

  if (!promptForYesNo(
    '''Do you really want to delete hero with the following details?$hero''',
  )) {
    return;
  }

  repo.delete(hero);
  print('''Deleted hero:
$hero''');
}

void createHero(HeroRepository repo) {
  Hero? hero = Hero.fromPrompt();
  if (hero == null) {
    print("Aborted");
    return;
  }

  if (!promptForYesNo('''Save new hero with the following details?$hero''')) {
    return;
  }

  repo.persist(hero);
  print('''Created hero:
$hero''');
}

void amendHero(HeroRepository repo) {
  Hero? hero = query(repo, "Amend");
  if (hero == null) {
    return;
  }
  var amededHero = hero.promptForAmendment();
  if (amededHero != null) {
    repo.persist(amededHero);
    print('''Amended hero:
$amededHero''');
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
    switch (promptForYesNextCancel('''

$what the following hero?$hero''')) {
      case YesNoCancel.yes:
        return hero;
      case YesNoCancel.next:
        continue;
      case YesNoCancel.cancel:
        return null;
    }
  }
  return null;
}
