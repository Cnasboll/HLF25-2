import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class Connections extends Updateable<Connections> {
  Connections({
    required this.groupAffiliation,
    required this.relatives,
  });

  factory Connections.fromJsonUpdate(
    Connections original,
    Map<String, dynamic> amendment,
  ) {
    return Connections(
      groupAffiliation: _groupAffiliationField.getStringForUpdate(original, amendment),
      relatives: _relativesField.getStringForUpdate(original, amendment),      
    );
  }

  factory Connections.fromJson(Map<String, dynamic> json) {
    return Connections(
      groupAffiliation: _groupAffiliationField.getString(json),
      relatives: _relativesField.getString(json),
    );
  }

  factory Connections.fromRow(Row row) {
    return Connections(
      groupAffiliation: row['group_affiliation'] as String,
      relatives: row['relatives'] as String,
    );
  }
  
  final String groupAffiliation;
  final String relatives;
  

  @override
  Connections fromJsonUpdate(Map<String, dynamic> amendment) {
    return Connections.fromJsonUpdate(this, amendment);
  }

  static Connections? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return Connections.fromJson(json);
  }


  @override
  List<Field<Connections>> get fields => staticFields;

  static Field<Connections> get _groupAffiliationField => Field<Connections>(
    (p) => p.groupAffiliation,
    'group-affiliation',
    'Groups the character is affiliated with wether currently or in the past and if addmittedly or not',
  );

  static final Field<Connections> _relativesField = Field<Connections>(
    (p) => p.relatives,
    'relatives',
    'A list of the character\'s relatives by blood, marriage, adoption, or pure association',
  );

  static final List<Field<Connections>> staticFields = [
    _groupAffiliationField,
    _relativesField,
  ];

}
