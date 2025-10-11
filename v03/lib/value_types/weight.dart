import 'package:equatable/equatable.dart';
import 'package:v03/value_types/imperial_metric.dart';

enum WeightUnit { pounds, kilograms }

class Weight extends Equatable {
  final int? pounds;
  final int? kg;

  const Weight({this.pounds, this.kg});

  @override
  List<Object?> get props => [pounds, kg];

  Weight.fromMap(Map<WeightUnit, int> partsPerUnit)
    : pounds = partsPerUnit[WeightUnit.pounds],
      kg = partsPerUnit[WeightUnit.kilograms];

  /// Parse a weight string such as "210 lb", "95 kg", or just "95"
  factory Weight.parse(String input) {
    final s = input.trim();
    if (s.isEmpty) {
      throw FormatException('Empty weight string');
    }

    final weightRegex = RegExp(
      r'''^\s*(\d+)\s*(lb|kg)?\s*$''',
      caseSensitive: false,
    );

    final m1 = weightRegex.firstMatch(s);
    if (m1 != null) {
      final value = int.tryParse(m1.group(1) ?? '');
      if (value != null) {
        if (m1.group(2) == 'kg') {
          return Weight(kg: value);
        } else {
          return Weight(pounds: value);
        }
      }
    }

    throw FormatException('Could not parse weight: $input');
  }

  factory Weight.parseList(List<String> weightInVariousUnits) {
    Map<SystemOfUnits, Weight> parsedWeights = {};
    for (var h in weightInVariousUnits.map((e) => Weight.parse(e))) {
      parsedWeights[h.systemOfUnits] = h;
    }

    // Find metric if available, otherwise imperial
    var metric = parsedWeights[SystemOfUnits.metric];
    if (metric != null) {
      // Check for conflicts with any imperial values
      var imperial = metric.asImperial();
      for (var e in parsedWeights.entries) {
        if (e.key == SystemOfUnits.metric) {
          continue;
        }
        if (e.key == SystemOfUnits.imperial) {
          var i = e.value;
          if (i != imperial) {
            // Conflict between metric and imperial, this is an error!
            throw FormatException(
              'Conflicting weight information: ${metric.toString()} vs ${i.toString()} -- expecting ${imperial.toString()} in order to match metric value',
            );
          }
        }
        return metric;
      }
    }
    for (var e in parsedWeights.entries) {
      return e.value.asMetric();
    }
    return throw FormatException('No valid weight information found');
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

  bool get isImperial => pounds != null;
  bool get isMetric => kg != null;

  @override
  String toString() {
    if (isImperial) {
      return "${pounds ?? 0} lb";
    }
    if (isMetric) {
      return "$kg kg";
    }
    return '<unknown>';
  }

  static final double kilosPerPound = 0.45359237;

  Weight asMetric() {
    if (isMetric) {
      return this;
    }
    final kilograms = ((pounds ?? 0) * kilosPerPound).round();
    return Weight(kg: kilograms);
  }

  Weight asImperial() {
    if (isImperial) {
      return this;
    }
    final pounds = ((kg ?? 0) / kilosPerPound).round();
    return Weight(pounds: pounds);
  }
}
