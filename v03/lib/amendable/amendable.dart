import 'package:equatable/equatable.dart';
import 'package:v03/prompts/prompt.dart';
import 'package:v03/amendable/field.dart';

abstract class Amendable<T extends Amendable<T>> extends Equatable
    implements Comparable<T> {
  List<Field<T>> get fields;

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

  static Map<String, dynamic>? promptForJson(List<Field> fields) {
    Map<String, dynamic> json = {};
    for (var field in fields) {
      if (!field.mutable || field.assignedBySystem) {
        continue;
      }
      if (!field.promptForJson(json)) {
        return null;
      }
    }
    return json;
  }

  Map<String, dynamic> promptForAmendmentJson() {
    Map<String, dynamic> amendment = {};
    for (var field in fields) {
      if (!field.mutable || field.assignedBySystem) {
        continue;
      }
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

  String formatAmendment(T other) {
    StringBuffer sb = StringBuffer();

    for (var field in fields) {
      var amendment = field.formatAmendment(this as T, other);
      if (amendment == null) {
        continue;
      }
      sb.writeln(amendment);
    }
    return sb.toString();
  }

  String sideBySide(T other) {
    var diff = formatAmendment(other);
    if (diff.isNotEmpty) {
      return '''

=============
$diff=============
  ''';
    }
    return '<No differences>';
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

  T fromChildJsonAmendment(Field field, Map<String, dynamic>? amendment) {
    return amendWith(field.getJsonFromJson(amendment));
  }

  T amendWith(Map<String, dynamic>? amendment);

  T? promptForAmendment() {
    var amendedObject = amendWith(promptForAmendmentJson());

    if (this == amendedObject) {
      print("No amendments made");
      return null;
    }

    if (!promptForYesNo(
      '''Save the following amendments?${sideBySide(amendedObject)}''',
    )) {
      return null;
    }

    return amendedObject;
  }
}
