import 'package:test/test.dart';
import 'package:v03/value_types/weight.dart';

void main() {
  test('parse imperial', () {
    final w = Weight.parse("210 lb");
    expect(w.pounds, 210);
    expect(w.asMetric().kg, 95);
  });

  test('parse imperial compact', () {
    final w = Weight.parse("210lb");
    expect(w.pounds, 210);
    expect(w.asMetric().kg, 95);
  });

  test('parse cm', () {
    final w = Weight.parse('95 kg');
    expect(w.kg, 95);
    expect(w.asImperial().pounds, 210);
  });

  test('parse cm compact', () {
    final w = Weight.parse('95kg');
    expect(w.kg, 95);
    expect(w.asImperial().pounds, 210);
  });
  
  test('parse cm without unit', () {
    final w = Weight.parse('95');
    expect(w.kg, 95);
    expect(w.asImperial().pounds, 210);
  });  
}
