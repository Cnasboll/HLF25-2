
import 'package:sqlite3/sqlite3.dart';
import 'package:v03/jobs/job_queue.dart';
import 'package:v03/models/appearance_model.dart';
import 'package:v03/models/biography_model.dart';
import 'package:v03/models/hero_model.dart';

class HeroRepository {

  HeroRepository.cache(this._db, this._cache, this._heroesByServerId);

  factory HeroRepository(String path) {
    final (db, heroes, heroesByServerId) = initDb(path);
    return HeroRepository.cache(db, heroes, heroesByServerId);
  }

  static (Database, Map<String, HeroModel>, Map<String, HeroModel>) initDb(String path) {
    var db = sqlite3.open(path);
    createTableIfNotExists(db);
    var (snapshot, heroesByServerId) = readSnapshot(db);
    return (db, snapshot, heroesByServerId);
  }

  static void createTableIfNotExists(Database db) {
    db.execute('''
CREATE TABLE IF NOT EXISTS heroes (
${HeroModel.generateSqliteColumnDeclarations('    ')}
)''');
  }

  static (Map<String, HeroModel>, Map<String, HeroModel>) readSnapshot(Database db) {
    var snapshot = <String, HeroModel>{};
    var heroesByServerId = <String, HeroModel>{};

    for (var row in db.select('SELECT * FROM heroes')) {
      var hero = HeroModel.fromRow(row);
      snapshot[hero.id] = hero;
      heroesByServerId[hero.serverId] = hero;
    }
    return (snapshot, heroesByServerId);
  }

  void persist(HeroModel hero) {
    _cache[hero.id] = hero;    
    _heroesByServerId[hero.serverId] = hero;
    // Persist a copy to avoid race conditions (technically not needed for inserts but I want to keep the code nice and clean)
    _jobQueue.enqueue(() => dbPersist(HeroModel.from(hero)));
  }

  void dbPersist(HeroModel hero) {
    var parameters = hero.sqliteProps().toList();
    _db.execute('''INSERT INTO heroes (
${HeroModel.generateSqliteColumnNameList('      ')}
) VALUES (${HeroModel.generateSQLiteInsertColumnPlaceholders()})
ON CONFLICT (id) DO
UPDATE
SET ${HeroModel.generateSqliteUpdateClause('    ')}
      ''', parameters);
  }

  void delete(HeroModel hero) {
    _cache.remove(hero.id);
    _heroesByServerId.remove(hero.serverId);
    _jobQueue.enqueue(() => dbDelete(hero));
  }

  void dbDelete(HeroModel hero) {
    _db.execute('DELETE FROM heroes WHERE id = ?', [hero.id]);
  }

  void clean() {
    _cache.clear();
    _heroesByServerId.clear();
    _jobQueue.enqueue(() => dbClean());
  }

  void dbClean() {
    _db.execute('DELETE FROM heroes');
  }

  List<HeroModel> query(String query) {
    var lower = query.toLowerCase();
    var result = _cache.values
        .where(
          (hero) =>
              (hero.id.toLowerCase().contains(lower)) ||
              (hero.serverId.toString().contains(lower)) ||
              hero.name.toLowerCase().contains(lower) ||
              (hero.appearance.gender ?? Gender.unknown).name.contains(lower) ||
              (hero.powerStats.strength ?? 0).toString().contains(lower) ||
              (hero.biography.alignment ?? Alignment.unknown).name.contains(lower),
        )
        .toList();

    result.sort();
    return result;
  }

  // TODO: can I make a proper dispose pattern here?
  Future<Null> dispose() async {
    await _jobQueue.close();
    await _jobQueue.join();
    _db.dispose();
    _cache.clear();
    _heroesByServerId.clear();
  }

  final JobQueue _jobQueue = JobQueue();
  Map<String, HeroModel> _cache = {};
  Map<String, HeroModel> _heroesByServerId = {};

  Database _db;

  List<HeroModel> get heroes 
  {
    var snapshot = _cache.values.toList();
    snapshot.sort();
    return snapshot;
  }

  Map<String, HeroModel> get heroesById => Map.unmodifiable(_cache);
}
