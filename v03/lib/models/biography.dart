import 'dart:convert';
import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

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
    this.fullName,
    this.alterEgos,
    this.aliases,
    this.placeOfBirth,
    this.firstAppearance,
    this.publisher,
    this.alignment,
  });

  Biography.from(Biography other)
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

  Biography copyWith({
    String? fullName,
    String? alterEgos,
    List<String>? aliases,
    String? placeOfBirth,
    String? firstAppearance,
    String? publisher,
    Alignment? alignment,
  }) {
    return Biography(
      fullName: fullName ?? this.fullName,
      alterEgos: alterEgos ?? this.alterEgos,
      aliases: aliases ?? List<String>.from(this.aliases ?? []),
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      firstAppearance: firstAppearance ?? this.firstAppearance,
      publisher: publisher ?? this.publisher,
      alignment: alignment ?? this.alignment,
    );
  }

  factory Biography.fromJsonAmendment(
    Biography original,
    Map<String, dynamic>? amendment,
  ) {
    return Biography(
      fullName: _publisherField.getNullableStringFromJsonForAmendment(
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

  static Biography fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Biography();
    }
    return Biography(
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

  factory Biography.fromRow(Row row) {
    return Biography(
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

  static Biography amendOrCreate(
    Field field,
    Biography? original,
    Map<String, dynamic>? amendment,
  ) {
    if (original == null) {
      return Biography.fromJson(field.getJsonFromJson(amendment));
    }
    return original.fromJsonAmendment(field.getJsonFromJson(amendment));
  }

  @override
  Biography fromJsonAmendment(Map<String, dynamic>? amendment) {
    return Biography.fromJsonAmendment(this, amendment);
  }

  static Biography fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return Biography();
    }
    if (json.length != staticFields.length) {
      return Biography();
    }

    return Biography.fromJson(json);
  }

  /// Subclasses may override to contribute additional fields.
  @override
  List<Field<Biography>> get fields => staticFields;

  static Field<Biography> get _fullNameField =>
      Field<Biography>((p) => p?.fullName, String, 'full-name', 'Full');

  static final Field<Biography> _alterEgosField = Field<Biography>(
    (p) => p?.alterEgos,
    String,
    'alter-egos',
    'Such as Jekyll and Hyde',
  );

  static final Field<Biography> _aliasesField = Field<Biography>(
    (p) => p?.aliases,
    List<String>,
    'aliases',
    'Other names the character is known by',
    // This is a list of strings, so we need special handling as I cann't be arsed to make another table for it
    //but putting JSON in column is an anti-pattern. I pray to the SQL gods for forgiveness. /O.I
    sqliteGetter: ((p) => jsonEncode(p?.aliases)),
  );

  static final Field<Biography> _placeOfBirthFIeld = Field<Biography>(
    (p) => p?.placeOfBirth,
    String,
    'place-of-birth',
    'Where the character was born',
  );

  static final Field<Biography> _firstAppearanceField = Field<Biography>(
    (p) => p?.firstAppearance,
    String,
    'first-appearance',
    'When the character first appeared in print or in court',
  );

  static final Field<Biography> _publisherField = Field<Biography>(
    (p) => p?.publisher,
    String,
    'publisher',
    'The publisher of the character\'s stories or documentary evidence',
  );

  static final Field<Biography> _alignmentField = Field<Biography>(
    (h) => h?.alignment ?? Alignment.unknown,
    Alignment,
    "alignment",
    Alignment.values.map((e) => e.name).join(', '),
    format: (h) => (h?.alignment ?? Alignment.unknown).name,
    sqliteGetter:(h) => (h?.alignment ?? Alignment.unknown).name,
    nullable: false,
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
