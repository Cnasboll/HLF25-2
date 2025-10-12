import 'package:v03/value_types/value_type.dart';

enum HeightUnit { feet, inches, centimeters }

class Height extends ValueType<Height> {
  final int? feet;
  final int? inches;
  final int? centimeters;

  const Height({this.feet, this.inches, this.centimeters});

  Height.fromMap(Map<HeightUnit, int> partsPerUnit)
    : feet = partsPerUnit[HeightUnit.feet],
      inches = partsPerUnit[HeightUnit.inches],
      centimeters = partsPerUnit[HeightUnit.centimeters];

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
        return (Height(feet: feet, inches: inches), null);
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
        return (Height(feet: feet, inches: inches), null);
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
          final centimeters = (value * 100).round();
          return (Height(centimeters: centimeters), null);
        }
        return (Height(centimeters: value), null);
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
        return (Height(centimeters: centimeters), null);
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
  List<Object?> get props => [feet, inches, centimeters];

  @override
  bool get isImperial => feet != null || inches != null;
  @override
  bool get isMetric => centimeters != null;

  @override
  String toString() {
    if (isImperial) {
      return "${feet ?? 0}'${inches ?? 0}\"";
    }
    if (isMetric) {
      return "$centimeters cm";
    }
    return '<unknown>';
  }

  @override
  Height cloneMetric() {
    final f = feet ?? 0;
    final i = inches ?? 0;
    final totalInches = f * 12 + i;
    final cmVal = (totalInches * 2.54).round();
    return Height(centimeters: cmVal);
  }

  @override
  Height cloneImperial() {
    final c = centimeters ?? 0;
    final totalInches = (c / 2.54).round();
    final f = totalInches ~/ 12;
    final i = totalInches % 12;
    return Height(feet: f, inches: i);
  }
  
  @override
  double toMetricExact() {
    return asMetric().centimeters?.toDouble() ?? 0 * 100;
  }
}
