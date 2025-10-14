import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

class Work extends Amendable<Work> {
  Work({this.occupation, this.base});

  Work.from(Work other) : this(occupation: other.occupation, base: other.base);

  Work copyWith({String? occupation, String? base}) {
    return Work(
      occupation: occupation ?? this.occupation,
      base: base ?? this.base,
    );
  }

  factory Work.amendWith(
    Work original,
    Map<String, dynamic>? amendment,
  ) {
    return Work(
      occupation: _occupationField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      base: _baseField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
    );
  }

  static Work fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Work();
    }
    return Work(
      occupation: _occupationField.getNullableStringFromJson(json),
      base: _baseField.getNullableStringFromJson(json),
    );
  }

  factory Work.fromRow(Row row) {
    return Work(
      occupation: _occupationField.getNullableStringFromRow(row) ?? "",
      base: _baseField.getNullableStringFromRow(row) ?? "",
    );
  }

  final String? occupation;
  final String? base;

  @override
  Work amendWith(Map<String, dynamic>? amendment) {
    return Work.amendWith(this, amendment);
  }

  static Work fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return Work();
    }
    if (json.length != staticFields.length) {
      return Work();
    }

    return Work.fromJson(json);
  }

  @override
  List<Field<Work>> get fields => staticFields;

  static Field<Work> get _occupationField => Field<Work>(
    (p) => p?.occupation,
    String,
    'occupation',
    'Occupation of the character',
  );

  static final Field<Work> _baseField = Field<Work>(
    (p) => p?.base,
    String,
    'base',
    'A place where the character works or lives or hides rather frequently',
  );

  static final List<Field<Work>> staticFields = [_occupationField, _baseField];
}
