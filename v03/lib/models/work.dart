import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class Work extends Updateable<Work> {
  Work({
    required this.occupation,
    required this.base,
  });

  factory Work.fromJsonUpdate(
    Work original,
    Map<String, dynamic> amendment,
  ) {
    return Work(
      occupation: _occupationField.getStringForUpdate(original, amendment),
      base: _baseField.getStringForUpdate(original, amendment),      
    );
  }

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      occupation: _occupationField.getString(json),
      base: _baseField.getString(json),
    );
  }

    factory Work.fromRow(Row row) {
    return Work(
      occupation: row['occupation'] as String,
      base: row['base'] as String,
    );
  }

  final String occupation;
  final String base;
  

  @override
  Work fromJsonUpdate(Map<String, dynamic> amendment) {
    return Work.fromJsonUpdate(this, amendment);
  }

  static Work? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return Work.fromJson(json);
  }


  @override
  List<Field<Work>> get fields => staticFields;

  static Field<Work> get _occupationField => Field<Work>(
    (p) => p.occupation,
    'occupation',
    'Occupation of the character',
  );

  static final Field<Work> _baseField = Field<Work>(
    (p) => p.base,
    'base',
    'A place where the character works or lives or hides rather frequently',
  );

  static final List<Field<Work>> staticFields = [
    _occupationField,
    _baseField,
  ];
 
}
