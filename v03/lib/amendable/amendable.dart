import 'package:equatable/equatable.dart';
import 'package:v03/prompts/prompt.dart';
import 'package:v03/amendable/field_base.dart';
abstract class Amendable<T extends Amendable<T>> extends Equatable
    implements Comparable<T> {
  List<FieldBase<T>> get fields;

  @override
  List<Object?> get props => fields.map((f) => f.getter(this as T)).toList();

  List<Object?> sqliteProps() =>
      fields.expand((f) => f.sqliteProps(this as T)).toList();

  @override
  int compareTo(T other) {
    final a = fields;
    final b = other.fields;
    for (int i = 0; i < a.length && i < b.length; ++i) {
      final int cmp = fields[i].compareField(this as T, other);
      if (cmp != 0) {
        return cmp;
      }
    }

    // If all shared fields were equal, shorter list is considered smaller (consdering objects as bit string)
    if (a.length != b.length) {
      return a.length.compareTo(b.length);
    }
    return 0;
  }

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

  bool diff(T other, StringBuffer sb) {
    bool hasDifferences = false;
    for (var field in fields) {
      hasDifferences |= field.diff(this as T, other, sb);
    }
    return hasDifferences;
  }

  bool matches(String query) {
    var lower = query.toLowerCase();
    for (var field in fields) {
      if (field.matches(this as T, lower)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln('''

=============''');
    for (var field in fields) {
      field.formatField(this as T, sb);
    }
    sb.write('''=============
''');
    return sb.toString();
  }

  T fromChildJsonAmendment(FieldBase field, Map<String, dynamic>? amendment) {
    return amendWith(field.getJson(amendment));
  }

  T amendWith(Map<String, dynamic>? amendment);

  T? promptForAmendment() {
    var amendedObject = amendWith(promptForAmendmentJson());

    var sb = StringBuffer();
    if (!diff(amendedObject, sb)) {
      print("No amendments made");
      return null;
    }

    if (!promptForYesNo(
      '''Save the following amendments?

=============
${sb.toString()}=============
''',
    )) {
      return null;
    }

    return amendedObject;
  }
}
