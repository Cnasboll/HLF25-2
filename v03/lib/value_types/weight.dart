import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/field_base.dart';
import 'package:v03/value_types/value_type.dart';

enum WeightUnit { pounds, kilograms }

class Weight extends ValueType<Weight> {

  Weight(super.value, super.systemOfUnits);
  Weight.fromPounds(int pounds) : this(poundsToKilograms(pounds.toDouble()), SystemOfUnits.imperial);
  Weight.fromKilograms(int kilograms) : this(kilograms.toDouble(), SystemOfUnits.metric);

static Weight? fromRow(FieldBase fieldBase, Row row) {
    var (kilograms, systemOfUnits) = ValueType.fromRow(_valueField, _systemOfUnitsField, row);
    if (kilograms == null) {
      return null;
    }
    return Weight(kilograms, systemOfUnits);
  }

  static Weight parse(String input) {
    var (value, error) = tryParse(input);
    if (error != null) {
      throw FormatException(error);
    }
    if (value == null) {
      throw FormatException('Could not parse weight: $input');
    }
    return value;
  }

  /// Parse a weight string such as "210 lb", "95 kg", or just "95"
  static (Weight?, String?) tryParse(String? input) {
    if (input == null) {
      // Null is not an error, it just means no information provided
      return (null, null);
    }

    final s = input.trim();
    if (s.isEmpty) {
      return (null, 'Empty weight string');
    }

    final weightRegex = RegExp(
      r'''^\s*(\d+)\s*(lb|kg)?\s*$''',
      caseSensitive: false,
    );

    final match = weightRegex.firstMatch(s);
    if (match != null) {
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null) {
        if (match.group(2) == 'lb') {
          return (Weight.fromPounds(value), null);
        }
        return (Weight.fromKilograms(value), null);
      }
    }

    return (null, 'Could not parse weight: $input');
  }

  static Weight? parseList(List<String>? valueInVariousUnits) {
    var (value, error) = tryParseList(valueInVariousUnits);
    if (error != null) {
      throw FormatException(error);
    }
    return value;
  }

  static (Weight?, String?) tryParseList(List<String>? valueVariousUnits) {
    return ValueType.tryParseList(valueVariousUnits, "weight", tryParse);
  }


  @override
  String toString() {
    if (isImperial) {
      return "$wholePounds lb";
    }
    if (isMetric) {
      return "$wholeKilograms kg";
    }
    return '<unknown>';
  }

  static final double kilosgramsPerPound = 0.45359237;

  static double poundsToKilograms(double pounds) {
    return pounds * kilosgramsPerPound;
  }
  static double kilogramsToPounds(double kilograms) {
    return kilograms / kilosgramsPerPound;
  }

  int get wholePounds => (kilogramsToPounds(value)).round();
  int get wholeKilograms => value.round();

  @override
  Weight cloneMetric() {
    return Weight.fromKilograms(wholeKilograms);
  }

  @override
  Weight cloneImperial() {
    return Weight.fromPounds(wholePounds);
  }

  @override
  List<FieldBase<ValueType<Weight>>> get fields => staticFields;

  static final FieldBase<ValueType<Weight>> _valueField = Field.infer(
    (h) => h.value,
    "Weight (kg)",
    jsonName: "weight-kilograms",
    sqliteName: "weight_kg",
    'The character\'s weight of in kilograms',
  );

  static final FieldBase<ValueType<Weight>> _systemOfUnitsField =
      Field.infer(
        (h) => h.systemOfUnits,
        "Weight System of Units",
        jsonName: "weight-system-of-units",
        sqliteName: "weight_system_of_units",
        'The source system of units for the weight value (${SystemOfUnits.values.map((e) => e.name).join(" or ")})',
        sqliteGetter: (h) => h.systemOfUnits.toString().split('.').last,
      );

  static final List<FieldBase<ValueType<Weight>>> staticFields = [
    _valueField,
    _systemOfUnitsField,
  ];
}
