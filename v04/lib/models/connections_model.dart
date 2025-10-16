import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v04/amendable/field.dart';
import 'package:v04/amendable/amendable.dart';
import 'package:v04/amendable/field_base.dart';

class ConnectionsModel extends Amendable<ConnectionsModel> {
  ConnectionsModel({this.groupAffiliation, this.relatives});

  ConnectionsModel.from(ConnectionsModel other)
    : this(
        groupAffiliation: other.groupAffiliation,
        relatives: other.relatives,
      );

  ConnectionsModel copyWith({String? groupAffiliation, String? relatives}) {
    return ConnectionsModel(
      groupAffiliation: groupAffiliation ?? this.groupAffiliation,
      relatives: relatives ?? this.relatives,
    );
  }

  @override
  ConnectionsModel amendWith(Map<String, dynamic>? amendment) {
    return ConnectionsModel(
      groupAffiliation: _groupAffiliationField.getNullableStringForAmendment(
        this,
        amendment,
      ),
      relatives: _relativesField.getNullableStringForAmendment(this, amendment),
    );
  }

  static ConnectionsModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ConnectionsModel();
    }
    return ConnectionsModel(
      groupAffiliation: _groupAffiliationField.getNullableString(json),
      relatives: _relativesField.getNullableString(json),
    );
  }

  factory ConnectionsModel.fromRow(Row row) {
    return ConnectionsModel(
      groupAffiliation: _groupAffiliationField.getNullableStringFromRow(row),
      relatives: _relativesField.getNullableStringFromRow(row),
    );
  }

  final String? groupAffiliation;
  final String? relatives;

  static ConnectionsModel fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return ConnectionsModel();
    }
    if (json.length != staticFields.length) {
      return ConnectionsModel();
    }

    return ConnectionsModel.fromJson(json);
  }

  @override
  List<FieldBase<ConnectionsModel>> get fields => staticFields;

  static FieldBase<ConnectionsModel> get _groupAffiliationField => Field.infer(
    (m) => m.groupAffiliation,
    'Group Affiliation',
    'Groups the character is affiliated with wether currently or in the past and if addmittedly or not',
  );

  static final FieldBase<ConnectionsModel> _relativesField = Field.infer(
    (m) => m.relatives,
    'Relatives',
    'A list of the character\'s relatives by blood, marriage, adoption, or pure association',
  );

  static final List<FieldBase<ConnectionsModel>> staticFields = [
    _groupAffiliationField,
    _relativesField,
  ];
}
