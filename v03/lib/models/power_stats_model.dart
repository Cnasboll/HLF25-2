import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

class PowerStatsModel extends Amendable<PowerStatsModel> {
  PowerStatsModel({
    this.intelligence,
    this.strength,
    this.speed,
    this.durability,
    this.power,
    this.combat,
  });

  PowerStatsModel.from(PowerStatsModel other)
    : this(
        intelligence: other.intelligence,
        strength: other.strength,
        speed: other.speed,
        durability: other.durability,
        power: other.power,
        combat: other.combat,
      );

  PowerStatsModel copyWith({
    int? intelligence,
    int? strength,
    int? speed,
    int? durability,
    int? power,
    int? combat,
  }) {
    return PowerStatsModel(
      intelligence: intelligence ?? this.intelligence,
      strength: strength ?? this.strength,
      speed: speed ?? this.speed,
      durability: durability ?? this.durability,
      power: power ?? this.power,
      combat: combat ?? this.combat,
    );
  }

@override
  int compareTo(PowerStatsModel other) {
  
    // Sort by strength, descending first followed by intelligence, speed, durability, power, combat by reversing the comparison
    // to get descending order.
    for (var field in [_strengthField, _intelligenceField, _speedField, _durabilityField, _powerField, _combatField]) {
      int comparison = field.compareField(other, this);
      if (comparison != 0) {
        return comparison;
      }
    }
    
    return 0;
  }
  factory PowerStatsModel.amendWith(
    PowerStatsModel original,
    Map<String, dynamic>? amendment,
  ) {
    return PowerStatsModel(
      intelligence: _intelligenceField.getIntForAmendment(original, amendment),
      strength: _strengthField.getIntForAmendment(original, amendment),
      speed: _speedField.getIntForAmendment(original, amendment),
      durability: _durabilityField.getIntForAmendment(original, amendment),
      power: _powerField.getIntForAmendment(original, amendment),
      combat: _combatField.getIntForAmendment(original, amendment),
    );
  }

  static PowerStatsModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PowerStatsModel();
    }
    return PowerStatsModel(
      intelligence: _intelligenceField.getNullableIntFromJson(json),
      strength: _strengthField.getNullableIntFromJson(json),
      speed: _speedField.getNullableIntFromJson(json),
      durability: _durabilityField.getNullableIntFromJson(json),
      power: _powerField.getNullableIntFromJson(json),
      combat: _combatField.getNullableIntFromJson(json),
    );
  }

  factory PowerStatsModel.fromRow(Row row) {
    return PowerStatsModel(
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

  @override
  PowerStatsModel amendWith(Map<String, dynamic>? amendment) {
    return PowerStatsModel.amendWith(this, amendment);
  }

  static PowerStatsModel? fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return PowerStatsModel.fromJson(json);
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<query<PowerStatsModel>> get fields => staticFields;

  static query<PowerStatsModel> get _intelligenceField => query<PowerStatsModel>(
    (p) => p?.intelligence,
    int,
    'intelligence',
    'IQ SD 15 (WAIS)',
  );

  static final query<PowerStatsModel> _strengthField = query<PowerStatsModel>(
    (p) => p?.strength,
    int,
    'strength',
    'newton',
  );

  static final query<PowerStatsModel> _speedField = query<PowerStatsModel>(
    (p) => p?.speed,
    int,
    'speed',
    'km/h',
  );

  static final query<PowerStatsModel> _durabilityField = query<PowerStatsModel>(
    (p) => p?.durability,
    int,
    'durability',
    'longevity',
  );

  static final query<PowerStatsModel> _powerField = query<PowerStatsModel>(
    (p) => p?.power,
    int,
    'power',
    'whatever',
  );

  static final query<PowerStatsModel> _combatField = query<PowerStatsModel>(
    (p) => p?.combat,
    int,
    'combat',
    'fighting skills',
  );

  static final List<query<PowerStatsModel>> staticFields = [
    _intelligenceField,
    _strengthField,
    _speedField,
    _durabilityField,
    _powerField,
    _combatField,
  ];
}
