import 'package:v04/env/env.dart';
import 'package:v04/managers/hero_data_manager.dart';
import 'package:v04/managers/hero_data_managing.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/models/search_response_model.dart';
import 'package:v04/persistence/hero_repository.dart';
import 'package:v04/terminal/prompt.dart';
import 'package:v04/services/hero_service.dart';
import 'package:v04/services/hero_servicing.dart';
import 'package:v04/terminal/terminal.dart';
import 'package:v04/value_types/conflict_resolver.dart';
import 'package:v04/value_types/height.dart';
import 'package:v04/value_types/weight.dart';

Future<void> main() async {
  // Clear screen and set green text
  Terminal.initialize();

  Terminal.println("Welcome to the Hero Manager!");
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

  void defaultCommand(String query) =>
      listMatchingHeroes(heroDataManager, query: query);

  var prompt = generatePrompt(commands);

  while (doWOrk) {
    Terminal.println(prompt);
    try {
      await menu(heroDataManager, commands, defaultCommand: defaultCommand);
    } catch (e) {
      Terminal.println("Unexpected error: $e");
    }

    // allow any pending async operations to complete to save changes
    await Future.delayed(Duration.zero);
  }
  Terminal.cleanup();
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
  Map<String, (Function, String)> commands, {
  Function(String)? defaultCommand,
}) async {
  var input = promptFor("").toLowerCase();
  if (input.isEmpty) {
    Terminal.println("Please enter a command");
    return;
  }
  var command = commands[input]?.$1;
  if (command == null) {
    if (defaultCommand != null) {
      Terminal.println("No command entered, using default search");
      command = () => defaultCommand(input);
    }

    if (command == null) {
      Terminal.println("Invalid command, please try again");
      return;
    }
  }
  await command();
}

bool promptQuit() {
  if (!promptForYesNo("Do you really want to exit?")) {
    return false;
  }
  Terminal.println("Exiting...");
  return true;
}

void listHeroes(HeroDataManaging heroDataManager) {
  var heroes = heroDataManager.heroes;
  if (heroes.isEmpty) {
    Terminal.println("No heroes found");
  } else {
    Terminal.println("Found ${heroes.length} heroes:");
    for (var hero in heroes) {
      Terminal.println(hero.toString());
    }
  }
}

void listTopNHeroes(HeroDataManaging heroDataManager) {
  var n = int.tryParse(promptFor("Enter number of heroes to list:")) ?? 0;
  if (n <= 0) {
    Terminal.println("Invalid number");
    return;
  }
  var snapshot = heroDataManager.heroes;
  for (int i = 0; i < n; i++) {
    if (i >= snapshot.length) {
      break;
    }
    Terminal.println(snapshot[i].toString());
  }
}

void listMatchingHeroes(HeroDataManaging heroDataManager, {String? query}) {
  var result = search(heroDataManager, query: query);
  if (result == null) {
    return;
  }
  for (var hero in result) {
    Terminal.println(hero.toString());
  }
}

Future<void> saveHeroes(
  HeroDataManaging heroDataManager, {
  String? query,
}) async {
  query ??= promptFor("Enter a search string:");
  var heroService = HeroService(Env());
  var timestamp = DateTime.timestamp();
  Terminal.println('''

Online search started at $timestamp

''');
  var results = await heroService.search(query);
  String? error;
  if (results != null) {
    error = results["error"];
  }
  if (error != null) {
    Terminal.println("Failed to search online heroes: $error");
    return;
  }

  if (results == null) {
    Terminal.println(
      "Server returned no data when searching for '$query'",
    );
    return;
  }

  bool saveAll = false;
  var saveCount = 0;
  try {
    var previousHeightConflictResolver = Height.conflictResolver;
    var previousWeightConflictResolver = Weight.conflictResolver;
    SearchResponseModel searchResponseModel;
    try {
      var heightConflictResolver = Height.conflictResolver =
          ManualConflictResolver<Height>();
      var weightConflictResolver = Weight.conflictResolver =
          ManualConflictResolver<Weight>();
      searchResponseModel = SearchResponseModel.fromJson(
        heroDataManager,
        results,
        timestamp,
      );

      for (var error in heightConflictResolver.resolutionLog) {
        Terminal.println(error);
      }
      for (var error in weightConflictResolver.resolutionLog) {
        Terminal.println(error);
      }
    } finally {
      // Restore previous conflict resolvers
      Height.conflictResolver = previousHeightConflictResolver;
      Weight.conflictResolver = previousWeightConflictResolver;
    }

    Terminal.println('''

Found ${searchResponseModel.results.length} heroes online:''');
    for (var hero in searchResponseModel.results) {
      if (heroDataManager.getByExternalId(hero.externalId) != null) {
        Terminal.println(
          'Hero  ${hero.externalId} ("${hero.name}") already exists locally - skipping (run reconciliation to update existing heroes with online data)',
        );
        continue;
      }

      if (!saveAll) {
        var yesNoAll = promptForYesNoAllQuit('''Save the following hero locally?
$hero''');
        if (yesNoAll == YesNoAllQuit.quit) {
          Terminal.println("Aborting saving of further heroes");
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
      Terminal.println(
        '''Saved hero ${hero.externalId} ("${hero.name}") so it can save you:
$hero''',
      );
      ++saveCount;
    }
  } catch (e) {
    Terminal.println("Failed to parse online heroes: $e");
  }

  Terminal.println('''

Download complete at ${DateTime.timestamp()}: $saveCount heroes saved (so they can in turn save ${saveCount * saveCount * 10} people, or more, depending on their abilities).

''');
}

void deleteAllHeroes(HeroDataManaging heroDataManager) {
  if (!promptForYesNo("Do you really want to delete all heroes?")) {
    return;
  }
  heroDataManager.clear();
  Terminal.println("Deleted all heroes");
}

void deleteHeroUnprompted(HeroDataManaging heroDataManager, HeroModel hero) {
  heroDataManager.delete(hero);
  Terminal.println('''Deleted hero:
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
    Terminal.println("Aborted");
    return;
  }

  if (!promptForYesNo('''Save new hero with the following details?$hero''')) {
    return;
  }

  heroDataManager.persist(hero);
  Terminal.println('''Created hero:
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
    Terminal.println('''Amended hero:
$amededHero''');
  }
}

void unlockHero(HeroDataManaging heroDataManager) {
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
    Terminal.println("Hero is already unlocked");
    return;
  }

  if (unlockedHero.locked) {
    Terminal.println("Hero could not be unlocked");
    return;
  }

  heroDataManager.persist(unlockedHero);
  Terminal.println('''Hero was unlocked:
$unlockedHero''');
}

List<HeroModel>? search(
  HeroDataManaging heroDataManager, {
  String? query,
  bool Function(HeroModel)? filter,
}) {
  query ??= promptFor("Enter a search string in SHQL™ or plain text:");
  var results = heroDataManager.query(query, filter: filter);
  if (results.isEmpty) {
    Terminal.println("No heroes found");
    return null;
  }
  Terminal.println("Found ${results.length} heroes:");
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
      () async => await saveHeroes(heroDataManager),
      "[S]earch online for new heroes to save",
    ),
    "u": (
      () => unlockHero(heroDataManager),
      "[U]nlock manually amended heroes to enable reconciliation",
    ),
    "x": (() => {exit = true}, "E[X]it and return to main menu"),
  };

  void defaultCommand(String query) =>
      saveHeroes(heroDataManager, query: query);

  var prompt = generatePrompt(commands);

  while (!exit) {
    Terminal.println(prompt);
    try {
      await menu(heroDataManager, commands, defaultCommand: defaultCommand);
    } catch (e) {
      Terminal.println("Unexpected error: $e");
    }
  }
}

Future<void> reconcileHeroes(HeroDataManaging heroDataManager) async {
  var timestamp = DateTime.timestamp();
  Terminal.println(''' 

Reconciliation started at at $timestamp

''');
  HeroServicing? heroService;
  bool deleteAll = false;
  bool updateAll = false;
  var deletionCount = 0;
  var reconciliationCount = 0;
  for (var hero in heroDataManager.heroes) {
    heroService ??= HeroService(Env());
    var onlineHeroJson = await heroService.getById(hero.externalId);
    String? error;
    if (onlineHeroJson != null) {
      error = onlineHeroJson["error"];
    }

    if (onlineHeroJson == null || error != null) {
      if (hero.locked) {
        Terminal.println(
          '''Hero: ${hero.externalId} ("${hero.name}") does not exist online: "${error ?? 'Unknown error'}" but is locked by prior manual amendment - skipping deletion''',
        );
        continue;
      }

      if (deleteAll) {
        Terminal.println(
          'Hero: ${hero.externalId} ("${hero.name}") does not exist online: "${error ?? 'Unknown error'}" - deleting from local database',
        );
        deleteHeroUnprompted(heroDataManager, hero);
        ++deletionCount;
        continue;
      }

      var yesNoAllQuit = promptForYesNoAllQuit(
        'Hero: ${hero.externalId} ("${hero.name}") does not exist online: "${error ?? 'Unknown error'}" - delete it from local database?',
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
            Terminal.println("Aborting reconciliation of further heroes");
            return;
          }
      }
      continue;
    }

    var previousHeightConflictResolver = Height.conflictResolver;
    var previousWeightConflictResolver = Weight.conflictResolver;
    try {
      // Use height and weight conflict resolvers that use the system of units information from the the current hero being amended
      var heightConflictResolver = Height.conflictResolver =
          AutoConflictResolver<Height>(hero.appearance.height.systemOfUnits);
      var weightConflictResolver = Weight.conflictResolver =
          AutoConflictResolver<Weight>(hero.appearance.weight.systemOfUnits);

      var updatedHero = hero.apply(onlineHeroJson, timestamp, false);

      for (var error in heightConflictResolver.resolutionLog) {
        Terminal.println(error);
      }
      for (var error in weightConflictResolver.resolutionLog) {
        Terminal.println(error);
      }

      var sb = StringBuffer();
      var diff = hero.diff(updatedHero, sb);
      if (!diff) {
        Terminal.println(
          'Hero: ${hero.externalId} ("${hero.name}") is already up to date',
        );
        continue;
      }

      if (hero.locked) {
        Terminal.println(
          '''Hero: ${hero.externalId} ("${hero.name}") is locked by prior manual amendment, skipping reconciliation changes:

${sb.toString()}''',
        );
        continue;
      }

      if (updateAll) {
        heroDataManager.persist(updatedHero);
        ++reconciliationCount;
        Terminal.println(
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
            Terminal.println("Aborting reconciliation of further heroes");
            return;
          }
      }

      heroDataManager.persist(updatedHero);
      ++reconciliationCount;
      Terminal.println(
        '''Reconciled hero: ${hero.externalId} ("${hero.name}") with the following online changes:
${sb.toString()}''',
      );
    } catch (e) {
      Terminal.println(
        'Failed to reconcile hero: ${hero.externalId} ("${hero.name}"): $e',
      );
    } finally {
      Weight.conflictResolver = previousWeightConflictResolver;
      Height.conflictResolver = previousHeightConflictResolver;
    }
  }

  Terminal.println('''

Reconciliation complete at ${DateTime.timestamp()}: $reconciliationCount heroes reconciled, $deletionCount heroes deleted.

''');
}
