import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';
import 'package:v03/value_types/weight.dart';

enum Gender { unknown, ambiguous, male, female, nonBinary, wontSay }

class Appearance extends Updateable<Appearance> {
  Appearance({
    required this.gender,
    this.race,
    this.height,
    this.weight,
    this.eyeColor,
    this.hairColor,
  });

  Appearance.from(Appearance other)
    : this(
        gender: other.gender,
        race: other.race,
        height: other.height,
        weight: other.weight,
        eyeColor: other.eyeColor,
        hairColor: other.hairColor,
      );

  Appearance copyWith({
    Gender? gender,
    String? race,
    Height? height,
    Weight? weight,
    String? eyeColor,
    String? hairColor,
  }) {
    return Appearance(
      gender: gender ?? this.gender,
      race: race ?? this.race,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
    );
  }

  factory Appearance.fromJsonAmendment(
    Appearance original,
    Map<String, dynamic>? amendment,
  ) {
    return Appearance(
      gender: _genderField.getEnumForAmendment<Gender>(
        original,
        Gender.values,
        amendment,
      ),
      race: _raceField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      height: Height.parseList(
        _heightField.getNullableStringListFromJsonForAmendment(
          original,
          amendment,
        ),
      ),
      weight: Weight.parseList(
        _weightField.getNullableStringListFromJsonForAmendment(
          original,
          amendment,
        ),
      ),
      eyeColor: _eyeColourField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      hairColor: _hairColorField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
    );
  }

  static Appearance? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return Appearance(
      gender: _genderField.getEnumFromJson<Gender>(
        Gender.values,
        json,
        Gender.unknown,
      ),
      race: _raceField.getNullableStringFromJson(json),
      height: Height.parseList(
        _heightField.getNullableStringListFromJson(json),
      ),
      weight: Weight.parseList(
        _weightField.getNullableStringListFromJson(json),
      ),
      eyeColor: _eyeColourField.getNullableStringFromJson(json),
      hairColor: _hairColorField.getNullableStringFromJson(json),
    );
  }

  factory Appearance.fromRow(Row row) {
    return Appearance(
      gender: _genderField.getEnumFromRow(Gender.values, row, Gender.unknown),
      race: _raceField.getNullableStringFromRow(row),
      height: Height.tryParse(_heightField.getNullableStringFromRow(row)).$1,
      weight: Weight.tryParse(_weightField.getNullableStringFromRow(row)).$1,
      eyeColor: _eyeColourField.getNullableStringFromRow(row),
      hairColor: _hairColorField.getNullableStringFromRow(row),
    );
  }

  final Gender gender;
  final String? race;
  final Height? height;
  final Weight? weight;
  final String? eyeColor;
  final String? hairColor;

  static Appearance? amendOrCreate(
    Field field,
    Appearance? original,
    Map<String, dynamic>? amendment,
  ) {
    if (original == null) {
      return Appearance.fromJson(field.getJsonFromJson(amendment));
    }
    return original.fromJsonAmendment(field.getJsonFromJson(amendment));
  }

  @override
  Appearance fromJsonAmendment(Map<String, dynamic>? amendment) {
    return Appearance.fromJsonAmendment(this, amendment);
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
  int get genderComparisonFactor => isMale ? 1 : -1;

  @override
  int compareTo(Appearance other) {
    // Sort by non-male first and male second
    // as males are always weaker than everone else who are equal.
    int comparison = genderComparisonFactor.compareTo(
      other.genderComparisonFactor,
    );

    // Never sort appearances by race as that would be discriminatory, but by height ascending (as tall heroes always have an advantage in all areas of life
    // and herohood),
    if (comparison == 0) {
      _heightField.compareField(other, this);
    }

    if (comparison == 0) {
      comparison = _weightField.compareField(this, other);
    }

    if (comparison == 0) {
      _eyeColourField.compareField(this, other);
    }

    if (comparison == 0) {
      comparison = _hairColorField.compareField(this, other);
    }

    return comparison;
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<Appearance>> get fields => staticFields;

  static final Field<Appearance> _genderField = Field<Appearance>(
    (a) => a?.gender ?? Gender.unknown,
    Gender,
    "gender",
    Gender.values.map((e) => e.name).join(', '),
    format: (a) => (a?.gender ?? Gender.unknown).name,
    sqliteGetter: (a) => (a?.gender ?? Gender.unknown).name,
    nullable: false,
  );

  static final Field<Appearance> _raceField = Field<Appearance>(
    (a) => a?.race,
    String,
    "race",
    "Species in Latin or English",
  );

  static Field<Appearance> get _heightField => Field<Appearance>(
    (a) => a?.height,
    Height,
    'height',
    'Height in centimeters and / or feet and inches',
    sqliteGetter: ((a) => (a?.height).toString()),
  );

  static Field<Appearance> get _weightField => Field<Appearance>(
    (p) => p?.weight,
    Weight,
    'weight',
    'Weight in kilograms and / or pounds',
    sqliteGetter: ((a) => (a?.weight).toString()),
  );

  static final Field<Appearance> _eyeColourField = Field<Appearance>(
    (p) => p?.eyeColor,
    String,
    'eye-color',
    'The character\'s eye color of the most recent appearance',
  );

  static final Field<Appearance> _hairColorField = Field<Appearance>(
    (p) => p?.hairColor,
    String,
    'hair-color',
    'The character\'s hair color of the most recent appearance',
  );

  static final List<Field<Appearance>> staticFields = [
    _genderField,
    _raceField,
    _heightField,
    _weightField,
    _eyeColourField,
    _hairColorField,
  ];
}
