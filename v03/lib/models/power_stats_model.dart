import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';
import 'package:v03/amendable/field_base.dart';

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
      intelligence: _intelligenceField.getNullableInt(json),
      strength: _strengthField.getNullableInt(json),
      speed: _speedField.getNullableInt(json),
      durability: _durabilityField.getNullableInt(json),
      power: _powerField.getNullableInt(json),
      combat: _combatField.getNullableInt(json),
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
  List<FieldBase<PowerStatsModel>> get fields => staticFields;

  static FieldBase<PowerStatsModel> get _intelligenceField => Field.infer(
    (m) => m.intelligence,
    "Intelligence",
    'IQ SD 15 (WAIS)',
  );

  static FieldBase<PowerStatsModel> get _strengthField => Field.infer(
    (m) => m.strength,
    'Strength',
    'newton',
  );

  static FieldBase<PowerStatsModel> get _speedField => Field.infer(
    (m) => m.speed,
    'Speed',
    'km/h',
  );

  static FieldBase<PowerStatsModel> get _durabilityField => Field.infer(
    (m) => m.durability,
    'Durability',
    'longevity',
  );

  static FieldBase<PowerStatsModel> get _powerField => Field.infer(
    (m) => m.power,
    'Power',
    'whatever',
  );

  static FieldBase<PowerStatsModel> get _combatField => Field.infer(
    (m) => m.combat,
    'Combat',
    'fighting skills',
  );

  static final List<FieldBase<PowerStatsModel>> staticFields = [
    _intelligenceField,
    _strengthField,
    _speedField,
    _durabilityField,
    _powerField,
    _combatField,
  ];
}
