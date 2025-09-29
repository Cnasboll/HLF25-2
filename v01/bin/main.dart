import 'dart:io';
import 'package:v01/calculator/calculator.dart';
import 'package:v01/parser/parser.dart';
import 'package:v01/tokenizer/state_machine.dart';

void main(List<String> arguments) {
  for (;;) {
    print('Enter a mathematical expression or "q" to stop or "h" for help');
    var input = (stdin.readLineSync() ?? "").trim();
    if (input.toLowerCase().startsWith("q")) {
      break;
    }

    if (input.toLowerCase().startsWith("h")) {
      print(
        """Enter an arhithmetic or boolean expression and press enter. The following features are supported:
      Arithmetics: *,/,%,+,- 
      Operators are evaluated in the order of typical precendence but overriden by parentheses,
      i.e. (3.7)*3+2 is not the same  as 3.7*(3+2) and so on.
      Relational operators: <, >, <>, <=, >= (true evaluates to 1 and false to 0)
      Boolean operators: unary NOT, AND, OR, XOR (true evaluates to 1 and false to 0)
      Some mathematical constants: E, LN10, LN2, LOG2E, LOG10E, PI, SQRT1_2, SQRT2, AVOGADRO and ANSWER.
      Constants TRUE is 1 and FALSE is 0.
      Some binary and unary mathematical functions all mapped from dart:maths:
      MIN, MAX, ATAN2, POW, SIN, COS, TAN, ACOS, ASIN, ATAN, SQRT, EXP, LOG
      """,
      );
      continue;
    }
    try {
      print(Calculator.calculate(input));
    } on StateError catch (e) {
      print(
        "Somehing went wrong during Oskar's attempts to understand Dart iterators: ${e.message}",
      );
    } on TokenizerException catch (e) {
      print('Somehing went wrong during tokenization: ${e.message}');
    } on ParseException catch (e) {
      print('Somehing went wrong during parsing: ${e.message}');
    } on RuntimeException catch (e) {
      print('Somehing went wrong during evaluation: ${e.message}');
    } on Exception catch (e) {
      print('Something really unknown: $e');
    }
  }
}
