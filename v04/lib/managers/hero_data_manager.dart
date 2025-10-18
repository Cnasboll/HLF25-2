
import 'package:v04/managers/hero_data_managing.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/persistence/hero_repository.dart';

class HeroDataManager implements HeroDataManaging {

  HeroDataManager(HeroRepository repository)
    : _repository = repository,
      _heroesByExternalId = repository.heroes.asMap().map(
        (key, value) => MapEntry(value.externalId, value),
      );

  @override
  void persist(HeroModel hero) {
    _heroesByExternalId[hero.externalId] = hero;
    _repository.persist(hero);
  }

  @override
  void delete(HeroModel hero) {
    _heroesByExternalId.remove(hero.externalId);
    _repository.delete(hero);
  }


  @override
  void clear() {
    _heroesByExternalId.clear();
    _repository.clear();
  }

  @override
  List<HeroModel> query(String query) {
    var result = _heroesByExternalId.values
        .where(
          (hero) => hero.matches(query.toLowerCase()),
        )
        .toList();

    result.sort();
    return result;
  }

  @override
  HeroModel? getByExternalId(String externalId)
  {
    return _heroesByExternalId[externalId];
  }

  @override
  HeroModel? getById(String id)
  {
    return _repository.heroesById[id];
  }

  @override
  Future<Null> dispose() async {
    await _repository.dispose();    
  }

  @override
  List<HeroModel> get heroes 
  {
    var snapshot = _repository.heroes;
    snapshot.sort();
    return snapshot;
  }

  final Map<String, HeroModel> _heroesByExternalId;

  final HeroRepository _repository;
}
