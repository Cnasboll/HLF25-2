import 'package:v03/value_types/value_type.dart';

enum HeightUnit { feet, inches, centimeters }

class Height extends ValueType<Height> {

  Height(super.value, super.systemOfUnits);

  Height.fromFeetAndInches(int feet, double inches) : this(feetAndInchesToMeters(feet, inches), SystemOfUnits.imperial);
  Height.fromCentimeters(double centimeters) : this(centimeters / 100.0, SystemOfUnits.metric);
  Height.fromMeters(double meters) : this(meters, SystemOfUnits.metric);

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
          return (Height.fromMeters(value.toDouble()), null);
        }
        return (Height.fromCentimeters(value.toDouble()), null);
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
        return (Height.fromCentimeters(centimeters.toDouble()), null);
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
    return Height.fromCentimeters(wholeCentimeters.toDouble());
  }

  @override
  Height cloneImperial() {
    // Converts feet and inches to a round number of inches (this destroys precision if value is metric)
    var (feet, inches) = wholeFeetAndWholeInches;
    return Height.fromFeetAndInches(feet, inches.toDouble());
  }
}
