import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Hero extends Equatable implements Comparable<Hero> {
  final String id;
  final String name;
  final int strength;
  final String gender;
  final String race;
  final String alignment;

  Hero({
    required this.id,
    required this.name,
    required this.strength,
    required this.gender,
    required this.race,
    required this.alignment,
  });

  Hero.newId(
      String name, int strength, String gender, String race, String alignment)
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
    String? gender,
    String? race,
    String? alignment,
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

  @override
  int compareTo(Hero other) {
    var comparison = other.strength.compareTo(strength);

    if (comparison == 0) {
      comparison = name.compareTo(other.name);
    }    
  
    if (comparison == 0) {
      comparison = gender.compareTo(other.gender);
    }

    if (comparison == 0) {
      comparison = race.compareTo(other.race);
    }

    if (comparison == 0) {
      comparison = alignment.compareTo(other.alignment);
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

  String analyzeDifferences(Hero other) {
    StringBuffer sb = StringBuffer();

    for (int i = 0; i < fields.length; i++) {
      if (props[i] != other.props[i]) {
        sb.writeln("${fields[i]}: ${props[i]} => ${other.props[i]}");
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
    return '''

=============
id: $id
name: $name
strength: $strength
gender: $gender
race: $race
alignment: $alignment
=============
''';
  }
}
