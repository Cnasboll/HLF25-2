
import 'package:v03/managers/hero_data_managing.dart';
import 'package:v03/models/appearance_model.dart';
import 'package:v03/models/biography_model.dart';
import 'package:v03/models/hero_model.dart';
import 'package:v03/persistence/hero_repository.dart';

class HeroDataManager implements HeroDataManaging {

  HeroDataManager(HeroRepository repository)
    : _repository = repository,
      _heroesByServerId = repository.heroes.asMap().map(
        (key, value) => MapEntry(value.serverId, value),
      );

  @override
  void persist(HeroModel hero) {
    _heroesByServerId[hero.serverId] = hero;
    _repository.persist(hero);
  }

  @override
  void delete(HeroModel hero) {
    _heroesByServerId.remove(hero.serverId);
    _repository.delete(hero);
  }


  @override
  void clean() {
    _heroesByServerId.clear();
    _repository.clean();
  }

  @override
  List<HeroModel> query(String query) {
    var result = _heroesByServerId.values
        .where(
          (hero) => hero.matches(query.toLowerCase()),
        )
        .toList();

    result.sort();
    return result;
  }

  @override
  HeroModel? getByServerId(String serverId)
  {
    return _heroesByServerId[serverId];
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
    var snapshot = _heroesByServerId.values.toList();
    snapshot.sort();
    return snapshot;
  }

  final Map<String, HeroModel> _heroesByServerId;

  final HeroRepository _repository;
}
