import 'package:v04/amendable/field_provider.dart';
import 'package:v04/amendable/parsing_context.dart';
import 'package:v04/terminal/prompt.dart';
import 'package:v04/amendable/field_base.dart';
import 'package:v04/terminal/terminal.dart';

abstract class Amendable<T extends Amendable<T>> extends FieldProvider<T>
    implements Comparable<T> {
  static Future<Map<String, dynamic>?> promptForJson<T>(List<FieldBase<T>> fields) async {
    Map<String, dynamic> json = {};
    for (var field in fields) {
      if (!await field.promptForJson(json)) {
        return null;
      }
    }
    return json;
  }

  Future<Map<String, dynamic>> promptForAmendmentJson() async {
    Map<String, dynamic> amendment = {};
    for (var field in fields) {
      await field.promptForAmendmentJson(this as T, amendment);
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

  Future<T> fromChildJsonAmendment(FieldBase field, Map<String, dynamic>? amendment, {ParsingContext? parsingContext}) async {
    return amendWith(field.getJson(amendment), parsingContext: parsingContext);
  }

  Future<T> amendWith(Map<String, dynamic>? amendment, {ParsingContext? parsingContext});

  Future<T?> promptForAmendment() async {
    var amendedObject = await amendWith(await promptForAmendmentJson());

    var sb = StringBuffer();
    if (!diff(amendedObject, sb)) {
      Terminal.println("No amendments made");
      return null;
    }

    if (!(await promptForYesNo('''Save the following amendments?

=============
${sb.toString()}=============
'''))) {
      return null;
    }

    return amendedObject;
  }
}
