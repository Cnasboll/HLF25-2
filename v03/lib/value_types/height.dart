import 'package:equatable/equatable.dart';
import 'package:v03/value_types/imperial_metric.dart';

enum HeightUnit { feet, inches, centimeters }

class Height extends Equatable {
  final int? feet;
  final int? inches;
  final int? cm;

  const Height({this.feet, this.inches, this.cm});

  @override
  List<Object?> get props => [feet, inches, cm];

  Height.fromMap(Map<HeightUnit, int> partsPerUnit)
    : feet = partsPerUnit[HeightUnit.feet],
      inches = partsPerUnit[HeightUnit.inches],
      cm = partsPerUnit[HeightUnit.centimeters];

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
  factory Height.parse(String input) {
    final s = input.trim();
    if (s.isEmpty) {
      throw FormatException('Empty height string');
    }

    // Try imperial shorthand: 6'2" or 6'2 or 6' 2"
    final imperialRegex = RegExp(
      r'''^\s*(\d+)\s*'\s*(\d+)?\s*(?:"|in)?\s*$''',
      caseSensitive: false,
    );
    final m1 = imperialRegex.firstMatch(s);
    if (m1 != null) {
      final f = int.tryParse(m1.group(1) ?? '');
      final i = int.tryParse(m1.group(2) ?? '') ?? 0;
      if (f != null) {
        return Height(feet: f, inches: i);
      }
    }

    // Try verbose imperial: 6 ft 2 in, 6 feet 2 inches
    final imperialVerbose = RegExp(
      r'''^\s*(\d+)\s*(?:ft|feet)\s*(\d+)?\s*(?:in|inch|inches)?\s*$''',
      caseSensitive: false,
    );
    final m2 = imperialVerbose.firstMatch(s);
    if (m2 != null) {
      final f = int.tryParse(m2.group(1) ?? '');
      final i = int.tryParse(m2.group(2) ?? '') ?? 0;
      if (f != null) return Height(feet: f, inches: i);
    }

    // Try metric cm: 188 cm or 188
    final cmRegex = RegExp(
      r'''^\s*(\d{2,3})\s*(cm)?\s*$''',
      caseSensitive: false,
    );
    final m3 = cmRegex.firstMatch(s);
    if (m3 != null) {
      final c = int.tryParse(m3.group(1) ?? '');
      if (c != null) return Height(cm: c);
    }

    // Try metric meters: 1.88 m
    final mRegex = RegExp(
      r'''^\s*(\d+(?:\.\d+)?)\s*m?\s*$''',
      caseSensitive: false,
    );
    final m4 = mRegex.firstMatch(s);
    if (m4 != null) {
      final meters = double.tryParse(m4.group(1) ?? '');
      if (meters != null) {
        final cmVal = (meters * 100).round();
        return Height(cm: cmVal);
      }
    }

    // If nothing matched, try to parse a simple number as cm
    final onlyNumber = RegExp(r'''^\s*(\d{2,3})\s*$''');
    final m5 = onlyNumber.firstMatch(s);
    if (m5 != null) {
      final c = int.tryParse(m5.group(1) ?? '');
      if (c != null) return Height(cm: c);
    }

    throw FormatException('Could not parse height: $input');
  }

  factory Height.parseList(List<String> heightInVariousUnits) {
    Map<SystemOfUnits, Height> parsedHeights = {};
    for (var h in heightInVariousUnits.map((e) => Height.parse(e))) {
      parsedHeights[h.systemOfUnits] = h;
    }

    // Find metric if available, otherwise imperial
    var metric = parsedHeights[SystemOfUnits.metric];
    if (metric != null) {
      // Check for conflicts with any imperial values
      var imperial = metric.asImperial();
      for (var e in parsedHeights.entries) {
        if (e.key == SystemOfUnits.metric) {
          continue;
        }
        if (e.key == SystemOfUnits.imperial) {
          var i = e.value;
          if (i != imperial) {
            // Conflict between metric and imperial, this is an error!
            throw FormatException(
              'Conflicting height information: ${metric.toString()} vs ${i.toString()} -- expecting ${imperial.toString()} in order to match metric value',
            );
          }
        }
        return metric;
      }
    }
    for (var e in parsedHeights.entries) {
      return e.value.asMetric();
    }
    return throw FormatException('No valid height information found');
  }

  SystemOfUnits get systemOfUnits {
    if (isMetric) {
      return SystemOfUnits.metric;
    }

    if (isImperial) {
      return SystemOfUnits.imperial;
    }
    return SystemOfUnits.metric; // default to metric if unknown
  }

  bool get isImperial => feet != null || inches != null;
  bool get isMetric => cm != null;

  @override
  String toString() {
    if (isImperial) {
      return "${feet ?? 0}'${inches ?? 0}\"";
    }
    if (isMetric) {
      return "$cm cm";
    }
    return '<unknown>';
  }

  Height asMetric() {
    if (isMetric) {
      return this;
    }
    final f = feet ?? 0;
    final i = inches ?? 0;
    final totalInches = f * 12 + i;
    final cmVal = (totalInches * 2.54).round();
    return Height(cm: cmVal);
  }

  Height asImperial() {
    if (isImperial) {
      return this;
    }
    final c = cm ?? 0;
    final totalInches = (c / 2.54).round();
    final f = totalInches ~/ 12;
    final i = totalInches % 12;
    return Height(feet: f, inches: i);
  }
}
