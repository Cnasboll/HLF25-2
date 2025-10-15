import 'dart:convert';
import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

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

class BiographyModel extends Amendable<BiographyModel> {
  BiographyModel({
    this.fullName,
    this.alterEgos,
    this.aliases,
    this.placeOfBirth,
    this.firstAppearance,
    this.publisher,
    this.alignment,
  });

  BiographyModel.from(BiographyModel other)
    : this(
        fullName: other.fullName,
        alterEgos: other.alterEgos,
        aliases: other.aliases == null
            ? null
            : List<String>.from(other.aliases ?? []),
        placeOfBirth: other.placeOfBirth,
        firstAppearance: other.firstAppearance,
        publisher: other.publisher,
        alignment: other.alignment,
      );

  BiographyModel copyWith({
    String? fullName,
    String? alterEgos,
    List<String>? aliases,
    String? placeOfBirth,
    String? firstAppearance,
    String? publisher,
    Alignment? alignment,
  }) {
    return BiographyModel(
      fullName: fullName ?? this.fullName,
      alterEgos: alterEgos ?? this.alterEgos,
      aliases: aliases ?? List<String>.from(this.aliases ?? []),
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      firstAppearance: firstAppearance ?? this.firstAppearance,
      publisher: publisher ?? this.publisher,
      alignment: alignment ?? this.alignment,
    );
  }

  factory BiographyModel.amendWith(
    BiographyModel original,
    Map<String, dynamic>? amendment,
  ) {
    return BiographyModel(
      fullName: _fullNameField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      alterEgos: _alterEgosField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      aliases: _aliasesField.getNullableStringListFromJsonForAmendment(
        original,
        amendment,
      ),
      placeOfBirth: _placeOfBirthFIeld.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      firstAppearance: _firstAppearanceField
          .getNullableStringFromJsonForAmendment(original, amendment),
      publisher: _publisherField.getNullableStringFromJsonForAmendment(
        original,
        amendment,
      ),
      alignment: _alignmentField.getEnumForAmendment<Alignment>(
        original,
        Alignment.values,
        amendment,
      ),
    );
  }

  static BiographyModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BiographyModel();
    }
    return BiographyModel(
      fullName: _fullNameField.getNullableStringFromJson(json),
      alterEgos: _alterEgosField.getNullableStringFromJson(json),
      aliases: _aliasesField.getNullableStringListFromJson(json),
      placeOfBirth: _placeOfBirthFIeld.getNullableStringFromJson(json),
      firstAppearance: _firstAppearanceField.getNullableStringFromJson(json),
      publisher: _publisherField.getNullableStringFromJson(json),
      alignment: _alignmentField.getEnumFromJson<Alignment>(
        Alignment.values,
        json,
        Alignment.unknown,
      ),
    );
  }

  factory BiographyModel.fromRow(Row row) {
    return BiographyModel(
      fullName: _fullNameField.getNullableStringFromRow(row),
      alterEgos: _alterEgosField.getNullableStringFromRow(row),
      aliases: _aliasesField.getNullableStringListFromRow(row),
      placeOfBirth: _placeOfBirthFIeld.getNullableStringFromRow(row),
      firstAppearance: _firstAppearanceField.getNullableStringFromRow(row),
      publisher: _publisherField.getNullableStringFromRow(row),
      alignment: _alignmentField.getEnumFromRow<Alignment>(
        Alignment.values,
        row,
        Alignment.unknown,
      ),
    );
  }

  final String? fullName;
  final String? alterEgos;
  final List<String>? aliases;
  final String? placeOfBirth;
  final String? firstAppearance;
  final String? publisher;
  final Alignment? alignment;

  @override
  BiographyModel amendWith(Map<String, dynamic>? amendment) {
    return BiographyModel.amendWith(this, amendment);
  }

  static BiographyModel fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return BiographyModel();
    }
    if (json.length != staticFields.length) {
      return BiographyModel();
    }

    return BiographyModel.fromJson(json);
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<BiographyModel>> get fields => staticFields;

  static Field<BiographyModel> get _fullNameField =>
      Field<BiographyModel>((p) => p?.fullName, String, 'full-name', 'Full');

  static final Field<BiographyModel> _alterEgosField = Field<BiographyModel>(
    (p) => p?.alterEgos,
    String,
    'alter-egos',
    'Such as Jekyll and Hyde',
  );

  static final Field<BiographyModel> _aliasesField = Field<BiographyModel>(
    (p) => p?.aliases,
    List<String>,
    'aliases',
    'Other names the character is known by',
    // This is a list of strings, so we need special handling as I cann't be arsed to make another table for it
    // but putting JSON in column is an anti-pattern. Will I be condemned to purgatory? 
    // Will the database deities show mercy?
    sqliteGetter: ((p) => jsonEncode(p?.aliases)),
    prompt: ' as a single value (\'Insider\') without surrounding \' or a list in json format e.g. ["Insider", "Matches Malone"]',
  );

  static final Field<BiographyModel> _placeOfBirthFIeld = Field<BiographyModel>(
    (p) => p?.placeOfBirth,
    String,
    'place-of-birth',
    'Where the character was born',
  );

  static final Field<BiographyModel> _firstAppearanceField = Field<BiographyModel>(
    (p) => p?.firstAppearance,
    String,
    'first-appearance',
    'When the character first appeared in print or in court',
  );

  static final Field<BiographyModel> _publisherField = Field<BiographyModel>(
    (p) => p?.publisher,
    String,
    'publisher',
    'The publisher of the character\'s stories or documentary evidence',
  );

  static final Field<BiographyModel> _alignmentField = Field<BiographyModel>(
    (h) => h?.alignment ?? Alignment.unknown,
    Alignment,
    "alignment",
    Alignment.values.map((e) => e.name).join(', '),
    format: (h) => (h?.alignment ?? Alignment.unknown).name,
    sqliteGetter:(h) => (h?.alignment ?? Alignment.unknown).name,
    nullable: false,
  );

  static final List<Field<BiographyModel>> staticFields = [
    _fullNameField,
    _alterEgosField,
    _aliasesField,
    _placeOfBirthFIeld,
    _firstAppearanceField,
    _publisherField,
    _alignmentField,
  ];
}
