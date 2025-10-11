import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';
import 'package:v03/utils/enum_parsing.dart';

// Levels of evilness
enum Alignment {
  unknown,
  neutral,
  mostlyGood,
  good,
  reasonable,
  notQuite,
  bad,
  ugly,
  evil,
  usingMobileSpeakerOnPublicTransport,
}

class Biography extends Updateable<Biography> {
  Biography({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
  });

  factory Biography.fromJsonUpdate(
    Biography original,
    Map<String, dynamic> amendment,
  ) {
    return Biography(
      fullName: _publisherField.getStringForUpdate(original, amendment),
      alterEgos: _alterEgosField.getStringForUpdate(original, amendment),
      aliases: _aliasesField.getStringListForUpdate(original, amendment),
      placeOfBirth: _placeOfBirthFIeld.getStringForUpdate(original, amendment),
      firstAppearance: _firstAppearanceField.getStringForUpdate(original, amendment),
      publisher: _publisherField.getStringForUpdate(original, amendment),
        alignment: _alignmentField.getEnumForUpdate<Alignment>(
        original,
        Alignment.values,
        amendment,
      ),
    );
  }

  factory Biography.fromJson(Map<String, dynamic> json) {
    return Biography(
      fullName: _publisherField.getString(json),
      alterEgos: _alterEgosField.getString(json),
      aliases: _aliasesField.getStringList(json),
      placeOfBirth: _placeOfBirthFIeld.getString(json),
      firstAppearance: _firstAppearanceField.getString(json),
      publisher: _publisherField.getString(json),
      alignment: _alignmentField.getEnum<Alignment>(Alignment.values, json, Alignment.unknown),
    );
  }

  factory Biography.fromRow(Row row) {
    return Biography(
      fullName: row['full_name'] as String,
      alterEgos: row['alter_egos'] as String,
      // TODO: Parse aliases properly (map to json array in DB)
      aliases: (row['aliases'] as String).split(','),
      placeOfBirth: row['place_of_birth'] as String,
      firstAppearance: row['first_appearance'] as String,
      publisher: row['publisher'] as String,
      alignment: Alignment.values.tryParse(row['alignment'] as String) ??
            Alignment.unknown,
    );
  }

  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher; 
  final Alignment alignment;

  @override
  Biography fromJsonUpdate(Map<String, dynamic> amendment) {
    return Biography.fromJsonUpdate(this, amendment);
  }

  static Biography? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return Biography.fromJson(json);
  }


  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<Biography>> get fields => staticFields;

  static Field<Biography> get _fullNameField => Field<Biography>(
    (p) => p.fullName,
    'full-name',
    'Full',
  );

  static final Field<Biography> _alterEgosField = Field<Biography>(
    (p) => p.alterEgos,
    'alter-egos',
    'Such as Jekyll and Hyde',
  );

  static final Field<Biography> _aliasesField = Field<Biography>(
    (p) => p.aliases,
    'aliases',
    'Other names the character is known by',
  );

  static final Field<Biography> _placeOfBirthFIeld = Field<Biography>(
    (p) => p.placeOfBirth,
    'place-of-birth',
    'Where the character was born',
  );

  static final Field<Biography> _firstAppearanceField = Field<Biography>(
    (p) => p.firstAppearance,
    'first-appearance',
    'When the character first appeared in print or in court',
  );

  static final Field<Biography> _publisherField = Field<Biography>(
    (p) => p.publisher,
    'publisher',
    'The publisher of the character\'s stories or documentary evidence',
  );

  static final Field<Biography> _alignmentField = Field<Biography>(
    (h) => h.alignment,
    "alignment",
    Alignment.values.map((e) => e.name).join(', '),
    format:(h) => h.alignment.name
  );

  static final List<Field<Biography>> staticFields = [
    _fullNameField,
    _alterEgosField,
    _aliasesField,
    _placeOfBirthFIeld,
    _firstAppearanceField,
    _publisherField,
    _alignmentField,
  ];
  
}
