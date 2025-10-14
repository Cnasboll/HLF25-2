import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

class Image extends Amendable<Image> {
  Image({this.url});

  Image.from(Image other) : this(url: other.url);

  Image copyWith(String? url) {
    return Image(url: url ?? this.url);
  }

  factory Image.amendWith(
    Image original,
    Map<String, dynamic>? amendment,
  ) {
    return Image(
      url: _urlField.getNullableStringFromJsonForAmendment(original, amendment),
    );
  }

  static Image fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Image();
    }
    return Image(url: _urlField.getNullableStringFromJson(json));
  }

  factory Image.fromRow(Row row) {
    return Image(url: _urlField.getNullableStringFromRow(row));
  }

  final String? url;

  @override
  Image amendWith(Map<String, dynamic>? amendment) {
    return Image.amendWith(this, amendment);
  }

  static Image fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return Image();
    }
    if (json.length != staticFields.length) {
      return Image();
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
