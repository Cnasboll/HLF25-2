import 'dart:convert';

List<String>? getNullableStringListFromMap(Map<String, dynamic>? map, String key) {
    var list = map?[key];
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

    if (list is !List) {
      // Not a list, return as single-item list
      return [list.toString()];
    }
    
    return List<String>.from(list);
  }