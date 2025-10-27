import 'package:v04/shql/calculator/calculator.dart';
import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/shql/parser/lookahead_iterator.dart';
import 'package:v04/shql/parser/parser.dart';
import 'package:v04/shql/tokenizer/token.dart';
import 'package:v04/shql/tokenizer/tokenizer.dart';
import 'package:test/test.dart';

void main() {
    test('Parse addition', () {
    var v = Tokenizer.tokenize('10+2').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(Symbols.integerLiteral, p.children[0].symbol);
    expect(10, constantsSet.integers.constants[p.children[0].qualifier!]);
    expect(Symbols.integerLiteral, p.children[1].symbol);
    expect(10, constantsSet.integers.constants[p.children[0].qualifier!]);
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

  test('Calculate not equal false', () {
    expect(0, Calculator.calculate('5*2 <> 2+8'));
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

}
