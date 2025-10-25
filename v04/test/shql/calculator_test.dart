import 'package:v04/models/appearance_model.dart';
import 'package:v04/models/biography_model.dart';
import 'package:v04/shql/calculator/calculator.dart';
import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/shql/parser/lookahead_iterator.dart';
import 'package:v04/shql/parser/parser.dart';
import 'package:v04/shql/tokenizer/token.dart';
import 'package:v04/shql/tokenizer/tokenizer.dart';
import 'package:test/test.dart';
import 'package:v04/value_types/value_type.dart';

void main() {
    test('Parse addition', () {
    var v = Tokenizer.tokenize('10+2').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(Symbols.integerLiteral, p.children[0].symbol);
    expect(10, constantsSet.constants.constants[p.children[0].qualifier!]);
    expect(Symbols.integerLiteral, p.children[1].symbol);
    expect(10, constantsSet.constants.constants[p.children[0].qualifier!]);
  });

  test('Calculate addition', () {
    expect(12, Calculator.calculate('10+2'));
  });
  test('Calculate addition and multiplication', () {
    expect(492, Calculator.calculate('10+13*37+1'));
  });

  test('Calculate addition and multiplication with parenthesis', () {
    expect(504, Calculator.calculate('10+13*(37+1)'));
  });

  test('Calculate addition, multiplication and subtraction', () {
    expect(490, Calculator.calculate('10+13*37-1'));
  });

  test('Calculate addition, multiplication, subtraction and division', () {
    expect(249.5, Calculator.calculate('10+13*37/2-1'));
  });

  test('Calculate modulus', () {
    expect(1, Calculator.calculate('9%2'));
  });

  test('Calculate equality true', () {
    expect(1, Calculator.calculate('5*2 = 2+8'));
  });

  test('Calculate equality false', () {
    expect(0, Calculator.calculate('5*2 = 1+8'));
  });

  test('Calculate not equal true', () {
    expect(1, Calculator.calculate('5*2 <> 1+8'));
  });

  test('Calculate not equal true with exclamation equals', () {
    expect(1, Calculator.calculate('5*2 != 1+8'));
  });

  test('Evaluate match true', () {
    expect(1, Calculator.calculate('"Super Man" ~  r"Super\\s*Man"'));
    expect(1, Calculator.calculate('"Superman" ~  r"Super\\s*Man"'));
    expect(1, Calculator.calculate('"Batman" ~  "batman"'));
  });

  test('Evaluate match false', () {
    expect(0, Calculator.calculate('"Bat Man" ~  r"Super\\s*Man"'));
    expect(0, Calculator.calculate('"Batman" ~  r"Super\\s*Man"'));
  });

  test('Evaluate mismatch true', () {
    expect(1, Calculator.calculate('"Bat Man" !~  r"Super\\s*Man"'));
    expect(1, Calculator.calculate('"Batman" !~  r"Super\\s*Man"'));

  });

  test('Evaluate mismatch false', () {
    expect(0, Calculator.calculate('"Super Man" !~  r"Super\\s*Man"'));
    expect(0, Calculator.calculate('"Superman" !~  r"Super\\s*Man"'));
  });

  test('Evaluate in list true', () {
    expect(1, Calculator.calculate('"Super Man" in ["Super Man", "Batman"]'));
    expect(1, Calculator.calculate('"Batman" in  ["Super Man", "Batman"]'));
  });

  test('Evaluate lower case in list true', () {
    expect(1, Calculator.calculate('lowercase("Robin") in  ["batman", "robin"]'));
    expect(1, Calculator.calculate('lowercase("Batman") in  ["batman", "robin"]'));
  });

  test('Evaluate in list false', () {
    expect(0, Calculator.calculate('"Robin" in  ["Super Man", "Batman"]'));
    expect(0, Calculator.calculate('"Superman" in ["Super Man", "Batman"]'));
  });

  test('Evaluate lower case in list false', () {
    expect(0, Calculator.calculate('lowercase("robin") in  ["super man", "batman"]'));
    expect(0, Calculator.calculate('lowercase("superman") in  ["super man", "batman"]'));
  });

  test('Calculate not equal false', () {
    expect(0, Calculator.calculate('5*2 <> 2+8'));
  });

  test('Calculate not equal false with exclamation equals', () {
    expect(0, Calculator.calculate('5*2 != 2+8'));
  });

  test('Calculate less than false', () {
    expect(0, Calculator.calculate('10<1'));
  });

  test('Calculate less than true', () {
    expect(1, Calculator.calculate('1<10'));
  });

  test('Calculate less than or equal false', () {
    expect(0, Calculator.calculate('10<=1'));
  });

  test('Calculate less than or equal true', () {
    expect(1, Calculator.calculate('1<=10'));
  });

  test('Calculate greater than false', () {
    expect(0, Calculator.calculate('1>10'));
  });

  test('Calculate greater than true', () {
    expect(1, Calculator.calculate('10>1'));
  });

  test('Calculate greater than or equal false', () {
    expect(0, Calculator.calculate('1>=10'));
  });

  test('Calculate greater than or equal true', () {
    expect(1, Calculator.calculate('10>=1'));
  });

  test('Calculate some boolean algebra and true', () {
    expect(1, Calculator.calculate('1<10 AND 2<9'));
  });

  test('Calculate some boolean algebra and false', () {
    expect(0, Calculator.calculate('1>10 AND 2<9'));
  });

  test('Calculate some boolean algebra or true', () {
    expect(1, Calculator.calculate('1>10 OR 2<9'));
  });

  test('Calculate some boolean algebra xor true', () {
    expect(1, Calculator.calculate('1>10 XOR 2<9'));
  });

  test('calculate_some_bool_algebra_xor_false', () {
    expect(0, Calculator.calculate('10>1 XOR 2<9'));
  });

  test('calculate_negation', () {
    expect(0, Calculator.calculate('NOT 11'));
  });

  test('calculate_negation with exclamation', () {
    expect(0, Calculator.calculate('!11'));
  });

  test('Calculate unary minus', () {
    expect(6, Calculator.calculate('-5+11'));
  });

  test('Calculate unary plus', () {
    expect(16, Calculator.calculate('+5+11'));
  });

  test('Calculate with constants', () {
    expect(3.1415926535897932 * 2, Calculator.calculate('PI * 2'));
  });

  test('Calculate with functions', () {
    expect(4, Calculator.calculate('POW(2,2)'));
  });

  test('Calculate with two functions', () {
    expect(6, Calculator.calculate('POW(2,2)+SQRT(4)'));
  });

  test('Calculate nested function call', () {
    expect(2, Calculator.calculate('SQRT(POW(2,2))'));
  });

  test('Calculate nested function call with expression', () {
    expect(3.7416573867739413, Calculator.calculate('SQRT(POW(2,2)+10)'));
  });

  test('Export enums', () {
    ConstantsSet constantsSet = Calculator.prepareConstantsSet();
    constantsSet.registerEnum<Alignment>(Alignment.values);
    constantsSet.registerEnum<Gender>(Gender.values);
    constantsSet.registerEnum<SystemOfUnits>(SystemOfUnits.values);
    expect(0, Calculator.calculate('unknown', constantsSet: constantsSet));
    expect(1, Calculator.calculate('neutral', constantsSet: constantsSet));
    expect(2, Calculator.calculate('mostlyGood', constantsSet: constantsSet));
    expect(3, Calculator.calculate('good', constantsSet: constantsSet));
    expect(4, Calculator.calculate('reasonable', constantsSet: constantsSet));
    expect(5, Calculator.calculate('notQuite', constantsSet: constantsSet));
    expect(6, Calculator.calculate('bad', constantsSet: constantsSet));
    expect(7, Calculator.calculate('ugly', constantsSet: constantsSet));
    expect(8, Calculator.calculate('evil', constantsSet: constantsSet));
    expect(9, Calculator.calculate('usingMobileSpeakerOnPublicTransport', constantsSet: constantsSet));

    expect(0, Calculator.calculate('unknown', constantsSet: constantsSet));
    expect(1, Calculator.calculate('ambiguous', constantsSet: constantsSet));
    expect(2, Calculator.calculate('male', constantsSet: constantsSet));
    expect(3, Calculator.calculate('female', constantsSet: constantsSet));
    expect(4, Calculator.calculate('nonBinary', constantsSet: constantsSet));
    expect(5, Calculator.calculate('wontSay', constantsSet: constantsSet));

    expect(0, Calculator.calculate('metric', constantsSet: constantsSet));
    expect(1, Calculator.calculate('imperial', constantsSet: constantsSet));
  });
}
