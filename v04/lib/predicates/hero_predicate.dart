import 'package:v04/models/appearance_model.dart';
import 'package:v04/models/biography_model.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/shql/engine/engine.dart';
import 'package:v04/shql/parser/constants_set.dart';
import 'package:v04/shql/parser/lookahead_iterator.dart';
import 'package:v04/shql/parser/parse_tree.dart';
import 'package:v04/shql/parser/parser.dart';
import 'package:v04/shql/tokenizer/tokenizer.dart';
import 'package:v04/value_types/value_type.dart';

class HeroPredicate {
  HeroPredicate.parse(String shqlExpression)
    : _parseTree = _tryParse(shqlExpression),
      query = shqlExpression;

  static ParseTree? _tryParse(String shqlExpression) {
    ParseTree? parseTree;
    try {
      var v = Tokenizer.tokenize(shqlExpression).toList();
      var tokenEnumerator = v.lookahead();
      parseTree = Parser.parse(tokenEnumerator, _constantsSet);
      // ignore: empty_catches
    } catch (e) {}
    if (parseTree == null || parseTree.children.isEmpty) {
      print("Using plain text search for query: $shqlExpression");
      return null;
    }
    print("Using SHQL™ search for query: $shqlExpression");
    return parseTree;
  }

  // This is a placeholder for the actual implementation of HeroPredicate.
  bool evaluate(HeroModel hero) {
    if (_parseTree == null || _parseTree.children.isEmpty) {
      // If parsing failed, we fall back to string matching against all fields
      return hero.matches(query);
    }

    ConstantsSet heroScope = _constantsSet.createChild();
    // Load the hero identifiers into the scope
    hero.registerIdentifiers(heroScope);

    try {
      var result = Engine.evaluate(_parseTree, heroScope);
      if (result is bool) {
        return result;
      } else if (result is num) {
        return result != 0;
      } else {
        return false;
      }
    } catch (e) {
      print('Error evaluating SHQL™ expression for hero with externalId: "${hero.externalId}" and name: "${hero.name}": $e');
      return false;    
    }
  }

  static ConstantsSet createConstantsSet() {
    ConstantsSet constantsSet = Engine.prepareConstantsSet();
    constantsSet.registerEnum<Alignment>(Alignment.values);
    constantsSet.registerEnum<Gender>(Gender.values);
    constantsSet.registerEnum<SystemOfUnits>(SystemOfUnits.values);
    HeroModel.declareIdentifiers(constantsSet);
    return constantsSet;
  }

  static final ConstantsSet _constantsSet = createConstantsSet();
  final ParseTree? _parseTree;
  final String query;
}
