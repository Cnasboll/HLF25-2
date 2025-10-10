
import 'package:collection/collection.dart';
import 'package:v03/utils/enum_parsing.dart';

typedef LookupField<T> = Object? Function(T);
typedef FormatField<T> = String Function(T);

class Field<T> {
  Field(this.getter, this.name, this.description, {this.mutable = true, FormatField<T>? format, this.comparable = true})
      : format = format ?? ((t) => getter(t).toString());

  bool validateUpdate(T lhs, T rhs) {
    if (lhs == rhs) {
      return true;
    }
    return mutable;
  }

  String? formatUpdate(T lhs, T rhs) {
    if (!mutable) {
      return null;
    }

    if (getter(lhs) == getter(rhs)) {
      return null;
    }
    return "$name: ${format(lhs)} => ${format(rhs)}";
  }

  int compareField(T lhs, T rhs) {
    if (!comparable)
    {
      // Not part of comparison
      return 0;
    }

    if (lhs == null && rhs == null) {
      return 0;
    }

    if (lhs == null) {
      return -1; // null is considered smaller
    }

    if (rhs == null) {
      return 1;
    }

    // If both implement Comparable, use that (most common case).
    if (lhs is Comparable && rhs is Comparable) {
      try {
        final cmp = lhs.compareTo(rhs);
        if (cmp != 0) {
          return cmp;
        }
        return 0;
      } catch (_) {
        // Fall through to other strategies if compareTo throws or isn't compatible.
      }
    }

    // Booleans: true > false
    if (lhs is bool && rhs is bool) {
      if (lhs != rhs) {
        return lhs ? 1 : -1;
      }
      return 0;
    }

    // Enums: compare by index
    if (lhs is Enum && rhs is Enum) {
      final cmp = lhs.index.compareTo(rhs.index);
      if (cmp != 0) {
        return cmp;
      }
      return 0;
    }

    // Deep-equal complex structures -> treat equal
    if (deepEq.equals(lhs, rhs)) {
      return 0;
    }

    // Last resort: compare string representations to provide a deterministic
    // ordering even for unknown / mixed types.
    final lstr = lhs.toString();
    final rstr = rhs.toString();
    final cmp = lstr.compareTo(rstr);
    if (cmp != 0) {
      return cmp;
    }
    return 0;
  }

  int getIntForUpdate(T t, Map<String, dynamic> values) {
    return getInt(values, defaultValue:  getter(t) as int);
  }

  int getInt(Map<String, dynamic> values, {int defaultValue = 0}) {
    var str = values[name];
    if (str == null) {
      return defaultValue;
    }
    return int.tryParse(str) ?? defaultValue;
  }

  String getStringForUpdate(T t, Map<String, dynamic> values) {
    return getString(values, defaultValue: getter(t) as String);
  }

  String getString(Map<String, dynamic> values, {String defaultValue = ""}) {
    var str = values[name];
    if (str == null) {
      return defaultValue;
    }
    return str;
  }

  E getEnumForUpdate<E extends Enum>(T t, Iterable<E> enumValues, Map<String, dynamic> values) {
    return getEnum(enumValues, values, getter(t) as E);
  }

  E getEnum<E extends Enum>(Iterable<E> enumValues, Map<String, dynamic> values, E defaultValue) {
    return enumValues.findMatch(getString(values, defaultValue: defaultValue.name)) ?? defaultValue;
  }

  /// Function to get the field from an object
  LookupField<T> getter;

/// Descriptive name of a field
  String name;

  /// Description of a field
  String description;
  
  /// Function to format the field on an object as a presentable string
  FormatField<T> format;

  /// True if field is mutable
  bool mutable;

  /// True if field should be part of comparisons
  bool comparable;

  static const deepEq = DeepCollectionEquality();
}
