import 'package:v04/value_types/value_type.dart';

abstract interface class ConflictResolver<T extends ValueType<T>> {
  /// Resolve a conflict between [value] and [conflictingInDifferentUnit] value,
  /// returning the resolved value.
  (T?, String?) resolveConflict(
    String valueTypeName,
    T value,
    T conflictingInDifferentUnit,
    String error,
  );
}
