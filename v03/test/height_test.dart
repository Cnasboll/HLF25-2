import 'package:test/test.dart';
import 'package:v03/value_types/height.dart';

void main() {
  test('parse imperial shorthand', () {
    final h = Height.parse("6'2\"");
    expect(h.feet, 6);
    expect(h.inches, 2);
    expect(h.asMetric().cm, 188);
  });

    test('parse imperial shorthand with space', () {
    final h = Height.parse("6 '2 \"");
    expect(h.feet, 6);
    expect(h.inches, 2);
    expect(h.asMetric().cm, 188);
  });

  test('parse imperial verbose', () {
    final h = Height.parse('6 ft 2 in');
    expect(h.feet, 6);
    expect(h.inches, 2);
  });

  test('parse cm', () {
    final h = Height.parse('188 cm');
    expect(h.cm, 188);
    final imp = h.asImperial();
    expect(imp.feet, 6);
    // inches could be 2 or 1 depending on rounding; allow 2
    expect(imp.inches, inInclusiveRange(1, 2));
  });

  test('parse cm compact', () {
    final h = Height.parse('188cm');
    expect(h.cm, 188);
    final imp = h.asImperial();
    expect(imp.feet, 6);
    // inches could be 2 or 1 depending on rounding; allow 2
    expect(imp.inches, inInclusiveRange(1, 2));
  });
  
  test('parse cm without unit', () {
    final h = Height.parse('188');
    expect(h.cm, 188);
    final imp = h.asImperial();
    expect(imp.feet, 6);
    // inches could be 2 or 1 depending on rounding; allow 2
    expect(imp.inches, inInclusiveRange(1, 2));
  });

  test('parse meters', () {
    final h = Height.parse('1.88 m');
    expect(h.cm, 188);
  });

    test('parse meters compact', () {
    final h = Height.parse('1.88m');
    expect(h.cm, 188);
  });

  test('parse meters without unit', () {
    final h = Height.parse('1.88');
    expect(h.cm, 188);
  });
}
