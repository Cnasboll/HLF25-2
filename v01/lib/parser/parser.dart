import 'package:v01/parser/constants_set.dart';
import 'package:v01/parser/parse_tree.dart';
import 'package:v01/parser/lookahead_iterator.dart';
import 'package:v01/tokenizer/token.dart';

class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

class Parser {
  static ParseTree parse(
    LookaheadIterator<Token> tokenEnumerator,
    ConstantsSet constantsSet,
  ) {
    var operandStack = <ParseTree>[];
    var operatorStack = <Token>[];

    do {
      if (!tokenEnumerator.hasNext) {
        throw ParseException(
          "Unexpected End of token stream while expecting operand.",
        );
      }
      tokenEnumerator.next();

      operandStack.add(parseOperand(tokenEnumerator, constantsSet));
      if (tryConsumeOperator(tokenEnumerator)) {
        while (operatorStack.isNotEmpty &&
            !tokenEnumerator.current.takesPrecedence(operatorStack.last)) {
          popOperatorStack(tokenEnumerator, operandStack, operatorStack);
        }
        operatorStack.add(tokenEnumerator.current);
      } else {
        // No more operators.
        while (operatorStack.isNotEmpty) {
          popOperatorStack(tokenEnumerator, operandStack, operatorStack);
        }
      }
    } while (operatorStack.isNotEmpty || operandStack.length > 1);

    return operandStack.removeLast();
  }

  static void popOperatorStack(
    LookaheadIterator<Token> tokenEnumerator,
    List<ParseTree> operandStack,
    List<Token> operatorStack,
  ) {
    Token operatorToken = operatorStack.removeLast();
    if (operandStack.length < 2) {
      var unexpectedLexeme = tokenEnumerator.peek().lexeme;
      var operatorLexeme = operatorStack.last.lexeme;
      throw ParseException(
        'Unexpected token "$unexpectedLexeme" when expecting operand for binary operator "$operatorLexeme".',
      );
    }
    var rhs = operandStack.removeLast();
    var lhs = operandStack.removeLast();
    operandStack.add(ParseTree(operatorToken.symbol, [lhs, rhs]));
  }

  static bool tryConsumeOperator(LookaheadIterator<Token> tokenEnumerator) {
    // TODO: If we find a left parenthesis here, consider this a multiplication!

    if (tokenEnumerator.hasNext && tokenEnumerator.peek().isOperator()) {
      tokenEnumerator.next();
      return true;
    }
    return false;
  }

  static ParseTree parseOperand(
    LookaheadIterator<Token> tokenEnumerator,
    ConstantsSet constantsSet, [
    bool allowSign = true,
  ]) {
    // If we find a plus or minus sign here, consider that a sign for the operand, then we recurse
    if (tokenEnumerator.current.tokenType == TokenTypes.add) {
      tokenEnumerator.next();
      return ParseTree.withChildren(Symbols.unaryPlus, [
        parseOperand(tokenEnumerator, constantsSet, false),
      ]);
    }

    if (tokenEnumerator.current.tokenType == TokenTypes.sub) {
      tokenEnumerator.next();
      return ParseTree.withChildren(Symbols.unaryMinus, [
        parseOperand(tokenEnumerator, constantsSet, false),
      ]);
    }

    if (tokenEnumerator.current.keyword == Keywords.notKeyword) {
      tokenEnumerator.next();
      return ParseTree.withChildren(Symbols.not, [
        parseOperand(tokenEnumerator, constantsSet),
      ]);
    }

    // If we find a left parenthesis, we recurse as that is the highest precedence
    if (tokenEnumerator.current.tokenType == TokenTypes.lPar) {
      var parseTree = parse(tokenEnumerator, constantsSet);
      consume(tokenEnumerator, TokenTypes.rPar, ")");
      return parseTree;
    }

    if (tokenEnumerator.current.tokenType == TokenTypes.identifier) {
      String identifierName = tokenEnumerator.current.lexeme;
      return ParseTree(
        Symbols.identifier,
        parseArgumentList(tokenEnumerator, constantsSet, identifierName),
        constantsSet.identifiers.include(identifierName),
      );
    }

    String currentLexeme = tokenEnumerator.current.lexeme;

    switch (tokenEnumerator.current.literalType) {
      case LiteralTypes.integerLiteral:
        return ParseTree.withQualifier(
          Symbols.integerLiteral,
          constantsSet.integers.include(
            int.parse(tokenEnumerator.current.lexeme),
          ),
        );
      case LiteralTypes.floatLiteral:
        return ParseTree.withQualifier(
          Symbols.floatLiteral,
          constantsSet.doubles.include(
            double.parse(tokenEnumerator.current.lexeme),
          ),
        );
      default:
    }

    throw ParseException(
      'Unexpected token "$currentLexeme" when expecting operand.',
    );
  }

  static List<ParseTree> parseArgumentList(
    LookaheadIterator<Token> tokenEnumerator,
    ConstantsSet constantsSet,
    String identifierName,
  ) {
    List<ParseTree> arguments = [];

    if (tokenEnumerator.hasNext &&
        tokenEnumerator.peek().tokenType == TokenTypes.lPar) {
      // Consume the parenthsis
      tokenEnumerator.next();
      // Proceed to next token
      if (tokenEnumerator.peek().tokenType == TokenTypes.rPar) {
        // Empty argument list
        // Consume the parenthsis
        tokenEnumerator.next();
        return arguments;
      }
      for (;;) {
        arguments.add(parse(tokenEnumerator, constantsSet));

        if (!tokenEnumerator.hasNext) {
          throw ParseException(
            "End of stream when consuming arguments for call to function $identifierName()",
          );
        }

        tokenEnumerator.next();

        if (tokenEnumerator.current.tokenType == TokenTypes.rPar) {
          break;
        }

        if (tokenEnumerator.current.tokenType != TokenTypes.comma) {
          var n = arguments.length;
          throw ParseException(
            "Expected comma or right parenthesis following $n:th argument for call to function $identifierName()",
          );
        }
      }
    }
    return arguments;
  }

  static void consume(
    LookaheadIterator<Token> tokenEnumerator,
    TokenTypes expectedType,
    String expectedLexeme,
  ) {
    if (!tokenEnumerator.hasNext) {
      throw ParseException(
        "End of token stream when expecting '$expectedType'",
      );
    }
    var token = tokenEnumerator.next();
    if (token.tokenType != expectedType) {
      var actualLexeme = token.lexeme;
      throw ParseException(
        "Found token '$actualLexeme' when expecting '$expectedLexeme'",
      );
    }
  }
}
