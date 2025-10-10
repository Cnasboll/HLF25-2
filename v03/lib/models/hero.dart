import 'dart:vmservice_io';

import 'package:uuid/uuid.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

// Levels of evilness
enum Alignment {
  unknown,
  neutral,
  mostlyGood,
  good,
  reasonable,
  notQuite,
  bad,
  ugly,
  evil,
  usingMobileSpeakerOnPublicTransport,
}

enum Gender { unknown, ambiguous, male, female, nonBinary, wontSay }

class Hero extends Updateable<Hero> {
  Hero({
    required this.id,
    required this.serverId,
    required this.version,
    required this.name,
    required this.strength,
    required this.gender,
    required this.race,
    required this.alignment,
  });

  Hero.newId(
    int serverId,
    String name,
    int strength,
    Gender gender,
    String race,
    Alignment alignment,
  ) : this(
        id: Uuid().v4(),                
        version: 1,
        serverId: serverId,
        name: name,
        strength: strength,
        gender: gender,
        race: race,
        alignment: alignment,
      );
    
  factory Hero.fromJsonUpdate(Hero original, Map<String, dynamic> amendment) {
    return Hero(
      id: original.id,
      version: original.version + 1,
      serverId: original.serverId,
      name: _nameField.getStringForUpdate(original, amendment),
      strength: _strengthField.getIntForUpdate(original, amendment),
      gender: _genderField.getEnumForUpdate<Gender>(
        original,
        Gender.values,
        amendment,
      ),
      race: _raceField.getStringForUpdate(original, amendment),
      alignment: _alignmentField.getEnumForUpdate<Alignment>(
        original,
        Alignment.values,
        amendment,
      ),
    );
  }

  factory Hero.fromJsonNewId(Map<String, dynamic> json) {
    return Hero.newId(
      _serverIdField.getInt(json),
      _nameField.getString(json),
      _strengthField.getInt(json),
      _genderField.getEnum<Gender>(Gender.values, json, Gender.unknown),
      _raceField.getString(json),
      _alignmentField.getEnum<Alignment>(Alignment.values, json, Alignment.unknown),
    );
  }

  Hero.copy(Hero other)
    : this(
        id: other.id,
        version: other.version,        
        serverId: other.serverId,
        name: other.name,
        strength: other.strength,
        gender: other.gender,
        race: other.race,
        alignment: other.alignment,
      );

  Hero copyWith({
    String? id,
    int? version,
    int? serverId,
    String? name,
    int? strength,
    Gender? gender,
    String? race,
    Alignment? alignment,
  }) {
    return Hero(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      version: (version ?? 1) + 1,
      name: name ?? this.name,
      strength: strength ?? this.strength,
      gender: gender ?? this.gender,
      race: race ?? this.race,
      alignment: alignment ?? this.alignment,
    );
  }

  bool get isMale => gender == Gender.male;
  int get genderComparisonFactor => isMale ? -1 : 1;

  @override
  int compareTo(Hero other) {
    // Sort by strength, descending
    var comparison = other.strength.compareTo(strength);

    // if strength is the same, sort by alignment
    if (comparison == 0) {
      comparison = alignment.index.compareTo(other.alignment.index);
    }

    // if strength and alignment is the same, sort by non-male first and male second
    // as males are always weaker than everone else who are equal.
    if (comparison == 0) {
      comparison = genderComparisonFactor.compareTo(
        other.genderComparisonFactor,
      );
    }

    // Don't compare race but sort by name alphabetically ascending, case insensitive.
    if (comparison == 0) {
      comparison = name.toLowerCase().compareTo(other.name.toLowerCase());
    }

    return comparison;
  }

  @override
  Hero fromJsonUpdate(Map<String, dynamic> amendment) {
    return Hero.fromJsonUpdate(this, amendment);
  }

  static Hero? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }

    return Hero.fromJsonNewId(json);
  }

  @override
  List<Field<Hero>> get fields => staticFields;

  final String id;
  final int serverId;
  final int version;
  final String name;
  final int strength;
  final Gender gender;
  final String race;
  final Alignment alignment;

  static final Field<Hero> _idField = Field<Hero>(
    (h) => h.id,
    "local_id",
    "UUID",
    mutable: false,
  );

  static final Field<Hero> _serverIdField = Field<Hero>(
    (h) => h.serverId,
    "id",
    "Server assigned integer",
  );

  static final Field<Hero> _versionField = Field<Hero>(
    (v) => v.version,
    'version',
    'Version number',
    mutable: false,
  );

  static final Field<Hero> _nameField = Field<Hero>(
    (h) => h.name,
    "name",
    "Full",
  );

  static final Field<Hero> _strengthField = Field<Hero>(
    (h) => h.strength,
    "strength",
    "Physical strength",
  );

  static final Field<Hero> _genderField = Field<Hero>(
    (h) => h.gender,
    "gender",
    Gender.values.map((e) => e.name).join(', '),
    format:(h) => h.gender.name
  );

  static final Field<Hero> _raceField = Field<Hero>(
    (h) => h.race,
    "race",
    "Species in Latin or English",
  );

  static final Field<Hero> _alignmentField = Field<Hero>(
    (h) => h.alignment,
    "alignment",
    Alignment.values.map((e) => e.name).join(', '),
    format:(h) => h.alignment.name
  );

  static final List<Field<Hero>> staticFields = [
    _idField,
    _versionField,
    _serverIdField,
    _nameField,
    _strengthField,
    _genderField,
    _raceField,
    _alignmentField,
  ];
}
