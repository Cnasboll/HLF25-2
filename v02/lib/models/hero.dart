import 'package:uuid/uuid.dart';

class Hero implements Comparable<Hero> {
  final String id;
  String name;
  int strength;
  String gender;
  String race;
  String alignment;

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
  int compareTo(Hero other) {
    var comparison = other.strength.compareTo(this.strength);

    if (comparison == 0) {
      comparison = this.name.compareTo(other.name);
    }    
  
    if (comparison == 0) {
      comparison = this.gender.compareTo(other.gender);
    }

    if (comparison == 0) {
      comparison = this.race.compareTo(other.race);
    }

    if (comparison == 0) {
      comparison = this.alignment.compareTo(other.alignment);
    }

    return comparison;
  }

  @override
  String toString() {
    return '''

=============
Hero id: $id
name: $name
strength: $strength
gender: $gender
race: $race
alignment: $alignment
=============
''';
  }
}
