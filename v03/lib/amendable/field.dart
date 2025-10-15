import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field_base.dart';
import 'package:v03/prompts/prompt.dart';
import 'package:v03/utils/enum_parsing.dart';
import 'package:v03/utils/json_parsing.dart';
import 'package:v03/value_types/value_type.dart';

typedef LookupField<T, V> = V? Function(T);
typedef FormatField<T> = String Function(T);
typedef SQLGetter<T> = Object? Function(T);

class Field<T, V> implements FieldBase<T> {
  factory Field(
    LookupField<T, V> getter,
    String name,
    String description, {
    bool primary = false,
    bool nullable = true,
    FormatField<T>? format,
    bool comparable = true,
    String? prompt,
    bool? assignedBySystem,
    bool? mutable,
    String? jsonName,
    String? sqliteName,
    List<String>? sqliteNames,
    List<FieldBase>? children,
    SQLGetter<T>? sqliteGetter,
  }) {
    assignedBySystem = assignedBySystem ?? primary;
    mutable = mutable ?? !primary;
    // Derive jsonName and sqliteName from name if not provided, not from each other
    // to avoid accidental collisions (i.e. in our db we use British spelling for some fields as we control it)
    jsonName = jsonName ?? (name.replaceAll(' ', '-').toLowerCase());

    if (sqliteName != null && sqliteNames != null) {
      throw ArgumentError('Cannot provide both sqliteName and sqliteNames');
    }

    sqliteNames ??= [
      sqliteName ??
          (name.replaceAll(' ', '-').replaceAll('-', '_').toLowerCase()),
    ];

    format = format ?? ((t) => getter(t).toString());
    children = children ?? <FieldBase>[];
    sqliteGetter = sqliteGetter ?? ((t) => getter(t));

    return Field._internal(
      getter,
      name,
      jsonName,
      sqliteNames,
      description,
      format,
      sqliteGetter,
      primary,
      nullable,
      mutable,
      assignedBySystem,
      comparable,
      prompt,
      children,
    );
  }

  Field._internal(
    this._getter,
    this.name,
    this.jsonName,
    this.sqliteNames,
    this.description,
    this.format,
    this.sqliteGetter,
    this.primary,
    this.nullable,
    this._mutable,
    this.assignedBySystem,
    this.comparable,
    this.prompt,
    this._children,
  );

  // DRY for type: infer T from the getter's return type
  factory Field.infer(
    LookupField<T, V> getter,
    String name,
    String description, {
    bool primary = false,
    bool nullable = true,
    FormatField? format,
    bool comparable = true,
    String? prompt,
    bool? assignedBySystem,
    bool? mutable,
    String? jsonName,
    String? sqliteName,
    List<String>? sqLiteNames,
    List<FieldBase>? children,
    SQLGetter<T>? sqliteGetter,
  }) {
    return Field<T, V>(
      getter,
      name,
      description,
      primary: primary,
      nullable: nullable,
      format: format,
      comparable: comparable,
      prompt: prompt,
      assignedBySystem: assignedBySystem,
      mutable: mutable,
      jsonName: jsonName,
      sqliteName: sqliteName,
      sqliteNames: sqLiteNames,
      children: children,
      sqliteGetter: sqliteGetter,
    );
  }

  static String growCrumbTrail(String? crumbtrail, String name) {
    var cr = crumbtrail != null ? "$crumbtrail: " : "";
    return '$cr$name';
  }

  @override
  bool promptForJson(Map<String, dynamic> json, {String? crumbtrail}) {
    if (assignedBySystem) {
      return true;
    }
    var fullPath = growCrumbTrail(crumbtrail, name);
    if (_children.isEmpty) {
      String abortPrompt = crumbtrail != null
          ? "finish populating $crumbtrail"
          : "abort";
      var promptSuffix = prompt != null ? '$prompt' : '';
      print(
        "Enter $fullPath ($description$promptSuffix), or enter to $abortPrompt:",
      );
      var input = (readUtf8Line() ?? "").trim();
      if (input.isEmpty) {
        return false;
      }
      json[jsonName] = input;
      return true;
    }

    if (promptForYesNo('Populate $fullPath ($description)?')) {
      var childJson = json[jsonName] = <String, dynamic>{};
      for (var child in _children) {
        if (!child.promptForJson(childJson, crumbtrail: fullPath)) {
          return true;
        }
      }
    }
    return true;
  }

  @override
  void promptForAmendmentJson(
    T t,
    Map<String, dynamic> amendment, {
    String? crumbtrail,
  }) {
    if (!mutable || assignedBySystem) {
      return;
    }
    var fullPath = growCrumbTrail(crumbtrail, name);
    if (_children.isEmpty) {
      var promptSuffix = prompt != null ? '$prompt' : '';
      var current = format(t);
      print(
        "Enter $fullPath ($description$promptSuffix), or enter to keep current value ($current):",
      );
      var input = (readUtf8Line() ?? "").trim();
      if (input.isNotEmpty) {
        amendment[jsonName] = input;
      }
      return;
    }

    if (promptForYes('Amend $fullPath ($description)?')) {
      var childAmendment = amendment[jsonName] = <String, dynamic>{};
      for (var child in _children) {
        child.promptForAmendmentJson(
          getter(t),
          childAmendment,
          crumbtrail: fullPath,
        );
      }
    }
  }

  @override
  bool validateAmendment(T lhs, T rhs) {
    if (lhs == rhs || mutable) {
      return true;
    }
    for (var child in _children) {
      if (!child.validateAmendment(lhs, rhs)) {
        return false;
      }
    }
    return mutable;
  }

  @override
  bool matches(T t, String query) {
    var value = getter(t);
    if (value == null) {
      return false;
    }

    if (_children.isEmpty) {
      return format(t).toLowerCase().contains(query);
    }

    for (var child in _children) {
      if (child.matches(value, query)) {
        return true;
      }
    }
    return false;
  }

  @override
  void formatField(T t, StringBuffer sb, {String? crumbtrail}) {
    var fullPath = growCrumbTrail(crumbtrail, name);
    if (_children.isEmpty) {
      sb.writeln("$fullPath: ${format(t)}");
      return;
    }

    var childObject = getter(t);
    if (childObject == null) {
      sb.writeln("$fullPath: null");
      return;
    }

    for (var child in _children) {
      child.formatField(childObject, sb, crumbtrail: fullPath);
    }
  }

  @override
  bool diff(T lhs, T rhs, StringBuffer sb, {String? crumbtrail}) {
    var lhsValue = getter(lhs);
    var rhsValue = getter(rhs);

    if (!mutable || assignedBySystem || lhsValue == rhsValue) {
      return false;
    }

    var fullPath = growCrumbTrail(crumbtrail, name);
    if (_children.isEmpty) {
      sb.writeln("$fullPath: ${format(lhs)} -> ${format(rhs)}");
      return true;
    }

    bool hasChildDifferences = false;
    for (var child in _children) {
      hasChildDifferences |= child.diff(
        lhsValue,
        rhsValue,
        sb,
        crumbtrail: fullPath,
      );
    }
    return hasChildDifferences;
  }

  @override
  int compareField(T lhs, T rhs) {
    if (!comparable) {
      // Not part of comparison
      return 0;
    }

    var lhsValue = getter(lhs);
    var rhsValue = getter(rhs);

    if (lhsValue == null && rhsValue == null) {
      return 0;
    }

    if (lhsValue == null) {
      return -1; // null is considered smaller
    }

    if (rhsValue == null) {
      return 1;
    }

    // If both implement Comparable, use that (most common case).
    if (lhsValue is Comparable && rhsValue is Comparable) {
      try {
        final cmp = lhsValue.compareTo(rhsValue);
        if (cmp != 0) {
          return cmp;
        }
        return 0;
      } catch (_) {
        // Fall through to other strategies if compareTo throws or isn't compatible.
      }
    }

    // Booleans: true > false
    if (lhsValue is bool && rhsValue is bool) {
      if (lhsValue != rhsValue) {
        return lhsValue ? 1 : -1;
      }
      return 0;
    }

    // Enums: compare by index
    if (lhsValue is Enum && rhsValue is Enum) {
      final cmp = lhsValue.index.compareTo(rhsValue.index);
      if (cmp != 0) {
        return cmp;
      }
      return 0;
    }

    // Deep-equal complex structures -> treat equal
    if (deepEq.equals(lhsValue, rhsValue)) {
      return 0;
    }

    // Last resort: compare string representations to provide a deterministic
    // ordering even for unknown / mixed types.
    final lstr = lhsValue.toString();
    final rstr = rhsValue.toString();
    final cmp = lstr.compareTo(rstr);
    if (cmp != 0) {
      return cmp;
    }
    return 0;
  }

  @override
  int? getIntForAmendment(T t, Map<String, dynamic>? amendment) {
    return getNullableInt(amendment) ?? getter(t) as int?;
  }

  @override
  int getIntFromJson(Map<String, dynamic>? json, int defaultValue) {
    return getNullableInt(json) ?? defaultValue;
  }

  @override
  int? getNullableInt(Map<String, dynamic>? json) {
    var value = json?[jsonName];

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  @override
  int getIntFromRow(Row row, int defaultValue, {int index = 0}) {
    return row[sqliteNames[index]] as int? ?? defaultValue;
  }

  @override
  int? getNullableIntFromRow(Row row, {int index = 0}) {
    return row[sqliteNames[index]] as int?;
  }

  @override
  double getFloatFromRow(Row row, double defaultValue, {int index = 0}) {
    return row[sqliteNames[index]] as double? ?? defaultValue;
  }

  @override
  double? getNullableFloatFromRow(Row row, {int index = 0}) {
    return row[sqliteNames[index]] as double?;
  }

  @override
  String getStringForAmendment(T t, Map<String, dynamic>? amendment) {
    return getString(amendment, getter(t) as String);
  }

  @override
  String? getNullableStringForAmendment(T t, Map<String, dynamic>? amendment) {
    return getNullableString(amendment) ?? getter(t) as String?;
  }

  @override
  String? getNullableString(Map<String, dynamic>? json) {
    return json?[jsonName];
  }

  @override
  String getString(Map<String, dynamic>? json, String defaultValue) {
    return json?[jsonName] ?? defaultValue;
  }

  @override
  Map<String, dynamic>? getJson(Map<String, dynamic>? json) {
    return json?[jsonName] as Map<String, dynamic>?;
  }

  @override
  String? getNullableStringFromRow(Row row, {int index = 0}) {
    return row[sqliteNames[index]] as String?;
  }

  @override
  String getStringFromRow(Row row, String defaultValue, {int index = 0}) {
    return row[sqliteNames[index]] as String? ?? defaultValue;
  }

  @override
  List<String> getStringListFromJsonForAmendment(
    T t,
    Map<String, dynamic>? amendment,
  ) {
    return getStringList(amendment, getter(t) as List<String>);
  }

  @override
  List<String>? getNullableStringListFromJsonForAmendment(
    T t,
    Map<String, dynamic>? amendment,
  ) {
    var l = getNullableStringList(amendment);

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

  @override
  List<String> getStringList(
    Map<String, dynamic>? json,
    List<String> defaultValue,
  ) {
    return getNullableStringList(json) ?? defaultValue;
  }

  @override
  List<String>? getNullableStringList(Map<String, dynamic>? json) {
    return getNullableStringListFromMap(json, jsonName);
  }

  @override
  List<String> getStringListFromRow(
    Row row,
    List<String> defaultValue, {
    int index = 0,
  }) {
    return getNullableStringListFromRow(row, index: index) ?? defaultValue;
  }

  @override
  List<String>? getNullableStringListFromRow(Row row, {int index = 0}) {
    var json = getNullableStringFromRow(row, index: index);
    if (json == null) {
      return null;
    }
    return jsonDecode(json)?.cast<String>();
  }

  @override
  E getEnumForAmendment<E extends Enum>(
    T t,
    Iterable<E> enumValues,
    Map<String, dynamic>? amendment,
  ) {
    return getEnum(enumValues, amendment, getter(t) as E);
  }

  @override
  E getEnum<E extends Enum>(
    Iterable<E> enumValues,
    Map<String, dynamic>? amendment,
    E defaultValue,
  ) {
    return enumValues.findMatch(getString(amendment, defaultValue.name)) ??
        defaultValue;
  }

  @override
  E getEnumFromRow<E extends Enum>(
    Iterable<E> enumValues,
    Row row,
    E defaultValue, {
    int index = 0,
  }) {
    return enumValues.findMatch(
          getNullableStringFromRow(row, index: index) ?? defaultValue.name,
        ) ??
        defaultValue;
  }

  @override
  List<String> sqliteQualifiers() {
    if (primary) {
      return ['PRIMARY KEY'];
    }

    var qualifier = nullable ? '' : 'NOT ';
    return ['${qualifier}NULL'];
  }

  @override
  List<String> generateSqliteColumnTypes() {
    String columnType;

    // My only nested if statement in this project and hopefully the entire course

    if (<V>[] is List<ValueType>) {
      return ValueType.generateSqliteColumnTypes();
    }

    if (V == int) {
      columnType = "INTEGER";
    } else if (V == String) {
      columnType = "TEXT";
    } else if (V == bool) {
      columnType = "BOOLEAN";
    } else if (V == double) {
      columnType = "REAL";
    } else if (V == Enum) {
      columnType = "TEXT";
    } else {
      // Fallback to TEXT for complex types
      columnType = "TEXT";
    }

    return ["$columnType ${sqliteQualifiers()[0]}"];
  }

  @override
  List<Object?> sqliteProps(T t) {
    if (_children.isEmpty) {
      var v = sqliteGetter(t);
      if (v is List<Object?>) {
        return v;
      }
      return [v];
    }
    return _children.expand((c) => c.sqliteProps(getter(t))).toList();
  }

  @override
  String generateSQLiteInsertColumnPlaceholders() {
    if (_children.isEmpty) {
      return List.filled(sqliteNames.length, '?').join(',');
    }
    return _children
        .map((c) => c.generateSQLiteInsertColumnPlaceholders())
        .join(',');
  }

  @override
  String generateSqliteColumnNameList(String indent) {
    if (_children.isEmpty) {
      return sqliteNames.join(',\n$indent');
    }
    return _children
        .map((c) => c.generateSqliteColumnNameList(indent))
        .join(',\n$indent');
  }

  @override
  String generateSqliteColumnDeclarations(String indent) {
    if (_children.isEmpty) {
      var columnTypes = generateSqliteColumnTypes();
      var columnsAndTypes = List.generate(
        sqliteNames.length,
        (index) => (sqliteNames[index], columnTypes[index]),
      );
      return columnsAndTypes.map((e) => "${e.$1} ${e.$2}").join(',\n$indent');
    }
    return _children
        .map((c) => c.generateSqliteColumnDeclarations(indent))
        .join(',\n$indent');
  }

  @override
  String generateSqliteColumnDefinition() {
    if (_children.isEmpty) {
      var columnTypes = generateSqliteColumnTypes();
      var columnsAndTypes = List.generate(
        sqliteNames.length,
        (index) => (sqliteNames[index], columnTypes[index]),
      );
      return columnsAndTypes.map((e) => "${e.$1} ${e.$2}").join(',\n');
    }
    return '${_children.map((c) => c.generateSqliteColumnDefinition()).join(',\n')}\n';
  }

  @override
  String generateSqliteUpdateClause(String indent) {
    if (_children.isEmpty) {
      return sqliteNames
          .map((sqliteName) => "$sqliteName=excluded.$sqliteName")
          .join(',\n$indent');
    }
    return _children
        .where((c) => c.mutable)
        .map((c) => c.generateSqliteUpdateClause(indent))
        .join(',\n$indent');
  }

  /// Function to get the field from an object
  @override
  LookupField<T, Object?> get getter => _getter;

  LookupField<T, V> _getter;

  /// Descriptive name of a field
  String name;

  /// Name of the field in JSON
  String jsonName;

  /// Name of the corresponding column(s) in SQLite
  List<String> sqliteNames;

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

  @override
  bool get mutable => _mutable;

  bool _mutable;

  /// True if a field is assigned by the system and should not be prompted for during creation or update
  bool assignedBySystem;

  /// True if field should be part of comparisons
  bool comparable;

  /// Optional prompt suffix to be shown when prompting for this field
  String? prompt;

  final List<FieldBase> _children;

  static const deepEq = DeepCollectionEquality();
}
