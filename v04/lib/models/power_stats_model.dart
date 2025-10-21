import 'package:sqlite3/sqlite3.dart';
import 'package:v04/amendable/field.dart';
import 'package:v04/amendable/amendable.dart';
import 'package:v04/amendable/field_base.dart';
import 'package:v04/amendable/parsing_context.dart';
import 'package:v04/value_types/percentage.dart';

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
    Percentage? intelligence,
    Percentage? strength,
    Percentage? speed,
    Percentage? durability,
    Percentage? power,
    Percentage? combat,
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
    for (var field in [
      _strengthField,
      _intelligenceField,
      _speedField,
      _durabilityField,
      _powerField,
      _combatField,
    ]) {
      int comparison = field.compareField(other, this);
      if (comparison != 0) {
        return comparison;
      }
    }

    return 0;
  }

  @override
  PowerStatsModel amendWith(Map<String, dynamic>? amendment, {ParsingContext? parsingContext}) {
    return PowerStatsModel(
      intelligence: _intelligenceField.getPercentageForAmendment(
        this,
        amendment,
      ),
      strength: _strengthField.getPercentageForAmendment(this, amendment),
      speed: _speedField.getPercentageForAmendment(this, amendment),
      durability: _durabilityField.getPercentageForAmendment(this, amendment),
      power: _powerField.getPercentageForAmendment(this, amendment),
      combat: _combatField.getPercentageForAmendment(this, amendment),
    );
  }

  static PowerStatsModel fromJson(Map<String, dynamic>? json, {ParsingContext? parsingContext}) {
    if (json == null) {
      return PowerStatsModel();
    }
    return PowerStatsModel(
      intelligence: _intelligenceField.getNullablePercentage(json),
      strength: _strengthField.getNullablePercentage(json),
      speed: _speedField.getNullablePercentage(json),
      durability: _durabilityField.getNullablePercentage(json),
      power: _powerField.getNullablePercentage(json),
      combat: _combatField.getNullablePercentage(json),
    );
  }

  factory PowerStatsModel.fromRow(Row row) {
    return PowerStatsModel(
      intelligence: _intelligenceField.getNullablePercentageFromRow(row),
      strength: _strengthField.getNullablePercentageFromRow(row),
      speed: _speedField.getNullablePercentageFromRow(row),
      durability: _durabilityField.getNullablePercentageFromRow(row),
      power: _powerField.getNullablePercentageFromRow(row),
      combat: _combatField.getNullablePercentageFromRow(row),
    );
  }

  final Percentage? intelligence;
  final Percentage? strength;
  final Percentage? speed;
  final Percentage? durability;
  final Percentage? power;
  final Percentage? combat;

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

  static FieldBase<PowerStatsModel> get _intelligenceField =>
      Field.infer((m) => m.intelligence?.value, "Intelligence", '%');

  static FieldBase<PowerStatsModel> get _strengthField =>
      Field.infer((m) => m.strength?.value, 'Strength', '%');

  static FieldBase<PowerStatsModel> get _speedField =>
      Field.infer((m) => m.speed?.value, 'Speed', '%');

  static FieldBase<PowerStatsModel> get _durabilityField =>
      Field.infer((m) => m.durability?.value, 'Durability', '%');

  static FieldBase<PowerStatsModel> get _powerField =>
      Field.infer((m) => m.power?.value, 'Power', '%');

  static FieldBase<PowerStatsModel> get _combatField =>
      Field.infer((m) => m.combat?.value, 'Combat', '%');

  static final List<FieldBase<PowerStatsModel>> staticFields = [
    _intelligenceField,
    _strengthField,
    _speedField,
    _durabilityField,
    _powerField,
    _combatField,
  ];
}
