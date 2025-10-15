import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';
import 'package:v03/amendable/field_base.dart';

class WorkModel extends Amendable<WorkModel> {
  WorkModel({this.occupation, this.base});

  WorkModel.from(WorkModel other)
    : this(occupation: other.occupation, base: other.base);

  WorkModel copyWith({String? occupation, String? base}) {
    return WorkModel(
      occupation: occupation ?? this.occupation,
      base: base ?? this.base,
    );
  }

  factory WorkModel.amendWith(
    WorkModel original,
    Map<String, dynamic>? amendment,
  ) {
    return WorkModel(
      occupation: _occupationField.getNullableStringForAmendment(
        original,
        amendment,
      ),
      base: _baseField.getNullableStringForAmendment(original, amendment),
    );
  }

  static WorkModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WorkModel();
    }
    return WorkModel(
      occupation: _occupationField.getNullableString(json),
      base: _baseField.getNullableString(json),
    );
  }

  factory WorkModel.fromRow(Row row) {
    return WorkModel(
      occupation: _occupationField.getNullableStringFromRow(row) ?? "",
      base: _baseField.getNullableStringFromRow(row) ?? "",
    );
  }

  final String? occupation;
  final String? base;

  @override
  WorkModel amendWith(Map<String, dynamic>? amendment) {
    return WorkModel.amendWith(this, amendment);
  }

  static WorkModel fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return WorkModel();
    }
    if (json.length != staticFields.length) {
      return WorkModel();
    }

    return WorkModel.fromJson(json);
  }

  @override
  List<FieldBase<WorkModel>> get fields => staticFields;

  static FieldBase<WorkModel> get _occupationField => Field.infer(
    (m) => m.occupation,
    'occupation',
    'Occupation of the character',
  );

  static FieldBase<WorkModel> get _baseField => Field.infer(
    (m) => m.base,
    'base',
    'A place where the character works or lives or hides rather frequently',
  );

  static final List<FieldBase<WorkModel>> staticFields = [
    _occupationField,
    _baseField,
  ];
}
