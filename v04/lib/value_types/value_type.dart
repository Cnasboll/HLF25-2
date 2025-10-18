import 'package:sqlite3/sqlite3.dart';
import 'package:v04/amendable/field_base.dart';
import 'package:v04/amendable/field_provider.dart';

enum SystemOfUnits { metric, imperial }

abstract class ValueType<T> extends FieldProvider<ValueType<T>> implements Comparable<ValueType<T>> {
  
  ValueType(this.value, this.systemOfUnits);

  @override
  List<Object?> get props => [value, systemOfUnits];

  static (double, SystemOfUnits) fromRow(FieldBase<ValueType> valueField, FieldBase<ValueType> systemOfUnitsField, Row row) {
    var value = valueField.getFloatFromRow(row, 0);
    var unitOfMeasurement = systemOfUnitsField.getEnumFromRow(
      SystemOfUnits.values,
      row,
      SystemOfUnits.imperial,
    );
    return (value, unitOfMeasurement);
  }

 static (T?, String?) tryParseList<T>(
    List<String>? valueInVariousUnits,
    String valueTypeName,
    (T?, String?) Function(String) tryParse,
  ) {
    // Null is also accepted and means no information provided (i.e. keep current for amendments), but an *empty* list is an error
    if (valueInVariousUnits == null) {
      return (null, null);
    }
    if (valueInVariousUnits.isEmpty) {
      return (null, 'No $valueTypeName information provided');
    }
    // In the example of weight we get 2010 lb and 95 kg.
    // 2010 lb is 95.25 kg, so the 95 kg is a correct rounded converted value from pounds (!).
    // However, if we used the metric value 95 kg as source of truth, that would be 209.44 pounds which,
    // rounded to 209 pounds, is not a correct rounded value from 210 pounds. Why does the example use imperial as source of truth?

    // So we always use the first parsed value is the source of truth / master value, and check for conflicts with any subsequent value(s)!
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

        var masterInParsedUnit = value.as(parsedSystemOfUnits);

        // CASE 1: In the example we have ['210 lb', '95 kg']. 210 lb is 95.25 kg but 95 kg is 209.44 pounds so
        // an alternative representation would be ['95 kg', '209 lb'] (not 210!) for the same weight but master in metric!
        // So '95 kg' is a rounded version of '210 lb'. In that case imperial, i.e. the first value, is the master system of units,
        // Verify that in this case '95 kg' is indeed a rounded version of '210 lb'
        bool parsedValueCorrespondsMasterButInDifferentUnit =
            parsedValue == masterInParsedUnit;

        // CASE 2: Try the other way around -- ['95 kg', '210 lb']. As 95 kgs converted to pounds is 209.44 then we would expect a second
        // rounded value of '209 lb' but we got something else, '210 lb', so this is a conflict.
        // We do a second test to verify that a rounded version of '210 lb' is indeed '95 kg' as per CASE 1 above so both tests need to fail to detect
        // a real conflict!
        bool parsedValueInMasterUnitsCorrespondsToMaster = parsedValueInMasterUnit == value;

        if (!parsedValueCorrespondsMasterButInDifferentUnit && !parsedValueInMasterUnitsCorrespondsToMaster) {
          errors.write(
            "${separator}Conflicting $valueTypeName information:"
            " ${parsedSystemOfUnits.name} '$parsedValue' corresponds to '$parsedValueInMasterUnit' after converting back to ${valueSystemOfUnits.name} -- expecting '$masterInParsedUnit' in order to match first value of '$value'",
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
