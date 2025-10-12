import 'package:equatable/equatable.dart';
import 'package:v03/prompts/prompt.dart';
import 'package:v03/updateable/field.dart';
import 'dart:io';

abstract class Updateable<T extends Updateable<T>> extends Equatable
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
    Map<String, dynamic> values = {};
    for (var field in fields) {
      if (!field.mutable || field.assignedBySystem) {
        continue;
      }
      print("Enter ${field.name} (${field.description}) or enter to abort:");
      var input = (stdin.readLineSync() ?? "").trim();
      if (input.isEmpty) {
        return null;
      }
      values[field.jsonName] = input;
    }
    return values;
  }

  Map<String, dynamic> promptForAmendmentJson() {
    Map<String, dynamic> amendment = {};
    for (var field in fields) {
      var current = field.format(this as T);
      if (!field.mutable || field.assignedBySystem) {
        continue;
      }

      print(
        "Enter ${field.name} (${field.description}) or enter to keep current value ($current):",
      );
      var input = (stdin.readLineSync() ?? "").trim();
      if (input.isEmpty) {
        amendment[field.jsonName] = current;
      } else {
        amendment[field.jsonName] = input;
      }
    }
    return amendment;
  }

  /// Returns true if this can be updated to other and all immutable fields remain unchanged
  bool validateUpdate(T other) {
    for (var field in fields) {
      if (!field.validateAmendment(this as T, other)) {
        return false;
      }
    }
    return true;
  }

  String formatUpdate(T other) {
    StringBuffer sb = StringBuffer();

    for (var field in fields) {
      var update = field.formatAmendment(this as T, other);
      if (update == null) {
        continue;
      }
      sb.writeln(update);
    }
    return sb.toString();
  }

  String sideBySide(T other) {
    var diff = formatUpdate(other);
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
      sb.writeln("${field.name}: ${field.format(this as T)}");
    }
    sb.write('''=============
''');
    return sb.toString();
  }

  T fromJsonAmendment(Map<String, dynamic>? amendment);

  T? promptForUpdated() {
    var updatedHero = fromJsonAmendment(promptForAmendmentJson());

    if (this == updatedHero) {
      print("No changes made");
      return null;
    }

    if (promptForYesNo(
          '''Save the following changes?${sideBySide(updatedHero)}''',
        ) ==
        YesNo.no) {
      return null;
    }

    return updatedHero;
  }
}
