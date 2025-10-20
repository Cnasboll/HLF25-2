import 'package:v04/prompts/prompt.dart';
import 'package:v04/utils/enum_parsing.dart';
import 'package:v04/value_types/conflict_resolver.dart';
import 'package:v04/value_types/value_type.dart';

class ManualConflictResolver<T extends ValueType<T>>
    implements ConflictResolver<T> {
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
      var answer = promptFor(
        "$error.\nType ${value.systemOfUnits.name} to use the ${value.systemOfUnits.name} $valueTypeName '$value' or ${conflictingInDifferentUnit.systemOfUnits.name} to use the ${conflictingInDifferentUnit.systemOfUnits.name} $valueTypeName '$conflictingInDifferentUnit' value to resolve this conflict or enter to abort: ",
        value.systemOfUnits.name,
      );
      if (answer.isEmpty) {
        return (null, '$error. Conflict resolution cancelled by user');
      }
      systemOfUnits =
          SystemOfUnits.values.findMatch(answer) ?? value.systemOfUnits;
      var all = promptForNo(
        "Resolve future $valueTypeName conflicts by selecting the ${systemOfUnits.name} value for $valueTypeName?",
      );
      if (all) {
        _systemOfUnits = systemOfUnits;
      }
    }

    for (var v in [value, conflictingInDifferentUnit]) {
      if (v.systemOfUnits == systemOfUnits) {
        if (hadToPrompt) {
          print(
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
