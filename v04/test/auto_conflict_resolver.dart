import 'package:v04/value_types/conflict_resolver.dart';
import 'package:v04/value_types/value_type.dart';

class AutoConflictResolver<T extends ValueType<T>>
    implements ConflictResolver<T> {
  @override
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  ) {
    print("$error. Resolving by using first provided (${value.systemOfUnits.name}) value for $valueTypeName: '$value'.");
    return (value, null); // Always pick the first value
  }
}
