class ConstantsTable<T> {
    ConstantsTable({ConstantsTable<T>? parent}) : _parent = parent;

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
      if (_parent != null) {
        return _parent.getByIdentifier(identifier);
      }
      return null;
    }
    return _constants[index];
  }

  List<T> get constants {
    return _constants;
  }

  ConstantsTable<T>? root() {
    if (_parent == null) {
      return this;
    }
  
    return _parent.root();
  }

  final List<T> _constants = [];
  final Map<T, int> _index = {};
  final Map<int, int> _indexByIdentifier = {};
  final ConstantsTable<T>? _parent;
}

class ConstantsSet {
  ConstantsSet() : _constants = ConstantsTable(), _identifiers = ConstantsTable();
  
  ConstantsSet._child(ConstantsSet parent)
    : _constants = ConstantsTable(parent: parent._constants),
      _identifiers = parent._identifiers;

  ConstantsSet._subModel(ConstantsSet parent)
    : _constants = ConstantsTable(parent: parent._constants.root()),
      _identifiers = parent._identifiers;

  ConstantsTable<dynamic> get constants {
    return _constants;
  }

  ConstantsTable<String> get identifiers {
    return _identifiers;
  }

  ConstantsSet createChild() {
    return ConstantsSet._child(this);
  }

  ConstantsSet createSubModelScope(String identifier) {
    final identifierIndex = identifiers.include(identifier);
    final scope = ConstantsSet._subModel(this);
    _subModelScopes[identifierIndex] = scope;
    return scope;
  }

  ConstantsSet? getSubModelScope(int identifierIndex) {
    return _subModelScopes[identifierIndex];
  }

  void registerEnum<T extends Enum>(Iterable<T> values) {
    for (var value in values) {
      constants.register(
        value.index,
        identifiers.include(value.name.toUpperCase()),
      );
    }
  }

  final ConstantsTable<dynamic> _constants;
  final ConstantsTable<String> _identifiers;
  final Map<int, ConstantsSet> _subModelScopes = {};
}
