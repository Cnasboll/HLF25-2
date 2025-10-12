import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class Image extends Updateable<Image> {
  Image({required this.url});

  Image.from(Image other) : this(url: other.url);

  Image copyWith(String? url) {
    return Image(url: url ?? this.url);
  }

  factory Image.fromJsonAmendment(
    Image original,
    Map<String, dynamic>? amendment,
  ) {
    return Image(
      url: _urlField.getNullableStringFromJsonForAmendment(original, amendment),
    );
  }

  static Image? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return Image(url: _urlField.getNullableStringFromJson(json));
  }

  factory Image.fromRow(Row row) {
    return Image(url: _urlField.getNullableStringFromRow(row));
  }

  final String? url;

  static Image? amendOrCreate(
    Field field,
    Image? original,
    Map<String, dynamic>? amendment,
  ) {
    if (original == null) {
      return Image.fromJson(field.getJsonFromJson(amendment));
    }
    return original.fromJsonAmendment(field.getJsonFromJson(amendment));
  }

  @override
  Image fromJsonAmendment(Map<String, dynamic>? amendment) {
    return Image.fromJsonAmendment(this, amendment);
  }

  static Image? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }
    if (json.length != staticFields.length) {
      return null;
    }

    return Image.fromJson(json);
  }

  @override
  List<Field<Image>> get fields => staticFields;

  static Field<Image> get _urlField => Field<Image>(
    (p) => p?.url,
    String,
    'url',
    'The URL of the image',
    sqlLiteName: 'image_url',
  );

  static final List<Field<Image>> staticFields = [_urlField];
}
