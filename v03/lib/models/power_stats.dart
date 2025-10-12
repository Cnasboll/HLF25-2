import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class PowerStats extends Updateable<PowerStats> {
  PowerStats({
    this.intelligence,
    this.strength,
    this.speed,
    this.durability,
    this.power,
    this.combat,
  });

  PowerStats.from(PowerStats other)
    : this(
        intelligence: other.intelligence,
        strength: other.strength,
        speed: other.speed,
        durability: other.durability,
        power: other.power,
        combat: other.combat,
      );

  PowerStats copyWith({
    int? intelligence,
    int? strength,
    int? speed,
    int? durability,
    int? power,
    int? combat,
  }) {
    return PowerStats(
      intelligence: intelligence ?? this.intelligence,
      strength: strength ?? this.strength,
      speed: speed ?? this.speed,
      durability: durability ?? this.durability,
      power: power ?? this.power,
      combat: combat ?? this.combat,
    );
  }

  factory PowerStats.fromJsonAmendment(
    PowerStats original,
    Map<String, dynamic>? amendment,
  ) {
    return PowerStats(
      intelligence: _combatField.getIntForAmendment(original, amendment),
      strength: _strengthField.getIntForAmendment(original, amendment),
      speed: _speedField.getIntForAmendment(original, amendment),
      durability: _durabilityField.getIntForAmendment(original, amendment),
      power: _powerField.getIntForAmendment(original, amendment),
      combat: _combatField.getIntForAmendment(original, amendment),
    );
  }

  static PowerStats? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return PowerStats(
      intelligence: _combatField.getNullableIntFromJson(json),
      strength: _strengthField.getNullableIntFromJson(json),
      speed: _speedField.getNullableIntFromJson(json),
      durability: _durabilityField.getNullableIntFromJson(json),
      power: _powerField.getNullableIntFromJson(json),
      combat: _combatField.getNullableIntFromJson(json),
    );
  }

  factory PowerStats.fromRow(Row row) {
    return PowerStats(
      intelligence: _intelligenceField.getNullableIntFromRow(row),
      strength: _strengthField.getNullableIntFromRow(row),
      speed: _speedField.getNullableIntFromRow(row),
      durability: _durabilityField.getNullableIntFromRow(row),
      power: _powerField.getNullableIntFromRow(row),
      combat: _combatField.getNullableIntFromRow(row),
    );
  }

  final int? intelligence;
  final int? strength;
  final int? speed;
  final int? durability;
  final int? power;
  final int? combat;

  static PowerStats? amendOrCreate(
    Field field,
    PowerStats? original,
    Map<String, dynamic>? amendment,
  ) {
    if (original == null) {
      return PowerStats.fromJson(field.getJsonFromJson(amendment));
    }
    return original.fromJsonAmendment(field.getJsonFromJson(amendment));
  }

  @override
  PowerStats fromJsonAmendment(Map<String, dynamic>? amendment) {
    return PowerStats.fromJsonAmendment(this, amendment);
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
    int,
    'intelligence',
    'IQ SD 15 (WAIS)',
  );

  static final Field<PowerStats> _strengthField = Field<PowerStats>(
    (p) => p.strength,
    int,
    'strength',
    'newton',
  );

  static final Field<PowerStats> _speedField = Field<PowerStats>(
    (p) => p.speed,
    int,
    'speed',
    'km/h',
  );

  static final Field<PowerStats> _durabilityField = Field<PowerStats>(
    (p) => p.durability,
    int,
    'durability',
    'longevity',
  );

  static final Field<PowerStats> _powerField = Field<PowerStats>(
    (p) => p.power,
    int,
    'power',
    'whatever',
  );

  static final Field<PowerStats> _combatField = Field<PowerStats>(
    (p) => p.combat,
    int,
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
