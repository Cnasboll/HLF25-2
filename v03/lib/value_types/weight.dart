import 'dart:convert';

import 'package:v03/value_types/value_type.dart';

enum WeightUnit { pounds, kilograms }

class Weight extends ValueType<Weight> {
  final int? pounds;
  final int? kilograms;

  const Weight({this.pounds, this.kilograms});

  Weight.fromMap(Map<WeightUnit, int> partsPerUnit)
    : pounds = partsPerUnit[WeightUnit.pounds],
      kilograms = partsPerUnit[WeightUnit.kilograms];

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
          return (Weight(pounds: value), null);
        }
        return (Weight(kilograms: value), null);
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
  List<Object?> get props => [pounds, kilograms];

  @override
  bool get isImperial => pounds != null;
  @override
  bool get isMetric => kilograms != null;

  @override
  String toString() {
    if (isImperial) {
      return "${pounds ?? 0} lb";
    }
    if (isMetric) {
      return "$kilograms kg";
    }
    return '<unknown>';
  }

  static final double kilosgramsPerPound = 0.45359237;

  @override
  Weight cloneMetric() {
    final kilograms = ((pounds ?? 0) * kilosgramsPerPound).round();
    return Weight(kilograms: kilograms);
  }

  @override
  Weight cloneImperial() {
    final pounds = ((kilograms ?? 0) / kilosgramsPerPound).round();
    return Weight(pounds: pounds);
  }

  @override
  double toMetricExact() {
    return asMetric().kilograms?.toDouble() ?? 0;
  }
}
