
class ConstantsTable<T> {
  int include(T value) {
    var index = _index[value];

    if (index == null) {
      index = _index[value] = _constants.length;
      _constants.add(value);
    }
    return index;
  }

  int register(T value, int identifier) {
    var index = _index[value];

    if (index == null) {
      index = _index[value] = _constants.length;
      _constants.add(value);
    }
    _indexByIdentifier[identifier] = index;
    return index;
  }

  T? getByIdentifier(int identifier) {
    var index = _indexByIdentifier[identifier];
    if (index == null) {
      return null;
    }
    return _constants[index];
  }

  List<T> get constants {
    return _constants;
  }

  final List<T> _constants = [];
  final Map<T, int> _index = {};
  final Map<int, int> _indexByIdentifier = { };
}

class ConstantsSet {
 /* ConstantsTable<int> get integers {
    return _integers;
  }

  ConstantsTable<double> get doubles {
    return _doubles;
  }

  ConstantsTable<String> get strings {
    return _strings;
  }*/

  ConstantsTable<dynamic> get constants {
    return _constants;
  }

  ConstantsTable<String> get identifiers {
    return _identifiers;
  }

  void registerEnum<T extends Enum>(Iterable<T> values) {
    for (var value in values) {
      constants.register(value.index, identifiers.include(value.name.toUpperCase()));
    }
  }

  final ConstantsTable<dynamic> _constants = ConstantsTable();
  /*final ConstantsTable<double> _doubles = ConstantsTable();
  final ConstantsTable<String> _strings = ConstantsTable();*/
  final ConstantsTable<String> _identifiers = ConstantsTable();
}
