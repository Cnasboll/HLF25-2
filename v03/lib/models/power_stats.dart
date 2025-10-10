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

  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

 @override
  PowerStats fromUpdate(Map<String, String> update) {
    return PowerStats(
      intelligence: _combatField.getIntForUpdate(this, update),
      strength: _strengthField.getIntForUpdate(this, update),
      speed: _speedField.getIntForUpdate(this, update),
      durability: _durabilityField.getIntForUpdate(this, update),
      power: _powerField.getIntForUpdate(this, update),
      combat: _combatField.getIntForUpdate(this, update),
    );
  }

  static PowerStats? fromPrompt() {
    var values = Updateable.promptForValues(staticFields);
    if (values == null) {
      return null;
    }
    if (values.length != staticFields.length) {
      return null;
    }

    return PowerStats(
      intelligence: _combatField.getInt(values),
      strength: _strengthField.getInt(values),
      speed: _speedField.getInt(values),
      durability: _durabilityField.getInt(values),
      power: _powerField.getInt(values),
      combat: _combatField.getInt(values),
    );
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
