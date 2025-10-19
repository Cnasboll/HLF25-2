import 'package:sqlite3/sqlite3.dart';
import 'package:v04/jobs/job_queue.dart';
import 'package:v04/models/hero_model.dart';
import 'package:v04/persistence/hero_repositing.dart';

class HeroRepository implements HeroRepositing {
  HeroRepository.cache(this._db, this._cache);

  factory HeroRepository(String path) {
    final (db, heroes) = initDb(path);
    return HeroRepository.cache(db, heroes);
  }

  static (Database, Map<String, HeroModel>) initDb(String path) {
    var db = sqlite3.open(path);
    createTableIfNotExists(db);
    var snapshot = readSnapshot(db);
    return (db, snapshot);
  }

  static void createTableIfNotExists(Database db) {
    db.execute('''
CREATE TABLE IF NOT EXISTS heroes (
${HeroModel.generateSqliteColumnDeclarations('    ')}
)''');
  }

  static Map<String, HeroModel> readSnapshot(Database db) {
    var snapshot = <String, HeroModel>{};
    for (var row in db.select('SELECT * FROM heroes')) {
      var hero = HeroModel.fromRow(row);
      snapshot[hero.id] = hero;
    }
    return snapshot;
  }

  @override
  void persist(HeroModel hero) {
    _cache[hero.id] = hero;
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

  @override
  void delete(HeroModel hero) {
    _cache.remove(hero.id);
    _jobQueue.enqueue(() => dbDelete(hero));
  }

  void dbDelete(HeroModel hero) {
    _db.execute('DELETE FROM heroes WHERE id = ?', [hero.id]);
  }

  @override
  void clear() {
    _cache.clear();
    _jobQueue.enqueue(() => dbClean());
  }

  void dbClean() {
    _db.execute('DELETE FROM heroes');
  }

  // TODO: can I make a proper dispose pattern here?
  @override
  Future<Null> dispose() async {
    await _jobQueue.close();
    await _jobQueue.join();
    _db.dispose();
    _cache.clear();
  }

  final JobQueue _jobQueue = JobQueue();
  Map<String, HeroModel> _cache = {};

  Database _db;

  @override
  List<HeroModel> get heroes {
    var snapshot = _cache.values.toList();
    return snapshot;
  }

  @override
  Map<String, HeroModel> get heroesById => Map.unmodifiable(_cache);
}
