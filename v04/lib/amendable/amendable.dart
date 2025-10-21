import 'package:v04/amendable/field_provider.dart';
import 'package:v04/amendable/parsing_context.dart';
import 'package:v04/prompts/prompt.dart';
import 'package:v04/amendable/field_base.dart';

abstract class Amendable<T extends Amendable<T>> extends FieldProvider<T>
    implements Comparable<T> {
  static Map<String, dynamic>? promptForJson<T>(List<FieldBase<T>> fields) {
    Map<String, dynamic> json = {};
    for (var field in fields) {
      if (!field.promptForJson(json)) {
        return null;
      }
    }
    return json;
  }

  Map<String, dynamic> promptForAmendmentJson() {
    Map<String, dynamic> amendment = {};
    for (var field in fields) {
      field.promptForAmendmentJson(this as T, amendment);
    }
    return amendment;
  }

  /// Returns true if this can be amended to other and all immutable fields remain unchanged
  bool validateAmendment(T other) {
    for (var field in fields) {
      if (!field.validateAmendment(this as T, other)) {
        return false;
      }
    }
    return true;
  }

  T fromChildJsonAmendment(FieldBase field, Map<String, dynamic>? amendment, {ParsingContext? parsingContext}) {
    return amendWith(field.getJson(amendment), parsingContext: parsingContext);
  }

  T amendWith(Map<String, dynamic>? amendment, {ParsingContext? parsingContext});

  T? promptForAmendment() {
    var amendedObject = amendWith(promptForAmendmentJson());

    var sb = StringBuffer();
    if (!diff(amendedObject, sb)) {
      print("No amendments made");
      return null;
    }

    if (!promptForYesNo('''Save the following amendments?

=============
${sb.toString()}=============
''')) {
      return null;
    }

    return amendedObject;
  }
}
