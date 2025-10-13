import 'dart:convert';

List<String>? getNullableStringList(Map<String, dynamic>? json, String jsonName) {
    var list = json?[jsonName];
    if (list == null) {
      return null;
    }
    /// Special handler! if it is a json-encoded string, decode it
    if (list is String) {
      try {
        list = jsonDecode(list);
      } catch (e) {
        // Not JSON, return as single-item list
        return [list.toString()];
      }
    }
    if (list is String) {
      // Single string, return as single-item list
      return [list];
    }
    return List<String>.from(list);
  }