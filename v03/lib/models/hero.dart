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
    required this.version,
    required this.name,
    required this.strength,
    required this.gender,
    required this.race,
    required this.alignment,
  });

  Hero.newId(
    String name,
    int strength,
    Gender gender,
    String race,
    Alignment alignment,
  ) : this(
        id: Uuid().v4(),
        version: 1,
        name: name,
        strength: strength,
        gender: gender,
        race: race,
        alignment: alignment,
      );

  Hero.copy(Hero other)
    : this(
        id: other.id,
        version: other.version,
        name: other.name,
        strength: other.strength,
        gender: other.gender,
        race: other.race,
        alignment: other.alignment,
      );

  Hero copyWith({
    String? id,
    int? version,
    String? name,
    int? strength,
    Gender? gender,
    String? race,
    Alignment? alignment,
  }) {
    return Hero(
      id: id ?? this.id,
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
  Hero fromUpdate(Map<String, String> update) {
    return Hero(
      id: id,
      version: version + 1,
      name: _nameField.getStringForUpdate(this, update),
      strength: _strengthField.getIntForUpdate(this, update),
      gender: _genderField.getEnumForUpdate<Gender>(this, Gender.values, update),
      race: _raceField.getStringForUpdate(this, update),
      alignment: _alignmentField.getEnumForUpdate<Alignment>(this, Alignment.values, update),
    );
  }

  static Hero? fromPrompt() {
    var values = Updateable.promptForValues(staticFields);
    if (values == null) {
      return null;
    }
  
    return Hero.newId(
      _nameField.getString(values),
      _strengthField.getInt(values),
      _genderField.getEnum<Gender>(Gender.values, values, Gender.unknown),
      _raceField.getString(values),
      _alignmentField.getEnum<Alignment>(Alignment.values, values, Alignment.unknown),
    );
  }

  @override
  List<Field<Hero>> get fields => staticFields;

  final String id;
  final int version;
  final String name;
  final int strength;
  final Gender gender;
  final String race;
  final Alignment alignment;

  static final Field<Hero> _idField = Field<Hero>(
    (h) => h.id,
    "id",
    "UUID",
    mutable: false,
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
    _nameField,
    _strengthField,
    _genderField,
    _raceField,
    _alignmentField,
  ];
}
