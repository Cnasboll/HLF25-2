import 'package:test/test.dart';
import 'package:v03/models/hero.dart';

void main() {
  test('generate SQLite column names', () {
    final names = Hero.generateSqliteColumnNameList('      ');
    expect(names, '''
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
''');
  });

  test('generate SQLite column names', () {
    final declarations = Hero.generateSqliteColumnDeclarations('      ');
    print(declarations);
    expect(declarations, '''
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
  alignment TEXT NULL,
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
''');
  });

  test('generate SQLite update clause', () {
    final update = Hero.generateSqliteUpdateClause('    ');
    expect(update, '''version=excluded.version,
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
    alignment=excluded.alignment,
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
''');
  });

    test('generate SQLite insert column placeholders', () {
    final placeholders = Hero.generateSQLiteInsertColumnPlaceholders();
    expect(placeholders, '?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?');
  });
}
