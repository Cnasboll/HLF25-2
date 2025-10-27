import 'dart:convert';
import 'dart:io';

import 'package:v04/env/env.dart';
import 'package:v04/managers/hero_data_manager.dart';
import 'package:v04/managers/hero_data_managing.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/models/search_response_model.dart';
import 'package:v04/persistence/hero_repository.dart';
import 'package:v04/prompts/prompt.dart';
import 'package:v04/services/hero_service.dart';
import 'package:v04/services/hero_servicing.dart';
import 'package:v04/value_types/height.dart';
import 'package:v04/value_types/manual_conflict_resolver.dart';
import 'package:v04/value_types/weight.dart';

Future<void> main() async {
  stdout.encoding = utf8;
  stderr.encoding = utf8;

  print("Welcome to the Hero Manager!");
  var heroDataManager = HeroDataManager(HeroRepository('v04.db'));

  var doWOrk = true;
  Map<String, (Function, String)> commands = {
    "c": (
      () => createHero(heroDataManager),
      "[C]reate a new hero (will prompt for details)",
    ),
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
    "e": (
      () => deleteAllHeroes(heroDataManager),
      "[E]rase database (delete all heroes)",
    ),
    "o": (() => goOnline(heroDataManager), "Go [O]nline to download heroes"),
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
      await menu(heroDataManager, commands);
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

Future<void> menu(
  HeroDataManaging heroDataManager,
  Map<String, (Function, String)> commands,
) async {
  var input = promptFor("").toLowerCase();
  if (input.isEmpty) {
    print("Please enter a command");
    return;
  }
  var command = commands[input.substring(0, 1)]?.$1;
  if (command == null) {
    print("Invalid command, please try again");
    return;
  }
  await command();
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
  var n = int.tryParse(promptFor("Enter number of heroes to list:")) ?? 0;
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

Future<void> downloadHeroes(HeroDataManaging heroDataManager) async {
  var query = promptFor("Enter a search string:");
  var heroService = HeroService(Env());
    var timestamp = DateTime.timestamp();
  print (''' 

Online search started at $timestamp

''');
  var (results, error) = await heroService.search(query);
  if (error != null) {
    print("Failed to search online heroes: $error");
    return;
  }

  if (results == null) {
    print("Server returned no data when searching for '$query'");
    return;
  }

  bool saveAll = false;
  var saveCount  = 0;
  try {
    Height.conflictResolver = ManualConflictResolver();
    Weight.conflictResolver = ManualConflictResolver();
    var searchResponseModel = SearchResponseModel.fromJson(
      heroDataManager,
      results,
      timestamp
    );

    print("Found ${searchResponseModel.results.length} heroes online:");
    for (var hero in searchResponseModel.results) {
      if (heroDataManager.getByExternalId(hero.externalId) != null) {
        print(
          "Hero ${hero.name} already exists locally - skipping (run reconciliation to update existing heroes with online data)",
        );
        continue;
      }

      if (!saveAll) {
        var yesNoAll = promptForYesNoAllQuit('''Save the following hero locally?
$hero''');
        if (yesNoAll == YesNoAllQuit.quit) {
          print("Aborting download of further heroes");
          break;
        }
        if (yesNoAll == YesNoAllQuit.no) {
          continue;
        }
        if (yesNoAll == YesNoAllQuit.all) {
          saveAll = true;
        }
      }
      heroDataManager.persist(hero);
      print('''Saved hero:
$hero''');
      ++saveCount;
    }
  } catch (e) {
    print("Failed to parse online heroes: $e");
  } finally {
    Height.conflictResolver = null;
    Weight.conflictResolver = null;
  }

    print (''' 

Download complete at ${DateTime.timestamp()}: $saveCount heroes saved.

''');
}

void deleteAllHeroes(HeroDataManaging heroDataManager) {
  if (!promptForYesNo("Do you really want to delete all heroes?")) {
    return;
  }
  heroDataManager.clear();
  print("Deleted all heroes");
}

void deleteHeroUnprompted(HeroDataManaging heroDataManager, HeroModel hero) {
  heroDataManager.delete(hero);
  print('''Deleted hero:
$hero''');
}

bool deleteHeroPrompted(HeroDataManaging heroDataManager, HeroModel hero) {
  if (!promptForYesNo(
    '''Do you really want to delete hero with the following details?$hero''',
  )) {
    return false;
  }

  deleteHeroUnprompted(heroDataManager, hero);
  return true;
}

void deleteHero(HeroDataManaging heroDataManager) {
  HeroModel? hero = query(heroDataManager, "Delete");
  if (hero == null) {
    return;
  }

  deleteHeroPrompted(heroDataManager, hero);
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

void unlockHeroe(HeroDataManaging heroDataManager) {
  HeroModel? hero = query(
    heroDataManager,
    "Unlock to enable reconciliation",
    filter: (h) => h.locked,
  );
  if (hero == null) {
    return;
  }
  var unlockedHero = hero.unlock();

  if (!hero.locked) {
    print("Hero is already unlocked");
    return;
  }

  if (unlockedHero.locked) {
    print("Hero could not be unlocked");
    return;
  }

  heroDataManager.persist(unlockedHero);
  print('''Hero was unlocked:
$unlockedHero''');
}

List<HeroModel>? search(
  HeroDataManaging heroDataManager, {
  bool Function(HeroModel)? filter,
}) {
  var query = promptFor("Enter a search string:");
  var results = heroDataManager.query(query, filter: filter);
  if (results.isEmpty) {
    print("No heroes found");
    return null;
  }
  print("Found ${results.length} heroes:");
  return results;
}

HeroModel? query(
  HeroDataManaging heroDataManager,
  String what, {
  bool Function(HeroModel)? filter,
}) {
  var results = search(heroDataManager, filter: filter);
  if (results == null) {
    return null;
  }
  for (var hero in results) {
    switch (promptForYesNextCancel('''

$what the following hero?$hero''')) {
      case YesNextCancel.yes:
        return hero;
      case YesNextCancel.next:
        continue;
      case YesNextCancel.cancel:
        return null;
    }
  }
  return null;
}

Future<void> goOnline(HeroDataManaging heroDataManager) async {
  bool exit = false;
  Map<String, (Function, String)> commands = {
    "r": (
      () async => await reconcileHeroes(heroDataManager),
      "[R]econcile local heroes with online updates",
    ),
    "s": (
      () async => await downloadHeroes(heroDataManager),
      "[S]earch online for new heroes to download",
    ),
    "u": (
      () => unlockHeroe(heroDataManager),
      "[U]nlock manually amended heroes to enable reconciliation",
    ),
    "x": (() => {exit = true}, "E[X]it and return to main menu"),
  };

  var prompt = generatePrompt(commands);

  while (!exit) {
    print(prompt);
    try {
      await menu(heroDataManager, commands);
    } catch (e) {
      print("Unexpected error: $e");
    }
  }
}

Future<void> reconcileHeroes(HeroDataManaging heroDataManager) async {
  var timestamp = DateTime.timestamp();
  print (''' 

Reconciliation started at at $timestamp

''');
  HeroServicing? heroService;
  bool deleteAll = false;
  bool updateAll = false;
  var deletionCount = 0;
  var reconciliationCount  = 0;
  try {
    Weight.conflictResolver = ManualConflictResolver();
    Height.conflictResolver = ManualConflictResolver();
    for (var hero in heroDataManager.heroes) {
      heroService ??= HeroService(Env());
      var (onlineHeroJson, error) = await heroService.getById(hero.externalId);
      if (onlineHeroJson == null) {
        if (hero.locked) {
          print(
            '''Hero: ${hero.externalId} ("${hero.name}") does not exist online: ${error ?? 'Unknown error'} but is locked by prior manual amendment - skipping deletion''',
          );
          continue;
        }

        if (deleteAll) {
          print(
            'Hero: ${hero.externalId} ("${hero.name}") does not exist online: ${error ?? 'Unknown error'} - deleting from local database',
          );
          deleteHeroUnprompted(heroDataManager, hero);
          ++deletionCount;
          continue;
        }

        var yesNoAllQuit = promptForYesNoAllQuit(
          'Hero: ${hero.externalId} ("${hero.name}") does not exist online: ${error ?? 'Unknown error'} - delete it from local database?',
        );
        switch (yesNoAllQuit) {
          case YesNoAllQuit.yes:
            if (deleteHeroPrompted(heroDataManager, hero)) {
              ++deletionCount;
            }
            break;
          case YesNoAllQuit.no:
            // Do nothing
            break;
          case YesNoAllQuit.all:
            deleteAll = true;
            deleteHeroUnprompted(heroDataManager, hero);
            ++deletionCount;
            break;
          case YesNoAllQuit.quit:
            {
              print("Aborting reconciliation of further heroes");
              return;
            }
        }
        continue;
      }

      try {
        var updatedHero = hero.apply(onlineHeroJson, timestamp, false);
        var sb = StringBuffer();
        var diff = hero.diff(updatedHero, sb);
        if (!diff) {
          print('Hero: ${hero.externalId} ("${hero.name}") is already up to date');
          continue;
        }

        if (hero.locked) {
          print(
            '''Hero: ${hero.externalId} ("${hero.name}") is locked by prior manual amendment, skipping reconciliation changes:
${sb.toString()}''',
          );
          continue;
        }

        if (updateAll) {
          heroDataManager.persist(updatedHero);
          ++reconciliationCount;
          print(
            '''Reconciled hero: ${hero.externalId} ("${hero.name}") with the following online changes:
${sb.toString()}''',
          );
          continue;
        }

        var yesNoAllQuit = promptForYesNoAllQuit(
          '''Reconcile hero: ${hero.externalId} ("${hero.name}") with the following online changes?
  ${sb.toString()}''',
        );

        switch (yesNoAllQuit) {
          case YesNoAllQuit.yes:
            // continue below
            break;
          case YesNoAllQuit.no:
            // Do nothing
            continue;
          case YesNoAllQuit.all:
            updateAll = true;
            // continue below
            break;
          case YesNoAllQuit.quit:
            {
              print("Aborting reconciliation of further heroes");
              return;
            }
        }

        heroDataManager.persist(updatedHero);
          ++reconciliationCount;
          print(
            '''Reconciled hero: ${hero.externalId} ("${hero.name}") with the following online changes:
${sb.toString()}''',
          );
      } catch (e) {
        print(
          'Failed to reconcile hero: ${hero.externalId} ("${hero.name}"): $e',
        );
      }
    }
  } finally {
    Weight.conflictResolver = null;
    Height.conflictResolver = null;
  }
  print (''' 

Reconciliation complete at ${DateTime.timestamp()}: $reconciliationCount heroes reconciled, $deletionCount heroes deleted.

''');
}
