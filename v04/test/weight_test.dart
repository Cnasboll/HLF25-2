import 'package:test/test.dart';
import 'package:v04/value_types/weight.dart';

void main() {
  test('a dash means zero', () {
    final w = Weight.parse("- lb");
    expect(w.wholePounds, 0);
    expect(w.wholeKilograms, 0);
    expect(w.isImperial, true);
    expect(w.toString(), "- lb");
  });

  test('parse imperial', () {
    final w = Weight.parse("210 lb");
    expect(w.wholePounds, 210);
  });

  test('parse imperial', () {
    final w = Weight.parse("210 lb");
    expect(w.wholePounds, 210);
  });

  test(
    'parse 210 and 209 lb are both  95 kg verifying source data is ambiguous af',
    () {
      final lb210 = Weight.fromPounds(210);
      final lb209 = Weight.fromPounds(209);
      // It seesms like the api converts pounds to kilograms and rounds DOWN instead of to nearest
      expect(lb210.wholeKilograms, 95);
      expect(lb209.wholeKilograms, 94);
    },
  );

  test('parse imperial compact', () {
    final w = Weight.parse("210lb");
    expect(w.wholePounds, 210);
  });

  test('parse kg', () {
    final w = Weight.parse('95 kg');
    expect(w.wholeKilograms, 95);
    expect(w.asImperial().wholePounds, 209);
  });

  test('parse kg compact', () {
    final w = Weight.parse('95kg');
    expect(w.wholeKilograms, 95);
  });

  test('parse integer assumed kg', () {
    final w = Weight.parse('95');
    expect(w.wholeKilograms, 95);
  });

  /*Failed to parse hero id 256: Fin Fang Foom: FormatException: Could not parse weight: 18 tons
Failed to parse hero id 273: Galactus: FormatException: Could not parse weight: 16 tons
Failed to parse hero id 287: Godzilla: FormatException: Could not parse weight: 90,000 tons
Failed to parse hero id 303: Groot: FormatException: Could not parse weight: 4 tons
Failed to parse hero id 347: Iron Monger: FormatException: Could not parse weight: 2 tons
Failed to parse hero id 389: King Kong: FormatException: Could not parse weight: 9,000 tons
Failed to parse hero id 681: Utgard-Loki: FormatException: Could not parse weight: 58 tons*/
  test('parse Fin Fang Foom weight in tonnes', () {
    final w = Weight.parse('18 tons');
    expect(w.wholeKilograms, 18000);
  });

  test('parse Godzilla weight in tonnes', () {
    final w = Weight.parse('90,000 tons');
    expect(w.wholeKilograms, 90000000);
  });

  test('parse list with corresponding values in different systems', () {
    final imp = Weight.parseList(['209 lb', '95 kg']);
    expect(imp.wholePounds, 209);

    final imp2 = Weight.parseList(['210 lb', '95 kg']);
    expect(imp2.wholePounds, 210);

    // Note that 95 kgs can correspond to both 209 or 210 pounds
    final metric = Weight.parseList(['95 kg', '209 lb']);
    expect(metric.wholeKilograms, 95);

    final metric2 = Weight.parseList(['95 kg', '210 lb']);
    expect(metric2.wholeKilograms, 95);

    final metric3 = Weight.parseList(['95 kg', '210 lb', '209 lb'])!;
    expect(metric3.wholeKilograms, 95);

    final redundantMetric = Weight.parseList(['95 kg', '209 lb', "95"])!;
    expect(redundantMetric.wholeKilograms, 95);

    final moreImperial = Weight.parseList(["155 lb", "70 kg"])!;
    expect(moreImperial.wholePounds, 155);
  });

  test('parse with in conflicting values in different systems', () {
    expect(
      () => Weight.parseList(['210 lb', '94 kg']),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message ==
                  "Conflicting weight information: metric '94 kg' corresponds to '207 lb' after converting back to imperial -- expecting '95 kg' in order to match first value of '210 lb'",
        ),
      ),
    );
  });

  test('parse list with conflicting values in same system', () {
    expect(
      () => Weight.parseList(['210 lb', '209 lb']),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message ==
                  "Conflicting weight information: '209 lb' doesn't match first value '210 lb'",
        ),
      ),
    );
  });
}
