import 'package:v01/tokenizer/token.dart';

enum ECharCodeClasses {
  letter,
  digit,
  whitespace,
  lPar,
  rPar,
  underscore,
  comma,
  dot,
  mulop,
  divOp,
  modOp,
  minusOp,
  plusOp,
  eq,
  lt,
  gt,
}

enum TokenizerState {
  start,
  identifier,
  number,
  float,
  lt,
  gt,
  acceptEq,
  acceptLPar,
  acceptRPar,
  acceptIdentifier,
  acceptDivOp,
  acceptModOp,
  acceptMulOp,
  acceptPlusOp,
  acceptMinusOp,
  numberDot,
  acceptNumber,
  acceptFloat,
  acceptCommaOp,
  acceptGt,
  acceptLt,
  acceptLtEq,
  acceptNeq,
  acceptGtEq,
}

// Apparently there is no built in Char type:
typedef Char = int;

bool isDigit(Char c) => c >= 0x30 && c <= 0x39; // '0'..'9'
bool isUpper(Char c) => c >= 0x41 && c <= 0x5A; // 'A'..'Z'
bool isLower(Char c) => c >= 0x61 && c <= 0x7A; // 'a'..'z'
bool isLetter(Char c) => isUpper(c) || isLower(c); // letter (A-Z,a-z)
bool isWhitespace(Char c) =>
    c == 0x20 /* space */ ||
    c == 0x09 /* tab  */ ||
    c == 0x0A /* \n   */ ||
    c == 0x0D /* \r   */;

class TokenizerException implements Exception {
  final String message;

  TokenizerException(this.message);

  @override
  String toString() => 'TokenizerException: $message';
}

class StateMachine {
  Iterable<Token> accept(Char charCode) sync* {
    var nextState = _transitionTable[(_state, categorize(charCode))];
    if (nextState != null) {
      _state = nextState;
      if (_state != TokenizerState.start) {
        _buffer.writeCharCode(charCode);
        var token = interpretAcceptState();
        if (token != null) {
          yield token;
        }
      }
    } else {
      var nextState = _defaultTransitionTable[_state];
      if (nextState != null) {
        _state = nextState;
        var token = interpretAcceptState();
        if (token != null) {
          yield token;
        }

        //Don't consume the char, run the char again.
        for (var t in accept(charCode)) {
          yield t;
        }
      } else {
        throw TokenizerException(
          "Unexpected char '$charCode' in state $_state",
        );
      }
    }
  }

  Iterable<Token> acceptEndOfStream() sync* {
    if (_state != TokenizerState.start) {
      var nextState = _defaultTransitionTable[_state];
      TokenizerState oldState = _state;
      if (nextState != null) {
        _state = nextState;
        var token = interpretAcceptState();
        if (token != null) {
          yield token;
        } else {
          throw TokenizerException(
            "Internal error: _defaultTransitionTable[{$oldState}] gave {$_state} but interpretAcceptState() returns null.",
          );
        }
      } else {
        throw TokenizerException("Unexpected end of stream in state {$_state}");
      }
    }
  }

  Token? interpretAcceptState() {
    var tokenType = _acceptStateTable[_state];
    if (tokenType != null) {
      var token = Token.parser(tokenType, _buffer.toString());
      _state = TokenizerState.start;
      _buffer = StringBuffer();
      return token;
    }
    return null;
  }

  static ECharCodeClasses categorize(Char charCode) {
    if (isLetter(charCode)) {
      return ECharCodeClasses.letter;
    }

    if (isDigit(charCode)) {
      return ECharCodeClasses.digit;
    }

    if (isWhitespace(charCode)) {
      return ECharCodeClasses.whitespace;
    }

    var characterString = String.fromCharCode(charCode);
    var characterCodeClass = _charCodeClassTable[characterString];
    if (characterCodeClass == null) {
      throw TokenizerException("Unexpected character '$characterString'");
    }
    return characterCodeClass;
  }

  static Map<String, ECharCodeClasses> createCharCodeClassTable() {
    return {
      '(': ECharCodeClasses.lPar,
      ')': ECharCodeClasses.rPar,
      '_': ECharCodeClasses.underscore,
      ',': ECharCodeClasses.comma,
      '.': ECharCodeClasses.dot,
      '*': ECharCodeClasses.mulop,
      '/': ECharCodeClasses.divOp,
      '%': ECharCodeClasses.modOp,
      '+': ECharCodeClasses.plusOp,
      '-': ECharCodeClasses.minusOp,
      '=': ECharCodeClasses.eq,
      '<': ECharCodeClasses.lt,
      '>': ECharCodeClasses.gt,
    };
  }

  static Map<(TokenizerState, ECharCodeClasses), TokenizerState>
  createTransitionTable() {
    return {
      (TokenizerState.start, ECharCodeClasses.letter):
          TokenizerState.identifier,
      (TokenizerState.start, ECharCodeClasses.underscore):
          TokenizerState.identifier,
      (TokenizerState.start, ECharCodeClasses.digit): TokenizerState.number,
      (TokenizerState.start, ECharCodeClasses.gt): TokenizerState.gt,
      (TokenizerState.start, ECharCodeClasses.lt): TokenizerState.lt,
      (TokenizerState.start, ECharCodeClasses.eq): TokenizerState.acceptEq,
      (TokenizerState.start, ECharCodeClasses.lPar): TokenizerState.acceptLPar,
      (TokenizerState.start, ECharCodeClasses.rPar): TokenizerState.acceptRPar,
      (TokenizerState.start, ECharCodeClasses.divOp):
          TokenizerState.acceptDivOp,
      (TokenizerState.start, ECharCodeClasses.modOp):
          TokenizerState.acceptModOp,
      (TokenizerState.start, ECharCodeClasses.mulop):
          TokenizerState.acceptMulOp,
      (TokenizerState.start, ECharCodeClasses.plusOp):
          TokenizerState.acceptPlusOp,
      (TokenizerState.start, ECharCodeClasses.minusOp):
          TokenizerState.acceptMinusOp,
      (TokenizerState.start, ECharCodeClasses.comma):
          TokenizerState.acceptCommaOp,
      (TokenizerState.start, ECharCodeClasses.whitespace): TokenizerState.start,
      (TokenizerState.identifier, ECharCodeClasses.letter):
          TokenizerState.identifier,
      (TokenizerState.identifier, ECharCodeClasses.underscore):
          TokenizerState.identifier,
      (TokenizerState.identifier, ECharCodeClasses.digit):
          TokenizerState.identifier,
      (TokenizerState.number, ECharCodeClasses.digit): TokenizerState.number,
      (TokenizerState.number, ECharCodeClasses.dot): TokenizerState.numberDot,
      (TokenizerState.numberDot, ECharCodeClasses.digit): TokenizerState.float,
      (TokenizerState.float, ECharCodeClasses.digit): TokenizerState.float,
      (TokenizerState.lt, ECharCodeClasses.eq): TokenizerState.acceptLtEq,
      (TokenizerState.lt, ECharCodeClasses.gt): TokenizerState.acceptNeq,
      (TokenizerState.gt, ECharCodeClasses.eq): TokenizerState.acceptGtEq,
    };
  }

  static Map<TokenizerState, TokenizerState> createDefaultTransitionTable() {
    return {
      TokenizerState.identifier: TokenizerState.acceptIdentifier,
      TokenizerState.number: TokenizerState.acceptNumber,
      TokenizerState.float: TokenizerState.acceptFloat,
      TokenizerState.gt: TokenizerState.acceptGt,
      TokenizerState.lt: TokenizerState.acceptLt,
    };
  }

  static Map<TokenizerState, TokenTypes> createAcceptStateTable() {
    return {
      TokenizerState.acceptCommaOp: TokenTypes.comma,
      TokenizerState.acceptDivOp: TokenTypes.div,
      TokenizerState.acceptModOp: TokenTypes.mod,
      TokenizerState.acceptEq: TokenTypes.eq,
      TokenizerState.acceptFloat: TokenTypes.floatLiteral,
      TokenizerState.acceptGt: TokenTypes.gt,
      TokenizerState.acceptGtEq: TokenTypes.gtEq,
      TokenizerState.acceptIdentifier: TokenTypes.identifier,
      TokenizerState.acceptLPar: TokenTypes.lPar,
      TokenizerState.acceptLt: TokenTypes.lt,
      TokenizerState.acceptLtEq: TokenTypes.ltEq,
      TokenizerState.acceptMinusOp: TokenTypes.sub,
      TokenizerState.acceptMulOp: TokenTypes.mul,
      TokenizerState.acceptNeq: TokenTypes.neq,
      TokenizerState.acceptNumber: TokenTypes.integerLiteral,
      TokenizerState.acceptPlusOp: TokenTypes.add,
      TokenizerState.acceptRPar: TokenTypes.rPar,
    };
  }

  TokenizerState _state = TokenizerState.start;
  StringBuffer _buffer = StringBuffer();

  static final Map<String, ECharCodeClasses> _charCodeClassTable =
      createCharCodeClassTable();

  static final Map<(TokenizerState, ECharCodeClasses), TokenizerState>
  _transitionTable = createTransitionTable();
  static final Map<TokenizerState, TokenizerState> _defaultTransitionTable =
      createDefaultTransitionTable();
  static final Map<TokenizerState, TokenTypes> _acceptStateTable =
      createAcceptStateTable();
}
