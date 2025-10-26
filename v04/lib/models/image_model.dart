import 'dart:core';

import 'package:dio/dio.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:v04/amendable/field.dart';
import 'package:v04/amendable/amendable.dart';
import 'package:v04/amendable/field_base.dart';
import 'package:v04/amendable/parsing_context.dart';
import 'package:ascii_art_converter/ascii_art_converter.dart';
import 'package:v04/terminal/terminal.dart';
import 'package:v04/utils/ascii_art.dart';

// ignore: must_be_immutable
class ImageModel extends Amendable<ImageModel> {
  ImageModel({this.url});

  ImageModel.from(ImageModel other) : this(url: other.url);

  ImageModel copyWith(String? url) {
    return ImageModel(url: url ?? this.url);
  }

  @override
  ImageModel amendWith(
    Map<String, dynamic>? amendment, {
    ParsingContext? parsingContext,
  }) {
    return ImageModel(
      url: _urlField.getNullableStringForAmendment(this, amendment),
    );
  }

  static ImageModel fromJson(
    Map<String, dynamic>? json, {
    ParsingContext? parsingContext,
  }) {
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
    shqlName: 'url',
    formatEx: (p) => showAsciiArt(p),
  );

  static final List<FieldBase<ImageModel>> staticFields = [_urlField];

  static String showAsciiArt(ImageModel p) {
    if (p._asciiArt.isEmpty) {
      var url = p.url;
      if (url == null) {
        return p._asciiArt;
      }
      Terminal.println("Fetching image from $url");
      final dio = Dio();
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Cache-Control': 'max-age=0'
      };
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;
      // Option 2: Add timeouts and retry logic
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 10);
      dio.options.sendTimeout = Duration(seconds: 10);
      
      dio.get(url, options: Options(responseType: ResponseType.bytes))
          .then((response) {
            Terminal.println("Processing image from $url to ASCI art");
            AsciiArtConverter(
              width: 100,
              charset: CharSet.standart,
              invert: true,
              colorMode: ColorMode.ansi256,
            ).convert(response.data).then((value) {
              p._asciiArt = value;
              Terminal.println(
                "Finished processing image from $url to ASCI art\n${p._asciiArt}",
              );
            });
          })
          // Option 1: Add error handling and fallback
          .catchError((error) {
            if (error is DioException) {
              if (error.response?.statusCode == 403) {                
                p._asciiArt = AsciiArt.createHeroPortrait(url);
                Terminal.println("Image blocked by server (403) - using placeholder\n${p._asciiArt}");
              } else if (error.response?.statusCode == 429) {
                Terminal.println("Rate limited - too many requests");
                p._asciiArt = "Rate limited - try again later";
              } else {
                Terminal.println("HTTP Error ${error.response?.statusCode}: ${error.message}");
                p._asciiArt = "HTTP Error ${error.response?.statusCode}";
              }
            } else {
              Terminal.println("Failed to fetch image: $error");
              p._asciiArt = "Network error - failed to load image";
            }
            Terminal.println("ASCII Art fallback complete for $url");
          });
    }
    return p._asciiArt;
  }

  String _asciiArt = '';
}
