import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';
import 'package:v03/amendable/field_base.dart';

class ImageModel extends Amendable<ImageModel> {
  ImageModel({this.url});

  ImageModel.from(ImageModel other) : this(url: other.url);

  ImageModel copyWith(String? url) {
    return ImageModel(url: url ?? this.url);
  }

  @override
  ImageModel amendWith(Map<String, dynamic>? amendment) {
    return ImageModel(
      url: _urlField.getNullableStringForAmendment(this, amendment),
    );
  }

  static ImageModel fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ImageModel();
    }
    return ImageModel(url: _urlField.getNullableString(json));
  }

  factory ImageModel.fromRow(Row row) {
    return ImageModel(url: _urlField.getNullableStringFromRow(row));
  }

  final String? url;

  static ImageModel fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return ImageModel();
    }
    if (json.length != staticFields.length) {
      return ImageModel();
    }

    return ImageModel.fromJson(json);
  }

  @override
  List<FieldBase<ImageModel>> get fields => staticFields;

  static FieldBase<ImageModel> get _urlField => Field.infer(
    (p) => p.url,
    'Url',
    'The URL of the image',
    sqliteName: 'image_url',
  );

  static final List<FieldBase<ImageModel>> staticFields = [_urlField];
}
