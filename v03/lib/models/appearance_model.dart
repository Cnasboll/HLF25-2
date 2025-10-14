import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/value_types/height.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';
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

  static AppearanceModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppearanceModel(
        gender: Gender.unknown,
      );
    }
    return AppearanceModel(
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

  factory AppearanceModel.fromRow(Row row) {
    return AppearanceModel(
      gender: _genderField.getEnumFromRow(Gender.values, row, Gender.unknown),
      race: _raceField.getNullableStringFromRow(row),
      height: Height.tryParse(_heightField.getNullableStringFromRow(row)).$1,
      weight: Weight.tryParse(_weightField.getNullableStringFromRow(row)).$1,
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

    // if powerStats are the same, sort other fields ascending
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
  List<Field<AppearanceModel>> get fields => staticFields;

  static final Field<AppearanceModel> _genderField = Field<AppearanceModel>(
    (a) => a?.gender ?? Gender.unknown,
    Gender,
    "gender",
    Gender.values.map((e) => e.name).join(', '),
    format: (a) => (a?.gender ?? Gender.unknown).name,
    sqliteGetter: (a) => (a?.gender ?? Gender.unknown).name,
    nullable: false,
  );

  static final Field<AppearanceModel> _raceField = Field<AppearanceModel>(
    (a) => a?.race,
    String,
    "race",
    "Species in Latin or English",
  );

  static Field<AppearanceModel> get _heightField => Field<AppearanceModel>(
    (a) => a?.height,
    Height,
    'height',
    'Height in centimeters and / or feet and inches',
    sqliteGetter: ((a) => (a?.height).toString()),
    prompt: '. For multiple representations, enter a list in json format e.g. ["6\'2\\"", "188 cm"] or a single value like \'188 cm\', \'188\' or \'1.88\' (meters) without surrounding \'',
  );

  static Field<AppearanceModel> get _weightField => Field<AppearanceModel>(
    (p) => p?.weight,
    Weight,
    'weight',
    'Weight in kilograms and / or pounds',
    sqliteGetter: ((a) => (a?.weight).toString()),
    prompt: '. For multiple representations, enter a list in json format e.g. ["210 lb", "95 kg"] or a single value like \'95 kg\' or \'95\' (kilograms) without surrounding \'',
  );

  static final Field<AppearanceModel> _eyeColourField = Field<AppearanceModel>(
    (p) => p?.eyeColor,
    String,
    'eye-color',
    'The character\'s eye color of the most recent appearance',
  );

  static final Field<AppearanceModel> _hairColorField = Field<AppearanceModel>(
    (p) => p?.hairColor,
    String,
    'hair-color',
    'The character\'s hair color of the most recent appearance',
  );

  static final List<Field<AppearanceModel>> staticFields = [
    _genderField,
    _raceField,
    _heightField,
    _weightField,
    _eyeColourField,
    _hairColorField,
  ];
}
