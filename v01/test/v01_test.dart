import 'package:v01/calculator/calculator.dart';
import 'package:v01/parser/constants_set.dart';
import 'package:v01/parser/lookahead_iterator.dart';
import 'package:v01/parser/parser.dart';
import 'package:v01/tokenizer/token.dart';
import 'package:v01/tokenizer/tokenizer.dart';
import 'package:test/test.dart';

void main() {
  test('tokenize_addition', () {
    var v = Tokenizer.tokenize('10+2').toList();

    expect(3, v.length);
    expect(TokenTypes.integerLiteral, v[0].tokenType);
    expect(Symbols.none, v[0].symbol);
    expect(TokenTypes.add, v[1].tokenType);
    expect(Symbols.add, v[1].symbol);
    expect(TokenTypes.integerLiteral, v[2].tokenType);
    expect(Symbols.none, v[2].symbol);
  });

  test('parse_addition', () {
    var v = Tokenizer.tokenize('10+2').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(Symbols.integerLiteral, p.children[0].symbol);
    expect(10, constantsSet.integers.constants[p.children[0].qualifier!]);
    expect(Symbols.integerLiteral, p.children[1].symbol);
    expect(10, constantsSet.integers.constants[p.children[0].qualifier!]);
  });

  test('calculate_addition', () {
    expect(12, Calculator.calculate('10+2'));
  });

  test('parse_addition_and_multiplication', () {
    var v = Tokenizer.tokenize('10+13*37+1').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(Symbols.add, p.children[0].symbol);
    expect(Symbols.integerLiteral, p.children[0].children[0].symbol);
    expect(
      10,
      constantsSet.integers.constants[p.children[0].children[0].qualifier!],
    );
    expect(Symbols.mul, p.children[0].children[1].symbol);
    expect(
      Symbols.integerLiteral,
      p.children[0].children[1].children[0].symbol,
    );
    expect(
      13,
      constantsSet.integers.constants[p
          .children[0]
          .children[1]
          .children[0]
          .qualifier!],
    );
    expect(
      Symbols.integerLiteral,
      p.children[0].children[1].children[1].symbol,
    );
    expect(
      37,
      constantsSet.integers.constants[p
          .children[0]
          .children[1]
          .children[1]
          .qualifier!],
    );
    expect(Symbols.integerLiteral, p.children[1].symbol);
    expect(1, constantsSet.integers.constants[p.children[1].qualifier!]);
  });

  test('calculate_addition_and_multiplication', () {
    expect(492, Calculator.calculate('10+13*37+1'));
  });

  test('parse_addition_and_multiplication_with_parenthesis', () {
    var v = Tokenizer.tokenize('10+13*(37+1)').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(Symbols.integerLiteral, p.children[0].symbol);
    expect(10, constantsSet.integers.constants[p.children[0].qualifier!]);
    expect(Symbols.mul, p.children[1].symbol);
    expect(Symbols.integerLiteral, p.children[1].children[0].symbol);
    expect(
      13,
      constantsSet.integers.constants[p.children[1].children[0].qualifier!],
    );
    expect(Symbols.add, p.children[1].children[1].symbol);
    expect(
      Symbols.integerLiteral,
      p.children[1].children[1].children[0].symbol,
    );
    expect(
      37,
      constantsSet.integers.constants[p
          .children[1]
          .children[1]
          .children[0]
          .qualifier!],
    );
    expect(
      Symbols.integerLiteral,
      p.children[1].children[1].children[1].symbol,
    );
    expect(
      1,
      constantsSet.integers.constants[p
          .children[1]
          .children[1]
          .children[1]
          .qualifier!],
    );
  });

  test('calculate_addition_and_multiplication_with_parenthesis', () {
    expect(504, Calculator.calculate('10+13*(37+1)'));
  });

  test('parse_addition_multiplication_and_subtraction', () {
    var v = Tokenizer.tokenize('10+13*37-1').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.sub, p.symbol);
    expect(Symbols.add, p.children[0].symbol);
    expect(Symbols.integerLiteral, p.children[0].children[0].symbol);
    expect(
      10,
      constantsSet.integers.constants[p.children[0].children[0].qualifier!],
    );
    expect(Symbols.mul, p.children[0].children[1].symbol);
    expect(
      Symbols.integerLiteral,
      p.children[0].children[1].children[0].symbol,
    );
    expect(
      13,
      constantsSet.integers.constants[p
          .children[0]
          .children[1]
          .children[0]
          .qualifier!],
    );
    expect(
      Symbols.integerLiteral,
      p.children[0].children[1].children[1].symbol,
    );
    expect(
      37,
      constantsSet.integers.constants[p
          .children[0]
          .children[1]
          .children[1]
          .qualifier!],
    );
    expect(Symbols.integerLiteral, p.children[1].symbol);
    expect(1, constantsSet.integers.constants[p.children[1].qualifier!]);
  });

  test('calculate_addition_multiplication_and_subtraction', () {
    expect(490, Calculator.calculate('10+13*37-1'));
  });

  test('calculate_addition_multiplication_subtraction_and_division', () {
    expect(249.5, Calculator.calculate('10+13*37/2-1'));
  });

  test('tokenize_modulus', () {
    var v = Tokenizer.tokenize('9%2').toList();

    expect(3, v.length);
    expect(TokenTypes.integerLiteral, v[0].tokenType);
    expect(Symbols.none, v[0].symbol);
    expect(TokenTypes.mod, v[1].tokenType);
    expect(Symbols.mod, v[1].symbol);
    expect(TokenTypes.integerLiteral, v[2].tokenType);
    expect(Symbols.none, v[2].symbol);
  });

  test('calculate_modulus', () {
    expect(1, Calculator.calculate('9%2'));
  });

  test('calculate_relops_eq_true', () {
    expect(1, Calculator.calculate('5*2 = 2+8'));
  });

  test('calculate_relops_eq_false', () {
    expect(0, Calculator.calculate('5*2 = 1+8'));
  });

  test('calculate_relops_neq_true', () {
    expect(1, Calculator.calculate('5*2 <> 1+8'));
  });

  test('calculate_relops_neq_false', () {
    expect(0, Calculator.calculate('5*2 <> 2+8'));
  });

  test('calculate_relops_lt_false', () {
    expect(0, Calculator.calculate('10<1'));
  });

  test('calculate_relops_lt_true', () {
    expect(1, Calculator.calculate('1<10'));
  });

  test('calculate_relops_lteq_false', () {
    expect(0, Calculator.calculate('10<=1'));
  });

  test('calculate_relops_lteq_true', () {
    expect(1, Calculator.calculate('1<=10'));
  });

  test('calculate_relops_gt_false', () {
    expect(0, Calculator.calculate('1>10'));
  });

  test('calculate_relops_gt_true', () {
    expect(1, Calculator.calculate('10>1'));
  });

  test('calculate_relops_gteq_false', () {
    expect(0, Calculator.calculate('1>=10'));
  });

  test('calculate_relops_gteq_true', () {
    expect(1, Calculator.calculate('10>=1'));
  });

  test('calculate_some_bool_algebra_and_true', () {
    expect(1, Calculator.calculate('1<10 AND 2<9'));
  });

  test('calculate_some_bool_algebra_and_fals', () {
    expect(0, Calculator.calculate('1>10 AND 2<9'));
  });

  test('calculate_some_bool_algebra_or_true', () {
    expect(1, Calculator.calculate('1>10 OR 2<9'));
  });

  test('calculate_some_bool_algebra_xor_true', () {
    expect(1, Calculator.calculate('1>10 XOR 2<9'));
  });

  test('calculate_some_bool_algebra_xor_false', () {
    expect(0, Calculator.calculate('10>1 XOR 2<9'));
  });

  test('calculate_negation', () {
    expect(0, Calculator.calculate('NOT 11'));
  });

  test('calculate_unary_minus', () {
    expect(6, Calculator.calculate('-5+11'));
  });

  test('calculate_unary_plus', () {
    expect(16, Calculator.calculate('+5+11'));
  });

  test('calculate_with_constants', () {
    expect(3.1415926535897932 * 2, Calculator.calculate('PI * 2'));
  });

  test('calculate_with_functions', () {
    expect(4, Calculator.calculate('POW(2,2)'));
  });

  test('calculate_with_two_functions', () {
    expect(6, Calculator.calculate('POW(2,2)+SQRT(4)'));
  });

  test('calculate_nested_function_call', () {
    expect(2, Calculator.calculate('SQRT(POW(2,2))'));
  });

  test('calculate_nested_function_call_with_expression', () {
    expect(3.7416573867739413, Calculator.calculate('SQRT(POW(2,2)+10)'));
  });

  test('tokenize_spaced_identifiers', () {
    var v = Tokenizer.tokenize('hello world').toList();

    expect(2, v.length);
    expect(TokenTypes.identifier, v[0].tokenType);
    expect(Symbols.none, v[0].symbol);
    expect(TokenTypes.identifier, v[1].tokenType);
    expect(Symbols.none, v[1].symbol);
  });

  test('tokenize_keywords', () {
    var v = Tokenizer.tokenize('NOT XOR AND OR').toList();

    expect(4, v.length);
    expect(TokenTypes.identifier, v[0].tokenType);
    expect(Keywords.notKeyword, v[0].keyword);
    expect(Symbols.not, v[0].symbol);
    expect(TokenTypes.identifier, v[1].tokenType);
    expect(Keywords.xorKeyword, v[1].keyword);
    expect(Symbols.xor, v[1].symbol);
    expect(TokenTypes.identifier, v[2].tokenType);
    expect(Keywords.andKeyword, v[2].keyword);
    expect(Symbols.and, v[2].symbol);
    expect(TokenTypes.identifier, v[3].tokenType);
    expect(Keywords.orKeyword, v[3].keyword);
    expect(Symbols.or, v[3].symbol);
  });

  test('parse_function_call', () {
    var v = Tokenizer.tokenize('f()').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.identifier, p.symbol);
    expect(true, p.children.isEmpty);
  });

  test('parse_function_call_op', () {
    var v = Tokenizer.tokenize('f()+1').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(2, p.children.length);
  });

  test('parse_function_call_1_arg', () {
    var v = Tokenizer.tokenize('f(1)').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.identifier, p.symbol);
    expect(1, p.children.length);
  });

  test('parse_function_call_1_arg_op', () {
    var v = Tokenizer.tokenize('f(1)+1').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(2, p.children.length);
  });

  test('parse_function_call_1_arg_op_with_expression', () {
    var v = Tokenizer.tokenize('f(1*2, 2)+1').toList();
    var constantsSet = ConstantsSet();
    var p = Parser.parse(v.lookahead(), constantsSet);
    expect(Symbols.add, p.symbol);
    expect(2, p.children.length);
  });
}
