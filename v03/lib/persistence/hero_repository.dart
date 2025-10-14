
import 'package:sqlite3/sqlite3.dart';
import 'package:v03/jobs/job_queue.dart';
import 'package:v03/models/appearance.dart';
import 'package:v03/models/biography.dart';
import 'package:v03/models/hero.dart';

class HeroRepository {

  HeroRepository.cache(this._db, this._cache, this._heroesByServerId);

  factory HeroRepository(String path) {
    final (db, heroes, heroesByServerId) = initDb(path);
    return HeroRepository.cache(db, heroes, heroesByServerId);
  }

  static (Database, Map<String, Hero>, Map<String, Hero>) initDb(path) {
    var db = sqlite3.open(path);
    createTableIfNotExists(db);
    var (snapshot, heroesByServerId) = readSnapshot(db);
    return (db, snapshot, heroesByServerId);
  }

  static void createTableIfNotExists(Database db) {
    db.execute('''
CREATE TABLE IF NOT EXISTS heroes (
${Hero.generateSqliteColumnDeclarations('    ')}
)''');
  }

  static (Map<String, Hero>, Map<String, Hero>) readSnapshot(Database db) {
    var snapshot = <String, Hero>{};
    var heroesByServerId = <String, Hero>{};

    for (var row in db.select('SELECT * FROM heroes')) {
      var hero = Hero.fromRow(row);
      snapshot[hero.id] = hero;
      heroesByServerId[hero.serverId] = hero;
    }
    return (snapshot, heroesByServerId);
  }

  void persist(Hero hero) {
    _cache[hero.id] = hero;    
    _heroesByServerId[hero.serverId] = hero;
    // Persist a copy to avoid race conditions (technically not needed for inserts but I want to keep the code nice and clean)
    _jobQueue.enqueue(() => dbPersist(Hero.from(hero)));
  }

  void dbPersist(Hero hero) {
    var parameters = hero.sqliteProps().toList();
    _db.execute('''INSERT INTO heroes (
${Hero.generateSqliteColumnNameList('      ')}
) VALUES (${Hero.generateSQLiteInsertColumnPlaceholders()})
ON CONFLICT (id) DO
UPDATE
SET ${Hero.generateSqliteUpdateClause('    ')}
      ''', parameters);
  }

  void delete(Hero hero) {
    _cache.remove(hero.id);
    _heroesByServerId.remove(hero.serverId);
    _jobQueue.enqueue(() => dbDelete(hero));
  }

  void dbDelete(Hero hero) {
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

  List<Hero> query(String query) {
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
  Map<String, Hero> _cache = {};
  Map<String, Hero> _heroesByServerId = {};

  Database _db;

  List<Hero> get heroes 
  {
    var snapshot = _cache.values.toList();
    snapshot.sort();
    return snapshot;
  }

  Map<String, Hero> get heroesById => Map.unmodifiable(_cache);
}
