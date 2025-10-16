import 'dart:convert';
import 'dart:io';

import 'package:v04/managers/hero_data_manager.dart';
import 'package:v04/managers/hero_data_managing.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/persistence/hero_repository.dart';
import 'package:v04/prompts/prompt.dart';

Future<void> main() async {
  stdout.encoding = utf8;
  stderr.encoding = utf8;

  print("Welcome to the Hero Manager!");
  var heroDataManager = HeroDataManager(HeroRepository('v04.db'));

  var doWOrk = true;
  Map<String, (Function, String)> commands = {
    "c": (() => createHero(heroDataManager), "[C]reate a new hero (will prompt for details)"),
    "l": (() => listHeroes(heroDataManager), "[L]ist all heroes"),
    "t": (
      () => listTopNHeroes(heroDataManager),
      "List [T]op n heroes (will prompt for n)",
    ),
    "s": (
      () => listMatchingHeroes(heroDataManager),
      "[S]earch matching heroes (will prompt for a search string)",
    ),
    "a": (() => amendHero(heroDataManager), "[A]mend a hero"),
    "d": (() => deleteHero(heroDataManager), "[D]elete a hero"),
    "e": (() => deleteAllHeroes(heroDataManager), "[E]rase database (delete all heroes)"),
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
      await mainMenu(heroDataManager, commands);
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
  HeroDataManaging heroDataManager,
  Map<String, (Function, String)> commands,
) async {
  var input = (readUtf8Line() ?? "").toLowerCase().trim();
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

void listHeroes(HeroDataManaging heroDataManager) {
  var heroes = heroDataManager.heroes;
  if (heroes.isEmpty) {
    print("No heroes found");
  } else {
    print("Found ${heroes.length} heroes:");
    for (var hero in heroes) {
      print(hero);
    }
  }
}

void listTopNHeroes(HeroDataManaging heroDataManager) {
  print("Enter number of heroes to list:");
  var input = (readUtf8Line() ?? "").trim();
  var n = int.tryParse(input) ?? 0;
  if (n <= 0) {
    print("Invalid number");
    return;
  }
  var snapshot = heroDataManager.heroes;
  for (int i = 0; i < n; i++) {
    if (i >= snapshot.length) {
      break;
    }
    print(snapshot[i]);
  }
}

void listMatchingHeroes(HeroDataManaging heroDataManager) {
  var result = search(heroDataManager);
  if (result == null) {
    return;
  }
  for (var hero in result) {
    print(hero);
  }
}

void deleteAllHeroes(HeroDataManaging heroDataManager) {
  if (!promptForYesNo("Do you really want to delete all heroes?")) {
    return;
  }
  heroDataManager.clear();
  print("Deleted all heroes");
}

void deleteHero(HeroDataManaging heroDataManager) {
  HeroModel? hero = query(heroDataManager, "Delete");
  if (hero == null) {
    return;
  }

  if (!promptForYesNo(
    '''Do you really want to delete hero with the following details?$hero''',
  )) {
    return;
  }

  heroDataManager.delete(hero);
  print('''Deleted hero:
$hero''');
}

void createHero(HeroDataManaging heroDataManager) {
  HeroModel? hero = HeroModel.fromPrompt();
  if (hero == null) {
    print("Aborted");
    return;
  }

  if (!promptForYesNo('''Save new hero with the following details?$hero''')) {
    return;
  }

  heroDataManager.persist(hero);
  print('''Created hero:
$hero''');
}

void amendHero(HeroDataManaging heroDataManager) {
  HeroModel? hero = query(heroDataManager, "Amend");
  if (hero == null) {
    return;
  }
  var amededHero = hero.promptForAmendment();
  if (amededHero != null) {
    heroDataManager.persist(amededHero);
    print('''Amended hero:
$amededHero''');
  }
}

List<HeroModel>? search(HeroDataManaging heroDataManager) {
  print("Enter a search string:");
  var query = (readUtf8Line() ?? "").trim();
  var results = heroDataManager.query(query);
  if (results.isEmpty) {
    print("No heroes found");
    return null;
  }
  print("Found ${results.length} heroes:");
  return results;
}

HeroModel? query(HeroDataManaging heroDataManager, String what) {
  var results = search(heroDataManager);
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
