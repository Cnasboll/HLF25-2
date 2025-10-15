import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/field_base.dart';
import 'package:v03/value_types/value_type.dart';

class Height extends ValueType<Height> {

  Height(super.value, super.systemOfUnits);

  Height.fromFeetAndInches(int feet, double inches) : this(feetAndInchesToMeters(feet, inches), SystemOfUnits.imperial);
  Height.fromCentimeters(int centimeters) : this(centimeters.toDouble() / 100.0, SystemOfUnits.metric);
  Height.fromMeters(int meters) : this(meters.toDouble(), SystemOfUnits.metric);

  static Height? fromRow(FieldBase fieldBase, Row row)
  {
    var (metres, systemOfUnits) = ValueType.fromRow(_valueField, _systemOfUnitsField, row);
    if (metres == null)
    {
      return null;
    }
    return Height(metres, systemOfUnits);
  }

  static Height parse(String input) {
    var (value, error) = tryParse(input);
    if (error != null) {
      throw FormatException(error);
    }
    if (value == null) {
      throw FormatException('Could not parse height: $input');
    }
    return value;
  }

  /// Parse a height string
  ///
  /// Recognises common imperial forms like:
  /// - 6'2"  (with single-quote feet and double-quote inches)
  /// - 6'  or 6 ft
  /// - 6 ft 2 in
  /// and metric forms like:
  /// - 188 cm
  /// - 188cm
  /// - 188  (assumed to be cm if no unit given)
  /// - 1.88 m
  /// - 1.88
  ///
  static (Height?, String?) tryParse(String? input) {
    if (input == null) {
      // Null is not an error, it just means no information provided
      return (null, null);
    }
    final String s = input.trim();
    if (s.isEmpty) {
      return (null, 'Empty height string');
    }

    // Try imperial shorthand: 6'2" or 6'2 or 6' 2"
    final imperialRegex = RegExp(r'''^\s*(\d+)\s*'\s*(\d+)?\s*(?:"|in)?\s*$''');
    var match = imperialRegex.firstMatch(s);
    if (match != null) {
      final feet = int.tryParse(match.group(1) ?? '');
      final inches = int.tryParse(match.group(2) ?? '') ?? 0;
      if (feet != null) {
        return (Height.fromFeetAndInches(feet, inches.toDouble()), null);
      }
    }

    // Try verbose imperial: 6 ft 2 in, 6 feet 2 inches
    final imperialVerbose = RegExp(
      r'''^\s*(\d+)\s*(?:ft|feet)\s*(\d+)?\s*(?:in|inch|inches)?\s*$''',
      caseSensitive: false,
    );
    match = imperialVerbose.firstMatch(s);
    if (match != null) {
      final feet = int.tryParse(match.group(1) ?? '');
      final inches = int.tryParse(match.group(2) ?? '') ?? 0;
      if (feet != null) {
        return (Height.fromFeetAndInches(feet, inches.toDouble()), null);
      }
    }

    // Try integral metric: 188 cm, 2m or 188 e.g. with or without unit or spaces (assumed cm for values > 2 if no unit)
    final integralMetricRegex = RegExp(
      r'''^\s*(\d+)\s*(cm|m)?\s*$''',
      caseSensitive: false,
    );
    
    match = integralMetricRegex.firstMatch(s);
    if (match != null) {
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null) {
        var unit = match.group(2);
        if (unit == null) {
          // No unit given, assume m if value less than 3, otherwise cm
          if (value > 2) {
            unit = 'cm';
          } else {
            unit = 'm';
          }
        }

        if (unit == 'm') {
          return (Height.fromMeters(value), null);
        }
        return (Height.fromCentimeters(value), null);
      }
    }

    // Try metric meters: 1.88 m with our without unit or spaces
    final mRegex = RegExp(
      r'''^\s*(\d+(?:\.\d+)?)\s*m?\s*$''',
      caseSensitive: false,
    );
    match = mRegex.firstMatch(s);
    if (match != null) {
      final meters = double.tryParse(match.group(1) ?? '');
      if (meters != null) {
        final centimeters = (meters * 100).round();
        return (Height.fromCentimeters(centimeters), null);
      }
    }

    return (null, 'Could not parse height: $input');
  }

  static Height? parseList(List<String>? valueInVariousUnits) {
    var (value, error) = tryParseList(valueInVariousUnits);
    if (error != null) {
      throw FormatException(error);
    }
    return value;
  }

  static (Height?, String?) tryParseList(List<String>? valueVariousUnits) {
    return ValueType.tryParseList(valueVariousUnits, "height", tryParse);
  }

  @override
  String toString() {
    if (isImperial) {
      final (feet, inches) = metersToFeetAndInches(value);
      return "$feet'${inches.round()}\"";
    }
    if (isMetric) {
      return "${(value*100).round()} cm";
    }
    return '<unknown>';
  }

  static const double metersPerInch = 0.0254;
  static const double inchesPerFeet = 12.0;
  

  static double feetAndInchesToMeters(int feet, double inches) {
    double totalInches = (feet * inchesPerFeet) + inches;
    return totalInches * metersPerInch;
  }

  int get wholeCentimeters => (value * 100.0).round();

  (int, int) get wholeFeetAndWholeInches {
    var (feet, inches) = metersToFeetAndInches(value);
    return (feet, inches.round());
  }

  static (int, double) metersToFeetAndInches(double meters) {
    final double totalInches = meters / metersPerInch;
    final double totalFeet = totalInches / inchesPerFeet;
    final double inches = totalInches % inchesPerFeet;
    return (totalFeet.floor(), inches);
  }
  
  @override
  Height cloneMetric() {
    // Convert meters to a round number of centimeters (this destroys precision if value is imperial)
    return Height.fromCentimeters(wholeCentimeters);
  }

  @override
  Height cloneImperial() {
    // Converts feet and inches to a round number of inches (this destroys precision if value is metric)
    var (feet, inches) = wholeFeetAndWholeInches;
    return Height.fromFeetAndInches(feet, inches.toDouble());
  }
  
  @override
  List<FieldBase<ValueType<Height>>> get fields => staticFields;

  static final FieldBase<ValueType<Height>> _valueField = Field.infer(
    (h) => h.value,
    "Height (m)",
    jsonName: "height-metres",
    sqliteName: "height_m",
    'The character\'s height in metres',
  );

  static final FieldBase<ValueType<Height>> _systemOfUnitsField =
      Field.infer(
        (h) => h.systemOfUnits,
        "Height System of Units",
        jsonName: "height-system-of-units",
        sqliteName: "height_system_of_units",
        'The source system of units for height value (${SystemOfUnits.values.map((e) => e.name).join(" or ")})',
        sqliteGetter: (h) => h.systemOfUnits.toString().split('.').last,
      );

  static final List<FieldBase<ValueType<Height>>> staticFields = [
    _valueField,
    _systemOfUnitsField,
  ];
}
