
class ConstantsTable<T> {
  int include(T value) {
    var index = _index[value];

    if (index == null) {
      index = _index[value] = _constants.length;
      _constants.add(value);
    }
    return index;
  }

  List<T> get constants {
    return _constants;
  }

  final List<T> _constants = [];
  final Map<T, int> _index = {};
}

class ConstantsSet {
  ConstantsTable<int> get integers {
    return _integers;
  }

  ConstantsTable<double> get doubles {
    return _doubles;
  }

  ConstantsTable<String> get strings {
    return _strings;
  }

  ConstantsTable<String> get identifiers {
    return _identifiers;
  }

  final ConstantsTable<int> _integers = ConstantsTable();
  final ConstantsTable<double> _doubles = ConstantsTable();
  final ConstantsTable<String> _strings = ConstantsTable();
  final ConstantsTable<String> _identifiers = ConstantsTable();
}
