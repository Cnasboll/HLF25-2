import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:v03/prompts/prompt.dart';
import 'package:v03/utils/enum_parsing.dart';
import 'package:v03/utils/json_parsing.dart';

typedef LookupField<T> = Object? Function(T?);
typedef FormatField<T> = String Function(T?);
typedef SQLGetter<T> = Object? Function(T?);

class Field<T> {
  Field(
    this.getter,
    this.type,
    this.name,
    this.description, {
    this.primary = false,
    this.nullable = true,
    this.assignedBySystem = false,
    FormatField<T>? format,
    this.comparable = true,
    this.prompt,
    bool? mutable,
    String? jsonName,
    String? sqlLiteName,
    List<Field>? children,
    LookupField<T>? sqliteGetter,
  }) : mutable = mutable ?? !primary,
       format = format ?? ((t) => getter(t).toString()),
       jsonName = jsonName ?? name,
       sqlLiteName = sqlLiteName ?? name.replaceAll('-', '_').toLowerCase(),
       _children = children ?? [],
       sqliteGetter = sqliteGetter ?? ((t) => getter(t));

  bool promptForJson(Map<String, dynamic> json, {String? crumbtrail}) {
    String cr = crumbtrail != null ? "$crumbtrail." : "";
    var fullPath = '$cr$name';
    if (_children.isEmpty) {
      String abortPrompt = crumbtrail != null ? "finish populating $crumbtrail" : "abort";
      var promptSuffix = prompt != null ? '$prompt' : '';
      print("Enter $fullPath ($description$promptSuffix), or enter to $abortPrompt:");
      var input = (stdin.readLineSync() ?? "").trim();
      if (input.isEmpty) {
        return false;
      }
      json[jsonName] = input;
      return true;
    }

    if (promptForYesNo('Populate $fullPath?')) {
      var childJson = json[jsonName] = <String, dynamic>{};
      for (var child in _children) {
        if (!child.promptForJson(childJson, crumbtrail: fullPath)) {
          return true;
        }
      }
    }
    return true;
  }

  void promptForAmendmentJson(T t,
    Map<String, dynamic> amendment, {
    String? crumbtrail,
  }) {
    String cr = crumbtrail != null ? "$crumbtrail." : "";
    var fullPath = '$cr$name';
    if (_children.isEmpty) {
      var promptSuffix = prompt != null ? '$prompt' : '';
      var current = format(t);
      print(
        "Enter $fullPath ($description$promptSuffix), or enter to keep current value ($current):",
      );
      var input = (stdin.readLineSync() ?? "").trim();
      if (input.isEmpty) {
        amendment[jsonName] = current;
      } else {
        amendment[jsonName] = input;
      }
      return;
    }

    if (promptForYes('Amend $fullPath?')) {
      var childAmendment = amendment[jsonName] = <String, dynamic>{};
      for (var child in _children) {
        child.promptForAmendmentJson(getter(t), childAmendment, crumbtrail: fullPath);
      }
    }
  }

  bool validateAmendment(T lhs, T rhs) {
    if (lhs == rhs) {
      return true;
    }
    for (var child in _children) {
      if (!child.validateAmendment(lhs, rhs)) {
        return false;
      }
    }
    return mutable;
  }

  void formatField(T? t, StringBuffer sb, {String? crumbtrail}) {
    var cr = crumbtrail != null ? "$crumbtrail.$name" : name;  
    if (_children.isEmpty) {
      sb.writeln("$cr: ${format(t)}");
      return;
    }

    var childObject = getter(t);
    if (childObject == null) {
      sb.writeln("$cr: null");
      return;
    }
    
    for (var child in _children) {
      child.formatField(childObject, sb, crumbtrail: cr);
    }
  }

  String? formatAmendment(T? lhs, T? rhs, {String? crumbtrail}) {
    if (!mutable || assignedBySystem) {
      return null;
    }

    if (getter(lhs) == getter(rhs)) {
      return null;
    }

    if (_children.isEmpty) {
      String cr = crumbtrail != null ? "$crumbtrail." : "";
      return "$cr$name: ${format(lhs)} => ${format(rhs)}";
    }

    StringBuffer amedment = StringBuffer();
    for (var child in _children) {
      var cr = crumbtrail != null ? "$crumbtrail.$name" : name;
      var childAmendment = child.formatAmendment(lhs, rhs, crumbtrail: cr);
      if (childAmendment != null) {
        amedment.writeln(childAmendment);
      }
    }

    if (amedment.isEmpty) {
      return null;
    }
    return amedment.toString();
  }

  int compareField(T lhs, T rhs) {
    if (!comparable) {
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

  int? getIntForAmendment(T t, Map<String, dynamic>? amendment) {
    return getNullableIntFromJson(amendment) ?? getter(t) as int?;
  }

  int getIntFromJson(Map<String, dynamic>? json, int defaultValue) {
    return getNullableIntFromJson(json) ?? defaultValue;
  }

  int? getNullableIntFromJson(Map<String, dynamic>? json) {
    var value = json?[jsonName];

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  int getIntFromRow(Row row, int defaultValue) {
    return row[sqlLiteName] as int? ?? defaultValue;
  }

  int? getNullableIntFromRow(Row row) {
    return row[sqlLiteName] as int?;
  }

  String getStringFromJsonForAmendment(T t, Map<String, dynamic>? amendment) {
    return getStringFromJson(amendment, getter(t) as String);
  }

  String? getNullableStringFromJsonForAmendment(
    T t,
    Map<String, dynamic>? amendment,
  ) {
    return getNullableStringFromJson(amendment) ?? getter(t) as String?;
  }

  String? getNullableStringFromJson(Map<String, dynamic>? json) {
    return json?[jsonName];
  }

  String getStringFromJson(Map<String, dynamic>? json, String defaultValue) {
    return json?[jsonName] ?? defaultValue;
  }

  Map<String, dynamic>? getJsonFromJson(Map<String, dynamic>? json) {
    return json?[jsonName] as Map<String, dynamic>?;
  }

  String? getNullableStringFromRow(Row row) {
    return row[sqlLiteName] as String?;
  }

  String getStringFromRow(Row row, String defaultValue) {
    return row[sqlLiteName] as String? ?? defaultValue;
  }

  List<String> getStringListFromJsonForAmendment(
    T t,
    Map<String, dynamic>? amendment,
  ) {
    return getStringListFromJson(amendment, getter(t) as List<String>);
  }

  List<String>? getNullableStringListFromJsonForAmendment(
    T t,
    Map<String, dynamic>? amendment,
  ) {
    var l = getNullableStringListFromJson(amendment);

    if (l != null) {
      return l;
    }

    var current = getter(t);

    if (current == null) {
      return null;
    }

    if (current is List<String>) {
      return current;
    }

    return [current.toString()];
  }

  List<String> getStringListFromJson(
    Map<String, dynamic>? json,
    List<String> defaultValue,
  ) {
    return getNullableStringListFromJson(json) ?? defaultValue;
  }

  List<String>? getNullableStringListFromJson(Map<String, dynamic>? json) {
    return getNullableStringList( json, jsonName);
  }

  List<String> getStringListFromRow(Row row, List<String> defaultValue) {
    return getNullableStringListFromRow(row) ?? defaultValue;
  }

  List<String>? getNullableStringListFromRow(Row row) {
    var json = getNullableStringFromRow(row);
    if (json == null) {
      return null;
    }
    return jsonDecode(json)?.cast<String>();
  }

  E getEnumForAmendment<E extends Enum>(
    T t,
    Iterable<E> enumValues,
    Map<String, dynamic>? amendment,
  ) {
    return getEnumFromJson(enumValues, amendment, getter(t) as E);
  }

  E getEnumFromJson<E extends Enum>(
    Iterable<E> enumValues,
    Map<String, dynamic>? amendment,
    E defaultValue,
  ) {
    return enumValues.findMatch(
          getStringFromJson(amendment, defaultValue.name),
        ) ??
        defaultValue;
  }

  E getEnumFromRow<E extends Enum>(
    Iterable<E> enumValues,
    Row row,
    E defaultValue,
  ) {
    return enumValues.findMatch(
          getNullableStringFromRow(row) ?? defaultValue.name,
        ) ??
        defaultValue;
  }

  String sqlLiteQualifier(/*bool nullable*/) {
    if (primary) {
      return 'PRIMARY KEY';
    }

    var qualifier = nullable ? '' : 'NOT ';
    return '${qualifier}NULL';
  }

  String generateSqliteColumnType() {
    String columnType;

    // My only nested if statement in this project and hopefully the entire course

    if (type == int) {
      columnType = "INTEGER";
    } else if (type == String) {
      columnType = "TEXT";
    } else if (type == bool) {
      columnType = "BOOLEAN";
    } else if (type == double) {
      columnType = "REAL";
    } else if (type == Enum) {
      columnType = "TEXT";
    } else {
      // Fallback to TEXT for complex types
      columnType = "TEXT";
    }

    return "$columnType ${sqlLiteQualifier()}";
  }

  List<Object?> sqliteProps(T? t) {
    if (_children.isEmpty) {
      return [sqliteGetter(t)];
    }
    return _children.expand((c) => c.sqliteProps(getter(t))).toList();
  }

  String generateSQLiteInsertColumnPlaceholders() {
    if (_children.isEmpty) {
      return "?";
    }
    return _children
        .map((c) => c.generateSQLiteInsertColumnPlaceholders())
        .join(',');
  }

  String generateSqliteColumnNameList(String indent) {
    if (_children.isEmpty) {
      return sqlLiteName;
    }
    return _children
        .map((c) => c.generateSqliteColumnNameList(indent))
        .join(',\n$indent');
  }

  String generateSqliteColumnDeclarations(String indent) {
    if (_children.isEmpty) {
      return "$sqlLiteName ${generateSqliteColumnType()}";
    }
    return _children
        .map((c) => c.generateSqliteColumnDeclarations(indent))
        .join(',\n$indent');
  }

  String generateSqliteColumnDefinition() {
    if (_children.isEmpty) {
      return "$sqlLiteName ${generateSqliteColumnType()}";
    }
    return '${_children.map((c) => c.generateSqliteColumnDefinition()).join(',\n')}\n';
  }

  String generateSqliteUpdateClause(String indent) {
    if (_children.isEmpty) {
      return "$sqlLiteName=excluded.$sqlLiteName";
    }
    return _children
        .where((c) => c.mutable)
        .map((c) => c.generateSqliteUpdateClause(indent))
        .join(',\n$indent');
  }

  /// Function to get the field from an object
  LookupField<T> getter;

  /// The type of the field (todo: derive from result of getter?)
  Type type;

  /// Descriptive name of a field
  String name;

  /// Name of the field in JSON
  String jsonName;

  /// Name of the corresponding column in SQLite
  String sqlLiteName;

  /// Description of a field
  String description;

  /// Function to format the field on an object as a presentable string
  FormatField<T> format;

  /// Function to get the field from an object for SQLite inserts and updates
  SQLGetter<T> sqliteGetter;

  /// True if field is part of the primary key
  bool primary;

  /// True if db field is nullable (TODO: should be derived from the getter-type but that doesn't seem to work)
  bool nullable;

  /// True if field is mutable
  bool mutable;

  /// True if a field is assigned by the system and should not be prompted for during creation or update
  bool assignedBySystem;

  /// True if field should be part of comparisons
  bool comparable;

  /// Optional prompt suffix to be shown when prompting for this field
  String? prompt;

  final List<Field> _children;

  static const deepEq = DeepCollectionEquality();
}
