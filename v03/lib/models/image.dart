import 'dart:core';

import 'package:sqlite3/sqlite3.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class Image extends Updateable<Image> {
  Image({required this.url});

  factory Image.fromJsonUpdate(Image original, Map<String, dynamic> amendment) {
    return Image(url: _urlField.getStringForUpdate(original, amendment));
  }

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(url: _urlField.getString(json));
  }

  factory Image.fromRow(Row row) {
    return Image(
      url: row['image_url'] as String,
    );
  }

  final String url;

  @override
  Image fromJsonUpdate(Map<String, dynamic> amendment) {
    return Image.fromJsonUpdate(this, amendment);
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

  static Field<Image> get _urlField =>
      Field<Image>((p) => p.url, 'url', 'The URL of the image');

  static final List<Field<Image>> staticFields = [_urlField];
}
