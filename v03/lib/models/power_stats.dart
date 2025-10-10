import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class PowerStats extends Updateable<PowerStats> {
  PowerStats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory PowerStats.fromJsonUpdate(
    PowerStats original,
    Map<String, dynamic> amendment,
  ) {
    return PowerStats(
      intelligence: _combatField.getIntForUpdate(original, amendment),
      strength: _strengthField.getIntForUpdate(original, amendment),
      speed: _speedField.getIntForUpdate(original, amendment),
      durability: _durabilityField.getIntForUpdate(original, amendment),
      power: _powerField.getIntForUpdate(original, amendment),
      combat: _combatField.getIntForUpdate(original, amendment),
    );
  }

  factory PowerStats.fromJson(Map<String, dynamic> json) {
    return PowerStats(
      intelligence: _combatField.getInt(json),
      strength: _strengthField.getInt(json),
      speed: _speedField.getInt(json),
      durability: _durabilityField.getInt(json),
      power: _powerField.getInt(json),
      combat: _combatField.getInt(json),
    );
  }

  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  @override
  PowerStats fromJsonUpdate(Map<String, dynamic> amendment) {
    return PowerStats.fromJsonUpdate(this, amendment);
  }

  static PowerStats? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return PowerStats.fromJson(json);
  }


  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<PowerStats>> get fields => staticFields;

  static Field<PowerStats> get _intelligenceField => Field<PowerStats>(
    (p) => p.intelligence,
    'intelligence',
    'IQ SD 15 (WAIS)',
  );

  static final Field<PowerStats> _strengthField = Field<PowerStats>(
    (p) => p.strength,
    'strength',
    'newton',
  );

  static final Field<PowerStats> _speedField = Field<PowerStats>(
    (p) => p.speed,
    'speed',
    'km/h',
  );

  static final Field<PowerStats> _durabilityField = Field<PowerStats>(
    (p) => p.durability,
    'durability',
    'longevity',
  );

  static final Field<PowerStats> _powerField = Field<PowerStats>(
    (p) => p.power,
    'power',
    'whatever',
  );

  static final Field<PowerStats> _combatField = Field<PowerStats>(
    (p) => p.combat,
    'combat',
    'fighting skills',
  );

  static final List<Field<PowerStats>> staticFields = [
    _intelligenceField,
    _strengthField,
    _speedField,
    _durabilityField,
    _powerField,
    _combatField,
  ];
  
}
