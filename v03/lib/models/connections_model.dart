import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

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

  factory ConnectionsModel.amendWith(
    ConnectionsModel original,
    Map<String, dynamic>? amendment,
  ) {
    return ConnectionsModel(
      groupAffiliation: _groupAffiliationField
          .getNullableStringFromJsonForAmendment(original, amendment),
      relatives: _relativesField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
    );
  }

  static ConnectionsModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ConnectionsModel();
    }
    return ConnectionsModel(
      groupAffiliation: _groupAffiliationField.getNullableStringFromJson(json),
      relatives: _relativesField.getNullableStringFromJson(json),
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

  @override
  ConnectionsModel amendWith(Map<String, dynamic>? amendment) {
    return ConnectionsModel.amendWith(this, amendment);
  }

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
  List<query<ConnectionsModel>> get fields => staticFields;

  static query<ConnectionsModel> get _groupAffiliationField => query<ConnectionsModel>(
    (p) => p?.groupAffiliation,
    String,
    'group-affiliation',
    'Groups the character is affiliated with wether currently or in the past and if addmittedly or not',
  );

  static final query<ConnectionsModel> _relativesField = query<ConnectionsModel>(
    (p) => p?.relatives,
    String,
    'relatives',
    'A list of the character\'s relatives by blood, marriage, adoption, or pure association',
  );

  static final List<query<ConnectionsModel>> staticFields = [
    _groupAffiliationField,
    _relativesField,
  ];
}
