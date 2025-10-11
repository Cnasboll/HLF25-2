import 'package:sqlite3/sqlite3.dart';
import 'package:v03/jobs/job_queue.dart';
import 'package:v03/models/hero.dart';
import 'package:v03/models/power_stats.dart';
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
  intelligence INTEGER NOT NULL,
	strength INTEGER NOT NULL,
  speed INTEGER NOT NULL,
  durability INTEGER NOT NULL,
  power INTEGER NOT NULL,
  combat INTEGER NOT NULL,
  full_name TEXT NULL,
  alter_egos TEXT NULL,
  aliases TEXT NULL,
  place_of_birth TEXT NULL,
  first_appearance TEXT NULL,
  publisher TEXT NULL,
  alignment TEXT NULL
	gender TEXT NOT NULL,
	race TEXT NOT NULL,
  height_cm INTEGER NULL,
  weight_kg INTEGER NULL,
  eye_color TEXT NULL,
  hair_color TEXT NULL,
  eye_color TEXT NULL,
  occupation TEXT NULL,
  base TEXT NULL,
  group_affiliation TEXT NULL,
  relatives TEXT NULL,
  image_url TEXT NULL
)''');
  }

  static (Map<String, Hero>, Map<int, Hero>) readSnapshot(Database db) {
    var snapshot = <String, Hero>{};
    var heroesByServerId = <int, Hero>{};

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
    _jobQueue.enqueue(() => dbPersist(Hero.copy(hero)));
  }

  void dbPersist(Hero hero) {
    _db.execute(
      '''INSERT INTO heroes (
      id,
      version,
      server_id,
      name,
      intelligence,
      strength,
      speed,
      durability,
      power,
      combat,
      full_name,
      alter_egos,
      aliases,
      place_of_birth,
      first_appearance,
      publisher,
      alignment,
      gender,
      race,
      height_cm,
      weight_kg,
      eye_color,
      hair_color,
      occupation,
      base,
      group_affiliation,
      relatives,
      image_url
) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
ON CONFLICT (id) DO
UPDATE
SET version=excluded.version,
    server_id=excluded.server_id,
    name=excluded.name,
    intelligence=excluded.intelligence,
    strength=excluded.strength,
    speed=excluded.speed,
    durability=excluded.durability,
    power=excluded.power,
    combat=excluded.combat,
    full_name=excluded.full_name,
    alter_egos=excluded.alter_egos,
    aliases=excluded.aliases,
    place_of_birth=excluded.place_of_birth,
    first_appearance=excluded.first_appearance,
    publisher=excluded.publisher,
    gender=excluded.gender,
    race=excluded.race,
    height_cm=excluded.height_cm,
    weight_kg=excluded.weight_kg,
    eye_color=excluded.eye_color,
    hair_color=excluded.hair_color,
    occupation=excluded.occupation,
    base=excluded.base,
    group_affiliation=excluded.group_affiliation,
    relatives=excluded.relatives,
    image_url=excluded.image_url
      ''',
        [
          hero.id,
          hero.version,
          hero.serverId,
          hero.name,
          hero.powerStats.intelligence,
          hero.powerStats.strength,
          hero.powerStats.speed,
          hero.powerStats.durability,
          hero.powerStats.power,
          hero.powerStats.combat,
          hero.biography.fullName,
          hero.biography.alterEgos,
          hero.biography.aliases.join(', '),
          hero.biography.placeOfBirth,
          hero.biography.firstAppearance,
          hero.biography.publisher,
          hero.biography.alignment.name,
          hero.appearance.gender.name,
          hero.appearance.race,
          hero.appearance.height.cm,
          hero.appearance.weight.kg,
          hero.appearance.eyeColor,
          hero.appearance.hairColor,
          hero.work.occupation,
          hero.work.base,
          hero.connections.groupAffiliation,
          hero.connections.relatives,
          hero.image.url
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
              hero.appearance.gender.toString().contains(lower) ||
              hero.powerStats.strength.toString().contains(lower) ||
              hero.biography.alignment.toString().contains(lower)),
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
