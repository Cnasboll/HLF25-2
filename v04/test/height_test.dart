import 'dart:math';

import 'package:test/test.dart';
import 'package:v04/value_types/height.dart';

void main() {

  test('zero feet zero inches is a ash', () {
    final h = Height.parse("-");
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 0);
    expect(inches, 0);
    expect(h.wholeCentimeters, 0);
    expect(h.isImperial, true);
    expect(h.toString(), "-");
  });

  test('parse imperial shorthand', () {
    final h = Height.parse("6'2\"");
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
    expect(h.wholeCentimeters, 188);
  });

  test('parse imperial shorthand with space', () {
    final h = Height.parse("6 '2 \"");
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
    expect(h.wholeCentimeters, 188);
  });

  test('parse imperial verbose', () {
    final h = Height.parse('6 ft 2 in');
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
  });

  test('parse cm', () {
    final h = Height.parse('188 cm');
    expect(h.wholeCentimeters, 188);
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
  });

  test('parse cm compact', () {
    final h = Height.parse('188cm');
    expect(h.wholeCentimeters, 188);
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
  });

  test('parse integer asumed cm', () {
    final h = Height.parse('188');
    expect(h.wholeCentimeters, 188);
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);
  });

  test('parse integral m', () {
    final h = Height.parse('2 m');
    expect(h.wholeCentimeters, 200);
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 7);
  });

  test('parse integer assumed m', () {
    final h = Height.parse('2');
    expect(h.wholeCentimeters, 200);
    var (feet, inches) = h.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 7);
  });

  test('parse meters', () {
    final h = Height.parse('1.88 m');
    expect(h.wholeCentimeters, 188);
  });

  test('parse meters compact', () {
    final h = Height.parse('1.88m');
    expect(h.wholeCentimeters, 188);
  });

  test('parse double assumed meters', () {
    final h = Height.parse('1.88');
    expect(h.wholeCentimeters, 188);
  });

  test('parse list with corresponding values in different systems', () {
    final imp = Height.parseList(['6\'2"', '188 cm'])!;
    var (feet, inches) = imp.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);

    final impWithOtherMetric = Height.parseList(['6\'2"', '189 cm'])!;
    (feet, inches) = impWithOtherMetric.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);

    final redundantImp = Height.parseList(['6\'2"', '188 cm', '6 ft 2 in'])!;
    (feet, inches) = redundantImp.wholeFeetAndWholeInches;
    expect(feet, 6);
    expect(inches, 2);

    final metric = Height.parseList(['188 cm', '6\'2"'])!;
    expect(metric.wholeCentimeters, 188);

    final redundantMetric = Height.parseList(['188 cm', '6\'2"', "1.88"])!;
    expect(redundantMetric.wholeCentimeters, 188);
  });

  test('parse with in conflicting values in different systems', () {
    expect(
      () => Height.parseList(['6\'2"', '190 cm']),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message ==
                  "Conflicting height information: metric '190 cm' corresponds to '6'3\"' after converting back to imperial -- expecting '188 cm' in order to match first value of '6'2\"'",
        ),
      ),
    );
  });

  test('parse list with conflicting values in same system', () {
    expect(
      () => Height.parseList(['6\'2"', '6 feet 3']),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message ==
                  "Conflicting height information: '6 feet 3' doesn't match first value '6'2\"'",
        ),
      ),
    );
  });
}
