import 'package:v04/prompts/prompt.dart';
import 'package:v04/value_types/value_type.dart';

abstract class ConflictResolver<T extends ValueType<T>> {
  /// Resolve a conflict between [value] and [conflictingInDifferentUnit] value,
  /// returning the resolved value.
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  );

  List<String> resolutionLog = [];
}

class FirstProvidedValueConflictResolver<T extends ValueType<T>>
    extends ConflictResolver<T> {
  FirstProvidedValueConflictResolver() : super();

  @override
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  ) {
    resolutionLog.add(
      "$error. Resolving by using first provided (${value.systemOfUnits.name}) value for $valueTypeName: '$value'.",
    );
    return (value, null); // Always pick the first value
  }
}

class AutoConflictResolver<T extends ValueType<T>> extends ConflictResolver<T> {
  AutoConflictResolver(this.systemOfUnits);

  @override
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  ) {
    for (var v in [value, conflictingInDifferentUnit]) {
      if (v.systemOfUnits == systemOfUnits) {
        resolutionLog.add(
          "$error. Resolving by using value in current system of units (${systemOfUnits.name}) for $valueTypeName: '$v'.",
        );
        return (v, null);
      }
    }
    return (null, '$error. Failed to manually resolve conflict');
  }

  SystemOfUnits systemOfUnits;
}

class ManualConflictResolver<T extends ValueType<T>>
    extends ConflictResolver<T> {
  @override
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  ) {
    var systemOfUnits = _systemOfUnits;
    bool hadToPrompt = false;
    if (systemOfUnits == null) {
      hadToPrompt = true;
      for (;;) {
        var answer = promptFor(
          "$error.\nType '${value.systemOfUnits.name[0]}' to use the ${value.systemOfUnits.name} $valueTypeName '$value' or '${conflictingInDifferentUnit.systemOfUnits.name[0]}' to use the ${conflictingInDifferentUnit.systemOfUnits.name} $valueTypeName '$conflictingInDifferentUnit' value to resolve this conflict or enter to abort: ",
          value.systemOfUnits.name,
        ).toLowerCase();
        if (answer.isEmpty) {
          return (null, '$error. Conflict resolution cancelled by user');
        }
        if (value.systemOfUnits.name.toLowerCase().startsWith(answer)) {
          systemOfUnits = value.systemOfUnits;
          break;
        } else if (conflictingInDifferentUnit.systemOfUnits.name
            .toLowerCase()
            .startsWith(answer)) {
          systemOfUnits = conflictingInDifferentUnit.systemOfUnits;
          break;
        }
      }
      var all = promptForNo(
        "Resolve further $valueTypeName conflicts by selecting the ${systemOfUnits.name} value for $valueTypeName?",
      );
      if (all) {
        _systemOfUnits = systemOfUnits;
      }
    }

    for (var v in [value, conflictingInDifferentUnit]) {
      if (v.systemOfUnits == systemOfUnits) {
        if (hadToPrompt) {
          resolutionLog.add(
            "$error. Resolving by using value in previously decided system of units (${systemOfUnits.name}) for $valueTypeName: '$v'.",
          );
        }
        return (v, null);
      }
    }
    return (null, '$error. Failed to manually resolve conflict');
  }

  SystemOfUnits? _systemOfUnits;
}
