import 'dart:math';

import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/shql/parser/lookahead_iterator.dart';
import 'package:v04/shql/parser/parse_tree.dart';
import 'package:v04/shql/parser/parser.dart';
import 'package:v04/shql/tokenizer/token.dart';
import 'package:v04/shql/tokenizer/tokenizer.dart';

class RuntimeException implements Exception {
  final String message;

  RuntimeException(this.message);

  @override
  String toString() => 'RunitmeException: $message';
}

class Calculator {
  static num calculate(String expression) {
    var v = Tokenizer.tokenize(expression).toList();
    var constantsSet = ConstantsSet();

    var tokenEnumerator = v.lookahead();
    var p = Parser.parse(tokenEnumerator, constantsSet);

    if (tokenEnumerator.hasNext) {
      throw RuntimeException(
        'Unexpcted token "${tokenEnumerator.next().lexeme}" after parsing expression.',
      );
    }

    // Register mathematical constants
    for (var entry in _mathematicalConstants.entries) {
      constantsSet.identifiers.include(entry.key);
    }

    // Register mathematical functions
    for (var entry in _mathematicalFunctions.entries) {
      constantsSet.identifiers.include(entry.key);
    }
    return evaluate(p, constantsSet);
  }

  static num evaluate(ParseTree parseTree, ConstantsSet constantsSet) {
    var result = evaluateTerminal(parseTree, constantsSet);
    if (result != null) {
      return result;
    }
    result = evaluateUnary(parseTree, constantsSet);
    if (result != null) {
      return result;
    }

    if (parseTree.children.length < 2) {
      return double.nan;
    }

    return evaluateBinaryOperator(
      parseTree.symbol,
      evaluate(parseTree.children[0], constantsSet),
      evaluate(parseTree.children[1], constantsSet),
    );
  }

  static num evaluateBinaryOperator(Symbols symbol, num argument1, argument2) {
    switch (symbol) {
      case Symbols.add:
        return argument1 + argument2;

      case Symbols.sub:
        return argument1 - argument2;

      case Symbols.div:
        return argument1 / argument2;

      case Symbols.eq:
        {
          return argument1 == argument2 ? 1 : 0;
        }
      case Symbols.gt:
        return argument1 > argument2 ? 1 : 0;

      case Symbols.gtEq:
        return argument1 >= argument2 ? 1 : 0;
      case Symbols.lt:
        return argument1 < argument2 ? 1 : 0;
      case Symbols.ltEq:
        return argument1 <= argument2 ? 1 : 0;
      case Symbols.mod:
        return argument1 % argument2;
      case Symbols.mul:
        return argument1 * argument2;
      case Symbols.neq:
        return argument1 != argument2 ? 1 : 0;

      case Symbols.and:
        return (argument1 != 0) && (argument2 != 0) ? 1 : 0;
      case Symbols.or:
        return (argument1 != 0) || (argument2 != 0) ? 1 : 0;
      case Symbols.xor:
        return (argument1 != 0) != (argument2 != 0) ? 1 : 0;
      default:
        return double.nan;
    }
  }

  static num? evaluateTerminal(ParseTree parseTree, ConstantsSet constantsSet) {
    switch (parseTree.symbol) {
      case Symbols.floatLiteral:
        return constantsSet.doubles.constants[parseTree.qualifier!];
      case Symbols.integerLiteral:
        return constantsSet.integers.constants[parseTree.qualifier!];
      case Symbols.identifier:
        return evaluateIdentifier(parseTree, constantsSet);
      default:
        return null;
    }
  }

  static num? evaluateIdentifier(
    ParseTree parseTree,
    ConstantsSet constantsSet,
  ) {
    var identifier = constantsSet.identifiers.constants[parseTree.qualifier!];
    var constant = _mathematicalConstants[identifier];
    if (constant != null) {
      if (parseTree.children.isNotEmpty) {
        var argumentCount = parseTree.children.length;
        throw RuntimeException(
          "Attempt to use constant $identifier as a function: ($argumentCount) argument(s) given.",
        );
      }
      return constant;
    }

    var functionArity = _mathematicalFunctions[identifier];
    if (functionArity != null) {
      if (parseTree.children.length != functionArity) {
        var argumentCount = parseTree.children.length;
        throw RuntimeException(
          "Function $identifier() takes $functionArity argument(s), $argumentCount given.",
        );
      }

      if (functionArity == 1) {
        return evaluateUnaryFunction(
          identifier,
          evaluate(parseTree.children.first, constantsSet),
        );
      }

      if (functionArity == 2) {
        return evaluateBinaryFunction(
          identifier,
          evaluate(parseTree.children[0], constantsSet),
          evaluate(parseTree.children[1], constantsSet),
        );
      }
    }

    if (parseTree.children.isNotEmpty) {
      throw RuntimeException(
        'Unidentified identifier "$identifier" used as a function.',
      );
    }
    throw RuntimeException(
      'Unidentified identifier "$identifier" used as a constant.',
    );
  }

  static num evaluateUnaryFunction(String name, num argument) {
    switch (name) {
      case "SIN":
        return sin(argument);
      case "COS":
        return cos(argument);
      case "TAN":
        return tan(argument);
      case "ACOS":
        return acos(argument);
      case "ASIN":
        return asin(argument);
      case "ATAN":
        return atan(argument);
      case "SQRT":
        return sqrt(argument);
      case "EXP":
        return exp(argument);
      case "LOG":
        return log(argument);
      default:
        return double.nan;
    }
  }

  static num evaluateBinaryFunction(String name, num argument1, argument2) {
    switch (name) {
      case "MIN":
        return min(argument1, argument2);
      case "MAX":
        return max(argument1, argument2);
      case "ATAN2":
        return atan2(argument1, argument2);
      case "POW":
        return pow(argument1, argument2);
      default:
        return double.nan;
    }
  }

  static bool isUnary(Symbols symbol) {
    return [
      Symbols.unaryMinus,
      Symbols.unaryPlus,
      Symbols.not,
    ].contains(symbol);
  }

  static num? evaluateUnary(ParseTree parseTree, ConstantsSet constantsSet) {
    if (!isUnary(parseTree.symbol)) {
      return null;
    }
    if (parseTree.children.isEmpty) {
      return double.nan;
    }

    switch (parseTree.symbol) {
      case Symbols.unaryMinus:
        // Unary minus
        return -evaluate(parseTree.children.first, constantsSet);
      case Symbols.unaryPlus:
        // Unary plus
        return evaluate(parseTree.children.first, constantsSet);
      case Symbols.not:
        return evaluate(parseTree.children.first, constantsSet) == 0 ? 1 : 0;
      default:
        return null;
    }
  }

  static final Map<String, num> _mathematicalConstants = {
    "E": e,
    "LN10": ln10,
    "LN2": ln2,
    "LOG2E": log2e,
    "LOG10E": log10e,
    "PI": pi,
    "SQRT1_2": sqrt1_2,
    "SQRT2": sqrt2,
    "AVOGADRO": 6.0221408e+23,
    "ANSWER": 42,
    "TRUE": 1,
    "FALSE": 0,
  };

  static final Map<String, int> _mathematicalFunctions = {
    //Functions and their arity
    "MIN": 2,
    "MAX": 2,
    "ATAN2": 2,
    "POW": 2,
    "SIN": 1,
    "COS": 1,
    "TAN": 1,
    "ACOS": 1,
    "ASIN": 1,
    "ATAN": 1,
    "SQRT": 1,
    "EXP": 1,
    "LOG": 1,
  };
}
