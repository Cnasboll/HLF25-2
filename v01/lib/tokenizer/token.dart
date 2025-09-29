enum Symbols {
  none,
  //Operators:
  not,
  mul,
  div,
  mod,
  add,
  sub,
  lt,
  ltEq,
  gt,
  gtEq,
  eq,
  neq,
  and,
  or,
  xor,
  unaryPlus,
  unaryMinus,
  identifier,
  integerLiteral,
  floatLiteral,
}

enum LiteralTypes { none, integerLiteral, floatLiteral }

enum TokenTypes {
  mul,
  div,
  mod,
  add,
  sub,
  lt,
  ltEq,
  eq,
  neq,
  gt,
  gtEq,
  integerLiteral,
  floatLiteral,
  lPar,
  rPar,
  // Identifiers (built in functions)
  identifier,
  comma,
}

enum Keywords { none, notKeyword, andKeyword, orKeyword, xorKeyword }

class Token {
  String get lexeme {
    return _lexeme;
  }

  TokenTypes get tokenType {
    return _tokenType;
  }

  Keywords get keyword {
    return _keyword;
  }

  LiteralTypes get literalType {
    return _literalType;
  }

  int get operatorPrecedence {
    return _operatorPrecedence;
  }

  Symbols get symbol {
    return _symbol;
  }

  Token(
    this._lexeme,
    this._tokenType,
    this._keyword,
    this._literalType,
    this._operatorPrecedence,
    this._symbol,
  );

  factory Token.parser(TokenTypes tokenType, String lexeme) {
    Keywords keyword = Keywords.none;
    LiteralTypes literalType = LiteralTypes.none;
    int operatorPrecedence = -1;
    Symbols symbol = Symbols.none;

    switch (tokenType) {
      case TokenTypes.identifier:
        {
          keyword = _keywords[lexeme] ?? Keywords.none;
        }
        break;
      case TokenTypes.integerLiteral:
        literalType = LiteralTypes.integerLiteral;
        break;
      case TokenTypes.floatLiteral:
        literalType = LiteralTypes.floatLiteral;
        break;
      default:
        break;
    }
    var operatorSymbol = _boolOpTable[keyword] ?? _symbolTable[tokenType];
    if (operatorSymbol != null) {
      symbol = operatorSymbol;
      operatorPrecedence = _operatorPrecendences[symbol]!;
    }
    return Token(
      lexeme,
      tokenType,
      keyword,
      literalType,
      operatorPrecedence,
      symbol,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          _lexeme == other._lexeme &&
          _tokenType == other._tokenType;

  @override
  int get hashCode => Object.hash(_lexeme, _tokenType);

  String categorizeIdentifier() {
    if (isKeyword()) {
      return "Keyword $_lexeme";
    }

    if (isIdentifier()) {
      return "Identifer $_lexeme";
    }

    return "";
  }

  @override
  String toString() {
    var s = _tokenType == TokenTypes.identifier
        ? " ($categorizeIdentifier())"
        : "";
    return '$_tokenType "$_lexeme"$s';
  }

  bool isKeyword() {
    return _keyword != Keywords.none;
  }

  bool isIdentifier() {
    return _tokenType == TokenTypes.identifier && !isKeyword();
  }

  bool takesPrecedence(Token rhs) {
    return operatorPrecedence < rhs.operatorPrecedence;
  }

  bool isOperator() {
    return _operatorPrecedence >= 0;
  }

  static Map<String, Keywords> getKeywords() {
    return {
      "NOT": Keywords.notKeyword,
      "AND": Keywords.andKeyword,
      "OR": Keywords.orKeyword,
      "XOR": Keywords.xorKeyword,
    };
  }

  static Map<Symbols, int> getOperatorPrecendences() {
    var precedence = 0;
    return {
      // Not
      Symbols.not: precedence++,

      // Multiplication, division and remainder
      Symbols.mul: precedence,
      Symbols.div: precedence,
      Symbols.mod: precedence++,

      // Addition and subtraction
      Symbols.add: precedence,
      Symbols.sub: precedence++,

      // Relational operators
      Symbols.lt: precedence,
      Symbols.ltEq: precedence,
      Symbols.gt: precedence,
      Symbols.gtEq: precedence++,

      // Equalities
      Symbols.eq: precedence,
      Symbols.neq: precedence++,

      // Conjunctions
      Symbols.and: precedence++,

      // Disjunctions
      Symbols.or: precedence,
      Symbols.xor: precedence++,
    };
  }

  static Map<TokenTypes, Symbols> getSymbolTable() {
    return {
      TokenTypes.mul: Symbols.mul,
      TokenTypes.div: Symbols.div,
      TokenTypes.mod: Symbols.mod,
      TokenTypes.add: Symbols.add,
      TokenTypes.sub: Symbols.sub,
      TokenTypes.lt: Symbols.lt,
      TokenTypes.ltEq: Symbols.ltEq,
      TokenTypes.eq: Symbols.eq,
      TokenTypes.neq: Symbols.neq,
      TokenTypes.gt: Symbols.gt,
      TokenTypes.gtEq: Symbols.gtEq,
    };
  }

  static Map<Keywords, Symbols> getBoolOpTable() {
    return {
      Keywords.notKeyword: Symbols.not,
      Keywords.andKeyword: Symbols.and,
      Keywords.orKeyword: Symbols.or,
      Keywords.xorKeyword: Symbols.xor,
    };
  }

  final String _lexeme;
  final TokenTypes _tokenType;
  static final Map<String, Keywords> _keywords = getKeywords();
  static final Map<Symbols, int> _operatorPrecendences =
      getOperatorPrecendences();
  static final Map<TokenTypes, Symbols> _symbolTable = getSymbolTable();
  static final Map<Keywords, Symbols> _boolOpTable = getBoolOpTable();
  final Keywords _keyword;
  final LiteralTypes _literalType;
  final int _operatorPrecedence;
  final Symbols _symbol;
}
