import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

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

enum Gender
{
  unknown,
  ambiguous,
  male,
  female,
  nonBinary,
  wontSay
}

class Hero extends Equatable implements Comparable<Hero> {
  final String id;
  final String name;
  final int strength;
  final Gender gender;
  final String race;
  final Alignment alignment;

  Hero({
    required this.id,
    required this.name,
    required this.strength,
    required this.gender,
    required this.race,
    required this.alignment,
  });

  Hero.newId(
      String name, int strength, Gender gender, String race, Alignment alignment)
      : this(
            id: Uuid().v4(),
            name: name,
            strength: strength,
            gender: gender,
            race: race,
            alignment: alignment);
    
  Hero.copy(Hero other)
      : id = other.id,
        name = other.name,
        strength = other.strength,
        gender = other.gender,
        race = other.race,
        alignment = other.alignment;

  Hero copyWith({
    String? id,
    String? name,
    int? strength,
    Gender? gender,
    String? race,
    Alignment? alignment,
  }) {
    return Hero(
      id: id ?? this.id,
      name: name ?? this.name,
      strength: strength ?? this.strength,
      gender: gender ?? this.gender,
      race: race ?? this.race,
      alignment: alignment ?? this.alignment,
    );
  }
  
  @override
  List<Object?> get props => [id, name, strength, gender, race, alignment];

  List<String> get stringProps => [id.toString(), name, strength.toString(), gender.name, race, alignment.name];

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
      comparison = genderComparisonFactor.compareTo(other.genderComparisonFactor);
    }

    // Don't compare race but sort by name alphabetically ascending, case insensitive.
    if (comparison == 0) {
      comparison = name.toLowerCase().compareTo(other.name.toLowerCase());
    }

    return comparison;
  }

  static List<String> get fields => [
        "id",
        "name",
        "strength",
        "gender",
        "race",
        "alignment"];

  static List<String> get hints => [
    "UUID",
    "Full",
    "integer",
    Gender.values.map((e) => e.name).join(', '),
    "species in Latin or English",
    Alignment.values.map((e) => e.name).join(', '),
  ];

  String analyzeDifferences(Hero other) {
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < fields.length; i++) {
      if (props[i] != other.props[i]) {
        sb.writeln("${fields[i]}: ${stringProps[i]} => ${other.stringProps[i]}");
      }
    }
    return sb.toString();
  }

  String sideBySide(Hero other) {
    var diff = analyzeDifferences(other);
    if (diff.isNotEmpty) {
      return '''

=============
$diff=============
  ''';
    }
    return '<No differences>';
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.writeln('''

=============''');
    for (int i = 0; i < fields.length; ++i)
    {
      sb.writeln("${fields[i]}: ${stringProps[i]}");
    }
    sb.write('''=============
''');
    return sb.toString();
  }
}
