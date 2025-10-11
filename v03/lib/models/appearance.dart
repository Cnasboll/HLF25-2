import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/utils/enum_parsing.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';
import 'package:v03/value_types/weight.dart';

enum Gender { unknown, ambiguous, male, female, nonBinary, wontSay }

class Appearance extends Updateable<Appearance> {
  Appearance({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });

  factory Appearance.fromJsonUpdate(
    Appearance original,
    Map<String, dynamic> amendment,
  ) {
    return Appearance(
      gender: _genderField.getEnumForUpdate<Gender>(
        original,
        Gender.values,
        amendment,
      ),
      race: _raceField.getStringForUpdate(original, amendment),
      height: Height.parseList(
        _heightField.getStringListForUpdate(original, amendment),
      ),
      weight: Weight.parseList(
        _weightField.getStringListForUpdate(original, amendment),
      ),
      eyeColor: _eyeColourField.getStringForUpdate(original, amendment),
      hairColor: _hairColorField.getStringForUpdate(original, amendment),
    );
  }

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      gender: _genderField.getEnum<Gender>(Gender.values, json, Gender.unknown),
      race: _raceField.getString(json),
      height: Height.parseList(_heightField.getStringList(json)),
      weight: Weight.parseList(_weightField.getStringList(json)),
      eyeColor: _eyeColourField.getString(json),
      hairColor: _hairColorField.getString(json),
    );
  }

  factory Appearance.fromRow(Row row) {
    return Appearance(
      gender: Gender.values.tryParse(row['gender'] as String) ?? Gender.unknown,
      race: row['race'] as String,
      height: Height(cm: row['height_cm'] as int),
      weight: Weight(kg: row['weight_kg'] as int),
      eyeColor: row['eye_colour'] as String,
      hairColor: row['hair_colour'] as String,
    );
  }

  final Gender gender;
  final String race;
  final Height height;
  final Weight weight;
  final String eyeColor;
  final String hairColor;

  @override
  Appearance fromJsonUpdate(Map<String, dynamic> amendment) {
    return Appearance.fromJsonUpdate(this, amendment);
  }

  static Appearance? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return Appearance.fromJson(json);
  }

  bool get isMale => gender == Gender.male;
  int get genderComparisonFactor => isMale ? -1 : 1;

  @override
  int compareTo(Appearance other) {
    // Sort by non-male first and male second
    // as males are always weaker than everone else who are equal.
    int comparison = genderComparisonFactor.compareTo(
      other.genderComparisonFactor,
    );

    // Never soort heroes by race but by height ascending, weight, eye- and hair-color alphabetically
    if (comparison == 0) {
      comparison = (height.asMetric().cm ?? 0).compareTo(
        (other.height.asMetric().cm ?? 0),
      );
    }

    if (comparison == 0) {
      comparison = (weight.asMetric().kg ?? 0).compareTo(
        (other.weight.asMetric().kg ?? 0),
      );
    }

    if (comparison == 0) {
      comparison = eyeColor.compareTo(other.eyeColor);
    }

    if (comparison == 0) {
      comparison = hairColor.compareTo(other.hairColor);
    }

    return comparison;
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<Appearance>> get fields => staticFields;

  static final Field<Appearance> _genderField = Field<Appearance>(
    (h) => h.gender,
    "gender",
    Gender.values.map((e) => e.name).join(', '),
    format: (h) => h.gender.name,
  );

  static final Field<Appearance> _raceField = Field<Appearance>(
    (h) => h.race,
    "race",
    "Species in Latin or English",
  );

  static Field<Appearance> get _heightField => Field<Appearance>(
    (p) => p.height,
    'height',
    'Height in centimeters and / or feet and inches',
  );

  static Field<Appearance> get _weightField => Field<Appearance>(
    (p) => p.weight,
    'weight',
    'Weight in kilograms and / or pounds',
  );

  static final Field<Appearance> _eyeColourField = Field<Appearance>(
    (p) => p.eyeColor,
    'eye-colour',
    'The character\'s eye color of the most recent appearance',
  );

  static final Field<Appearance> _hairColorField = Field<Appearance>(
    (p) => p.hairColor,
    'hair-colour',
    'The character\'s hair color of the most recent appearance',
  );

  static final List<Field<Appearance>> staticFields = [
    _genderField,
    _raceField,
    _weightField,
    _heightField,
    _eyeColourField,
    _hairColorField,
  ];
}
