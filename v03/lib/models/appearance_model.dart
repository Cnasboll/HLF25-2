import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field_base.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';
import 'package:v03/value_types/value_type.dart';
import 'package:v03/value_types/weight.dart';

enum Gender { unknown, ambiguous, male, female, nonBinary, wontSay }

class AppearanceModel extends Amendable<AppearanceModel> {
  AppearanceModel({
    this.gender,
    this.race,
    this.height,
    this.weight,
    this.eyeColor,
    this.hairColor,
  });

  AppearanceModel.from(AppearanceModel other)
    : this(
        gender: other.gender,
        race: other.race,
        height: other.height,
        weight: other.weight,
        eyeColor: other.eyeColor,
        hairColor: other.hairColor,
      );

  AppearanceModel copyWith({
    Gender? gender,
    String? race,
    Height? height,
    Weight? weight,
    String? eyeColor,
    String? hairColor,
  }) {
    return AppearanceModel(
      gender: gender ?? this.gender,
      race: race ?? this.race,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      eyeColor: eyeColor ?? this.eyeColor,
      hairColor: hairColor ?? this.hairColor,
    );
  }

  factory AppearanceModel.amendWith(
    AppearanceModel original,
    Map<String, dynamic>? amendment,
  ) {
    return AppearanceModel(
      gender: _genderField.getEnumForAmendment<Gender>(
        original,
        Gender.values,
        amendment,
      ),
      race: _raceField.getNullableStringForAmendment(original, amendment),
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
      eyeColor: _eyeColourField.getNullableStringForAmendment(
        original,
        amendment,
      ),
      hairColor: _hairColorField.getNullableStringForAmendment(
        original,
        amendment,
      ),
    );
  }

  static AppearanceModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppearanceModel(gender: Gender.unknown);
    }
    return AppearanceModel(
      gender: _genderField.getEnum<Gender>(Gender.values, json, Gender.unknown),
      race: _raceField.getNullableString(json),
      height: Height.parseList(_heightField.getNullableStringList(json)),
      weight: Weight.parseList(_weightField.getNullableStringList(json)),
      eyeColor: _eyeColourField.getNullableString(json),
      hairColor: _hairColorField.getNullableString(json),
    );
  }

  factory AppearanceModel.fromRow(Row row) {
    return AppearanceModel(
      gender: _genderField.getEnumFromRow(Gender.values, row, Gender.unknown),
      race: _raceField.getNullableStringFromRow(row),
      height: Height.fromRow(_heightField, row),
      weight: Weight.fromRow(_weightField, row),
      eyeColor: _eyeColourField.getNullableStringFromRow(row),
      hairColor: _hairColorField.getNullableStringFromRow(row),
    );
  }

  final Gender? gender;
  final String? race;
  final Height? height;
  final Weight? weight;
  final String? eyeColor;
  final String? hairColor;

  @override
  AppearanceModel amendWith(Map<String, dynamic>? amendment) {
    return AppearanceModel.amendWith(this, amendment);
  }

  static AppearanceModel fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return AppearanceModel();
    }
    if (json.length != staticFields.length) {
      return AppearanceModel();
    }

    return AppearanceModel.fromJson(json);
  }

  bool get isMale => gender == Gender.male;
  int get genderComparisonFactor => isMale ? 1 : -1;

  @override
  int compareTo(AppearanceModel other) {
    // Sort by non-male first and male second
    // as males are always weaker than everone else who are equal.
    int comparison = genderComparisonFactor.compareTo(
      other.genderComparisonFactor,
    );

    if (comparison != 0) {
      return comparison;
    }

    // Never sort appearances by race as that would be discriminatory, but by height ascending (as tall heroes always have
    // an advantage in all areas of life and herohood),
    comparison = _heightField.compareField(other, this);

    if (comparison != 0) {
      return comparison;
    }

    // Sort other fields ascending
    for (var field in [_weightField, _eyeColourField, _hairColorField]) {
      comparison = field.compareField(this, other);
      if (comparison != 0) {
        return comparison;
      }
    }
    return 0;
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<FieldBase<AppearanceModel>> get fields => staticFields;

  static final FieldBase<AppearanceModel> _genderField = Field.infer(
    (m) => m.gender ?? Gender.unknown,
    "Gender",
    Gender.values.map((e) => e.name).join(', '),
    format: (m) => (m.gender ?? Gender.unknown).toString().split('.').last,
    sqliteGetter: (m) => (m.gender ?? Gender.unknown).toString().split('.').last,
    nullable: false,
  );

  static final FieldBase<AppearanceModel> _raceField = Field.infer(
    (m) => m.race,
    "Race",
    "Species in Latin or English",
  );

  static FieldBase<AppearanceModel> get _heightField => Field.infer(
    (m) => m.height,
    "Height",
    'Height in centimeters and / or feet and inches',
    // Note that the database columns are height_m and height_system_of_units for presentation, so mapped to TWO columns
    // we don't STORE the string "6'2" but the numeric value 1.8796 and the systemOfUnits enum value "imperial" to document the source
    // for UI formatting
    sqLiteNames: ["height_m", "height_system_of_units"],
    sqliteGetter: (m) => ValueType.toSQLColumns(m.height),
    prompt:
        '. For multiple representations, enter a list in json format e.g. ["6\'2\\"", "188 cm"] or a single value like \'188 cm\', \'188\' or \'1.88\' (meters) without surrounding \'',
  );

  static FieldBase<AppearanceModel> get _weightField => Field.infer(
    (m) => m.weight,
    "Weight",
    'Weight in kilograms and / or pounds',
    // Note that the database columns are weight_kg and weight_system_of_units for presentation, so mapped to TWO columns
    // we don't STORE "210 lb" but the numeric value 95.2543977 and the systemOfUnits enum value "imperial" to document the source
    // for UI formatting
    sqLiteNames: ["weight_kg", "weight_system_of_units"],
    sqliteGetter: (m) => ValueType.toSQLColumns(m.weight),
    prompt:
        '. For multiple representations, enter a list in json format e.g. ["210 lb", "95 kg"] or a single value like \'95 kg\' or \'95\' (kilograms) without surrounding \'',
  );

  static final FieldBase<AppearanceModel> _eyeColourField = Field.infer(
    (m) => m.eyeColor,
    "Eye Colour", // British spelling in db and in UI as we're in Europe
    jsonName: "eye-color",
    'The character\'s eye color of the most recent appearance',
  );

  static final FieldBase<AppearanceModel> _hairColorField = Field.infer(
    (m) => m.hairColor,
    "Hair Colour",  // British spelling in db and in UI as we're in Europe
    jsonName: "hair-color",
    'The character\'s hair color of the most recent appearance',
  );

  static final List<FieldBase<AppearanceModel>> staticFields = [
    _genderField,
    _raceField,
    _heightField,
    _weightField,
    _eyeColourField,
    _hairColorField,
  ];
}
