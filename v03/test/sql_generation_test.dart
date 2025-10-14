import 'package:test/test.dart';
import 'package:v03/models/hero_model.dart';

void main() {
  test('generate SQLite column names', () {
    final names = HeroModel.generateSqliteColumnNameList('      ');
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
      height,
      weight,
      eye_color,
      hair_color,
      occupation,
      base,
      group_affiliation,
      relatives,
      image_url
''');
  });

  test('generate SQLite column declarations', () {
    final declarations = HeroModel.generateSqliteColumnDeclarations('  ');
    expect(declarations, '''
  id TEXT PRIMARY KEY,
  version INTEGER NOT NULL,
  server_id TEXT NOT NULL,
  name TEXT NOT NULL,
  intelligence INTEGER NULL,
  strength INTEGER NULL,
  speed INTEGER NULL,
  durability INTEGER NULL,
  power INTEGER NULL,
  combat INTEGER NULL,
  full_name TEXT NULL,
  alter_egos TEXT NULL,
  aliases TEXT NULL,
  place_of_birth TEXT NULL,
  first_appearance TEXT NULL,
  publisher TEXT NULL,
  alignment TEXT NOT NULL,
  gender TEXT NOT NULL,
  race TEXT NULL,
  height TEXT NULL,
  weight TEXT NULL,
  eye_color TEXT NULL,
  hair_color TEXT NULL,
  occupation TEXT NULL,
  base TEXT NULL,
  group_affiliation TEXT NULL,
  relatives TEXT NULL,
  image_url TEXT NULL
''');
  });

  test('generate SQLite update clause', () {
    final update = HeroModel.generateSqliteUpdateClause('    ');
    expect(update, '''version=excluded.version,
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
    height=excluded.height,
    weight=excluded.weight,
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
    final placeholders = HeroModel.generateSQLiteInsertColumnPlaceholders();
    expect(placeholders, '?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?');
  });
}
