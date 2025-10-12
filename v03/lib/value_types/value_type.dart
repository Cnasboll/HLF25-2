import 'package:equatable/equatable.dart';

enum SystemOfUnits { metric, imperial }

abstract class ValueType<T> extends Equatable implements Comparable<ValueType<T>> {
  
  ValueType(this.value, this.systemOfUnits);

  @override
  List<Object?> get props => [value, systemOfUnits];

  static (T?, String?) tryParseList<T>(
    List<String>? valueInVariousUnits,
    String valueTypeName,
    (T?, String?) Function(String) tryParse,
  ) {
    // Null is also accepted and means no information provided but an empty list is an error
    if (valueInVariousUnits == null) {
      return (null, null);
    }
    if (valueInVariousUnits.isEmpty) {
      return (null, 'No $valueTypeName information provided');
    }
    // In the example of weight we get 2010 lb and 95 kg.
    // 2010 lb is 95.25 kg, so the 95 kg is a correct rounded converted value from pounds (!).
    // However, if we used the metric value 95 kg as source of truth, that would be 209.44 pounds
    // Which, rounded to 209 pounds, is not a correct rounded value from 210 pounds. Why does the example use imperial as source of truth?

    // So we always use the first parsed value is the source of truth / master value, and check for conflicts with following values!
    ValueType<T>? value;
    String? valueSource;
    StringBuffer errors = StringBuffer();
    String separator = '';
    for (int i = 0; i < valueInVariousUnits.length; ++i) {
      final input = valueInVariousUnits[i].trim();
      var (parsedValue, errorMessge) =
          tryParse(input) as (ValueType<T>?, String?);
      if (parsedValue == null) {
        // Could not parse this value, add to the error list
        errors.write('$separator${errorMessge ?? 'Unknown error'}');
        separator = '; ';
        continue;
      }
      if (value == null) {
        value = parsedValue;
        valueSource = input;
        continue;
      }

      var valueSystemOfUnits = value.systemOfUnits;
      var parsedSystemOfUnits = parsedValue.systemOfUnits;
      if (parsedSystemOfUnits != valueSystemOfUnits) {
        // Convert `value` back to the same unit as master to verify that it is indeed derived from the same master value
        var parsedValueInMasterUnit =
            parsedValue.as(value.systemOfUnits) as ValueType<T>;

        var masterInSecondaryUnits = value.as(parsedSystemOfUnits);

        // In the example we have ['210 lb', '95 kg']. 210 lb is 95.25 kg but 95 kg is 209.44 pounds
        // so '95 kg' is  rounded version of '210 lb' and imperial is the master system of units,
        // Verify that in this case '95 kg' is indeed a rounded version of '210 lb'
        // '155 lb' is 70.3068 kg, so '70 kg' is a rounded version of '155 lb'
        // But '70 kg' is 154.323 lb, so '154 lb' is not a rounded version of '70 kg' so both checks are needed
        if (parsedValueInMasterUnit != value && masterInSecondaryUnits != parsedValue) {        
          errors.write(
            "${separator}Conflicting $valueTypeName information:"
            " ${parsedSystemOfUnits.name} '$input' corresponds to '$parsedValueInMasterUnit' after converting back to ${valueSystemOfUnits.name} -- expecting '$masterInSecondaryUnits' in order to match first value of '$valueSource'",
          );
        }
        separator = '; ';
      } else if (parsedValue != value) {
        errors.write(
          "${separator}Conflicting $valueTypeName information: '$input' doesn't match first value '$valueSource'",
        );
      }
    }

    if (value != null) {
      return (value as T, errors.isEmpty ? null : errors.toString());
    }

    if (errors.isEmpty) {
      errors.write('No valid $valueTypeName information found');
    }
    return (null, errors.toString());
  }

  bool get isImperial => systemOfUnits == SystemOfUnits.imperial;
  bool get isMetric => systemOfUnits == SystemOfUnits.metric;

  T as(SystemOfUnits system) {
    if (system == SystemOfUnits.imperial) {
      return asImperial();
    }
    return asMetric();
  }

  T asMetric() {
    if (isMetric) {
      return this as T;
    }
    return cloneMetric();
  }

  T asImperial() {
    if (isImperial) {
      return this as T;
    }
    return cloneImperial();
  }

  T cloneMetric();

  T cloneImperial();

  @override
  int compareTo(ValueType<T> other) {
    return value.compareTo(other.value);
  }

  final double value;
  final SystemOfUnits systemOfUnits;
}
