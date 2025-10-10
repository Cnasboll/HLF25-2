import 'package:sqlite3/sqlite3.dart';
import 'package:v03/jobs/job_queue.dart';
import 'package:v03/models/hero.dart';
import 'package:v03/utils/enum_parsing.dart';

class HeroRepository {

  HeroRepository.cache(this._db, this._cache, this._heroesByServerId);

  factory HeroRepository(String path) {
    final (db, heroes, heroesByServerId) = initDb(path);
    return HeroRepository.cache(db, heroes, heroesByServerId);
  }

  static (Database, Map<String, Hero>, Map<int, Hero>) initDb(path) {
    var db = sqlite3.open(path);
    createTableIfNotExists(db);
    var (snapshot, heroesByServerId) = readSnapshot(db);
    return (db, snapshot, heroesByServerId);
  }

  static void createTableIfNotExists(Database db) {
    db.execute('''
CREATE TABLE IF NOT EXISTS heroes (
  id TEXT PRIMARY KEY,
  version INTEGER NOT NULL,
  server_id INTEGER NOT NULL,
	name TEXT NOT NULL,
	strength INTEGER NOT NULL,
	gender TEXT NOT NULL,
	race TEXT NOT NULL,
	alignment TEXT NULL
)''');
  }

  static (Map<String, Hero>, Map<int, Hero>) readSnapshot(Database db) {
    var snapshot = <String, Hero>{};
    var heroesByServerId = <int, Hero>{};

    for (var row in db.select('SELECT * FROM heroes')) {
      var hero = Hero(
        version: row['version'] as int,
        id: row['id'] as String,
        serverId: row['server_id'] as int,
        name: row['name'] as String,
        strength: row['strength'] as int,
        gender:
            Gender.values.tryParse(row['gender'] as String) ?? Gender.unknown,
        race: row['race'] as String,
        alignment:
            Alignment.values.tryParse(row['alignment'] as String) ??
            Alignment.unknown,
      );
      snapshot[hero.id] = hero;
      heroesByServerId[hero.serverId] = hero;
    }
    return (snapshot, heroesByServerId);
  }

  void persist(Hero hero) {
    _cache[hero.id] = hero;    
    _heroesByServerId[hero.serverId] = hero;
    // Persist a copy to avoid race conditions (technically not needed for inserts but I want to keep the code nice and clean)
    _jobQueue.enqueue(() => dbPersist(Hero.copy(hero)));
  }

  void dbPersist(Hero hero) {
    _db.execute(
      '''INSERT INTO heroes (id, version, server_id, name, strength, gender, race, alignment) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
ON CONFLICT (id) DO
UPDATE
SET version=excluded.version,
    server_id=excluded.server_id,
    name=excluded.name,
    strength=excluded.strength,
    gender=excluded.gender,
    race=excluded.race,
    alignment=excluded.alignment
      ''',
        [
          hero.id,
          hero.version,
          hero.serverId,
          hero.name,
          hero.strength,
          hero.gender.name,
          hero.race,
          hero.alignment.name
        ]);
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
              (hero.id.toLowerCase().contains(lower) ||
              (hero.serverId.toString().contains(lower)) ||
              hero.name.toLowerCase().contains(lower) ||
              hero.gender.toString().contains(lower) ||
              hero.strength.toString().contains(lower) ||
              hero.alignment.toString().contains(lower)),
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
  Map<int, Hero> _heroesByServerId = {};

  Database _db;

  List<Hero> get heroes 
  {
    var snapshot = _cache.values.toList();
    snapshot.sort();
    return snapshot;
  }

  Map<String, Hero> get heroesById => Map.unmodifiable(_cache);
}
