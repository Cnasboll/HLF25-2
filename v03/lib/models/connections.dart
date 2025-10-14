import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

class Connections extends Amendable<Connections> {
  Connections({this.groupAffiliation, this.relatives});

  Connections.from(Connections other)
    : this(
        groupAffiliation: other.groupAffiliation,
        relatives: other.relatives,
      );

  Connections copyWith({String? groupAffiliation, String? relatives}) {
    return Connections(
      groupAffiliation: groupAffiliation ?? this.groupAffiliation,
      relatives: relatives ?? this.relatives,
    );
  }

  factory Connections.amendWith(
    Connections original,
    Map<String, dynamic>? amendment,
  ) {
    return Connections(
      groupAffiliation: _groupAffiliationField
          .getNullableStringFromJsonForAmendment(original, amendment),
      relatives: _relativesField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
    );
  }

  static Connections fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Connections();
    }
    return Connections(
      groupAffiliation: _groupAffiliationField.getNullableStringFromJson(json),
      relatives: _relativesField.getNullableStringFromJson(json),
    );
  }

  factory Connections.fromRow(Row row) {
    return Connections(
      groupAffiliation: _groupAffiliationField.getNullableStringFromRow(row),
      relatives: _relativesField.getNullableStringFromRow(row),
    );
  }

  final String? groupAffiliation;
  final String? relatives;

  @override
  Connections amendWith(Map<String, dynamic>? amendment) {
    return Connections.amendWith(this, amendment);
  }

  static Connections fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return Connections();
    }
    if (json.length != staticFields.length) {
      return Connections();
    }

    return Connections.fromJson(json);
  }

  @override
  List<Field<Connections>> get fields => staticFields;

  static Field<Connections> get _groupAffiliationField => Field<Connections>(
    (p) => p?.groupAffiliation,
    String,
    'group-affiliation',
    'Groups the character is affiliated with wether currently or in the past and if addmittedly or not',
  );

  static final Field<Connections> _relativesField = Field<Connections>(
    (p) => p?.relatives,
    String,
    'relatives',
    'A list of the character\'s relatives by blood, marriage, adoption, or pure association',
  );

  static final List<Field<Connections>> staticFields = [
    _groupAffiliationField,
    _relativesField,
  ];
}
