import 'dart:convert';
import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v04/amendable/field.dart';
import 'package:v04/amendable/amendable.dart';
import 'package:v04/amendable/field_base.dart';
import 'package:v04/amendable/parsing_context.dart';

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
    this.alignment = Alignment.unknown,
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

  @override
  BiographyModel amendWith(Map<String, dynamic>? amendment, {ParsingContext? parsingContext}) {
    return BiographyModel(
      fullName: _fullNameField.getNullableStringForAmendment(this, amendment),
      alterEgos: _alterEgosField.getNullableStringForAmendment(this, amendment),
      aliases: _aliasesField.getNullableStringListFromJsonForAmendment(
        this,
        amendment,
      ),
      placeOfBirth: _placeOfBirthField.getNullableStringForAmendment(
        this,
        amendment,
      ),
      firstAppearance: _firstAppearanceField.getNullableStringForAmendment(
        this,
        amendment,
      ),
      publisher: _publisherField.getNullableStringForAmendment(this, amendment),
      alignment: _alignmentField.getEnumForAmendment<Alignment>(
        this,
        Alignment.values,
        amendment,
      ),
    );
  }

  static BiographyModel fromJson(Map<String, dynamic>? json, {ParsingContext? parsingContext}) {
    if (json == null) {
      return BiographyModel();
    }
    return BiographyModel(
      fullName: _fullNameField.getNullableString(json),
      alterEgos: _alterEgosField.getNullableString(json),
      aliases: _aliasesField.getNullableStringList(json),
      placeOfBirth: _placeOfBirthField.getNullableString(json),
      firstAppearance: _firstAppearanceField.getNullableString(json),
      publisher: _publisherField.getNullableString(json),
      alignment: _alignmentField.getEnum<Alignment>(
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
      placeOfBirth: _placeOfBirthField.getNullableStringFromRow(row),
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
  final Alignment alignment;

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
  List<FieldBase<BiographyModel>> get fields => staticFields;

  static FieldBase<BiographyModel> get _fullNameField => Field.infer(
    (m) => m.fullName,
    "Full Name",
    "Also applies when hungry"
  );

  /// Special string literal used in the API to indicate no alter egos exist -- treat as null.
  /// Do not use as an actual alter ego, as villains may exploit this loophole to evade detection systems!
  static const String noAlterEgosFound = "No alter egos found.";

  static final FieldBase<BiographyModel> _alterEgosField = Field.infer(
    (m) => m.alterEgos,
    "Alter Egos",
    "Alter egos of the character",
    extraNullLiterals: [noAlterEgosFound]
  );

  static final FieldBase<BiographyModel> _aliasesField = Field.infer(
    (m) => m.aliases,
    "Aliases",
    "Other names the character is known by",
    // This is a list of strings, so we need special handling as I cann't be arsed to make another table for it
    // but putting JSON in column is an anti-pattern. Will I be condemned to purgatory?
    // Will the database deities show mercy?
    sqliteGetter: ((m) => m.aliases == null ? null : jsonEncode(m.aliases)),
    prompt:
        ' as a single value (\'Insider\') without surrounding \' or a list in json format e.g. ["Insider", "Matches Malone"]',
  );

  static final FieldBase<BiographyModel> _placeOfBirthField = Field.infer(
    (m) => m.placeOfBirth,
    "Place of Birth",
    "Where the character was born",
  );

  static final FieldBase<BiographyModel> _firstAppearanceField = Field.infer(
    (m) => m.firstAppearance,
    "First Appearance",
    "When the character first appeared in print or in court",
  );

  static final FieldBase<BiographyModel> _publisherField = Field.infer(
    (m) => m.publisher,
    "Publisher",
    "The publisher of the character's stories or documentary evidence",
  );

  static final FieldBase<BiographyModel> _alignmentField = Field.infer(
    (m) => m.alignment,
    "Alignment",
    "The character's moral alignment (${Alignment.values.map((e) => e.name).join(', ')})",
    format: (m) => m.alignment.name,
    sqliteGetter: (m) => m.alignment.name,
    nullable: false,
  );

  static final List<FieldBase<BiographyModel>> staticFields = [
    _fullNameField,
    _alterEgosField,
    _aliasesField,
    _placeOfBirthField,
    _firstAppearanceField,
    _publisherField,
    _alignmentField,
  ];
}
