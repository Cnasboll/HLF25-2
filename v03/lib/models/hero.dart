import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'package:v03/models/appearance.dart';
import 'package:v03/models/biography.dart';
import 'package:v03/models/connections.dart';
import 'package:v03/models/image.dart';
import 'package:v03/models/power_stats.dart';
import 'package:v03/models/work.dart';
import 'package:v03/updateable/field.dart';
import 'package:v03/updateable/updateable.dart';

class Hero extends Updateable<Hero> {
  Hero({
    required this.id,
    required this.serverId,
    required this.version,
    required this.name,
    this.powerStats,
    this.biography,
    this.appearance,
    this.work,
    this.connections,
    this.image,
  });

  Hero.newId(
    int serverId,
    String name,
    PowerStats? powerStats,
    Biography? biography,
    Appearance? appearance,
    Work? work,
    Connections? connections,
    Image? image,
  ) : this(
        id: Uuid().v4(),
        version: 1,
        serverId: serverId,
        name: name,
        powerStats: powerStats,
        biography: biography,
        appearance: appearance,
        work: work,
        connections: connections,
        image: image,
      );

  factory Hero.fromJsonAmendment(
    Hero original,
    Map<String, dynamic>? amendment,
  ) {
    return Hero(
      id: original.id,
      version: original.version + 1,
      serverId: original.serverId,
      name: _nameField.getStringFromJsonForAmendment(original, amendment),
      powerStats: PowerStats.amendOrCreate(
        _powerstatsField,
        original.powerStats,
        amendment,
      ),
      biography: Biography.amendOrCreate(
        _biographyField,
        original.biography,
        amendment,
      ),
      appearance: Appearance.amendOrCreate(
        _appearanceField,
        original.appearance,
        amendment,
      ),
      work: Work.amendOrCreate(_workField, original.work, amendment),
      connections: Connections.amendOrCreate(
        _connectionsField,
        original.connections,
        amendment,
      ),
      image: Image.amendOrCreate(_imageField, original.image, amendment),
    );
  }

  Hero.fromJsonAndId(Map<String, dynamic> json, String id) : this(
      id : id,
      version: 1,
      serverId: _serverIdField.getIntFromJson(json, -1),
      name: _nameField.getStringFromJson(json, "unknown-name"),
      powerStats: PowerStats.fromJson(_powerstatsField.getJsonFromJson(json)),
      biography: Biography.fromJson(_biographyField.getJsonFromJson(json)),
      appearance: Appearance.fromJson(_appearanceField.getJsonFromJson(json)),
      work: Work.fromJson(_workField.getJsonFromJson(json)),
      connections: Connections.fromJson(_connectionsField.getJsonFromJson(json)),
      image: Image.fromJson(_imageField.getJsonFromJson(json)),
    );

  factory Hero.fromRow(Row row) {
    return Hero(
      version: _versionField.getIntFromRow(row, -1),
      id: _idField.getStringFromRow(row, "unknown-id"),
      serverId: _serverIdField.getNullableIntFromRow(row) as int,
      name: _nameField.getNullableStringFromRow(row) as String,
      powerStats: PowerStats.fromRow(row),
      biography: Biography.fromRow(row),
      appearance: Appearance.fromRow(row),
      work: Work.fromRow(row),
      connections: Connections.fromRow(row),
      image: Image.fromRow(row),
    );
  }

  Hero.from(Hero other)
    : this(
        id: other.id,
        version: other.version,
        serverId: other.serverId,
        name: other.name,
        powerStats: other.powerStats == null
            ? null
            : PowerStats.from(other.powerStats!),
        biography: other.biography == null
            ? null
            : Biography.from(other.biography!),
        appearance: other.appearance == null
            ? null
            : Appearance.from(other.appearance!),
        work: other.work == null ? null : Work.from(other.work!),
        connections: other.connections == null
            ? null
            : Connections.from(other.connections!),
        image: other.image == null ? null : Image.from(other.image!),
      );

  Hero copyWith({
    String? id,
    int? version,
    int? serverId,
    String? name,
    PowerStats? powerStats,
    Biography? biography,
    Appearance? appearance,
    Work? work,
    Connections? connections,
    Image? image,
  }) {
    return Hero(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      version: (version ?? 1) + 1,
      name: name ?? this.name,
      powerStats: powerStats ?? this.powerStats,
      biography: biography ?? this.biography,
      appearance: appearance ?? this.appearance,
      work: work ?? this.work,
      connections: connections ?? this.connections,
      image: image ?? this.image,
    );
  }

  @override
  int compareTo(Hero other) {
    // Sort by strength, descending by reversing the comparison of powerStats
    // to get descending order
    int comparison = _powerstatsField.compareField(other, this);
    // if powerStats are the same, sort by biography
    if (comparison == 0) {
      comparison = _biographyField.compareField(this, other);
    }

    // if powerStats and biography are the same, sort by appearance
    if (comparison == 0) {
      comparison = _appearanceField.compareField(this, other);
    }

    // if powerStats, biography and appearance are the same, sort by work
    if (comparison == 0) {
      comparison = _workField.compareField(this, other);
    }

    // ... connections
    if (comparison == 0) {
      comparison = _connectionsField.compareField(this, other);
    }

    // ... image
    if (comparison == 0) {
      comparison = _imageField.compareField(this, other);
    }

    return comparison;
  }

  @override
  Hero fromJsonAmendment(Map<String, dynamic>? amendment) {
    return Hero.fromJsonAmendment(this, amendment);
  }

  static Hero? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }

    return Hero.fromJsonAndId(json, Uuid().v4());
  }

  static String generateSQLiteInsertColumnPlaceholders() {
    return staticFields
        .map((f) => f.generateSQLiteInsertColumnPlaceholders())
        .join(',');
  }

  static String generateSqliteColumnNameList(String indent) {
    return '$indent${staticFields.map((f) => f.generateSqliteColumnNameList(indent)).join(',\n$indent')}\n';
  }

  static String generateSqliteColumnDeclarations(String indent) {
    return '$indent${staticFields.map((f) => f.generateSqliteColumnDeclarations(indent)).join(',\n$indent')}\n';
  }

  static String generateSqliteColumnDefinitions() {
    return '\n${staticFields.map((f) => {f.generateSqliteColumnDefinition()}).join(',\n')}\n';
  }

  static String generateSqliteUpdateClause(String indent) {
    return '${staticFields.where((c) => c.mutable).map((f) => f.generateSqliteUpdateClause(indent)).join(',\n$indent')}\n';
  }

  @override
  List<Field<Hero>> get fields => staticFields;

  final String id;
  final int serverId;
  final int version;
  final String name;
  final PowerStats? powerStats;
  final Biography? biography;
  final Appearance? appearance;
  final Work? work;
  final Connections? connections;
  final Image? image;

  static final Field<Hero> _idField = Field<Hero>(
    (h) => h?.id ?? Uuid(),
    String,
    "id",
    "UUID",
    primary: true,
  );

  static final Field<Hero> _serverIdField = Field<Hero>(
    (h) => h?.serverId,
    int,
    "server_id",
    "Server assigned integer",
    jsonName: "id",
    nullable: false,
  );

  static final Field<Hero> _versionField = Field<Hero>(
    (v) => v?.version ?? 1,
    int,
    'version',
    'Version number',
    nullable: false,
    assignedBySystem: true,
  );

  static final Field<Hero> _nameField = Field<Hero>(
    (h) => h?.name ?? '',
    String,
    "name",
    "Most commonly used name",
    nullable: false,
  );

  static final Field<Hero> _powerstatsField = Field<Hero>(
    (h) => h?.powerStats,
    PowerStats,
    "powerstats",
    "Power statistics which is mostly misused",
    children: PowerStats.staticFields,
  );

  static final Field<Hero> _biographyField = Field<Hero>(
    (h) => h?.biography,
    Biography,
    "biography",
    "Hero's quite biased biography",
    format: (h) => "Biography: ${h?.biography}",
    children: Biography.staticFields,
  );

  static final Field<Hero> _workField = Field<Hero>(
    (h) => h?.work,
    Work,
    "work",
    "Hero's work",
    format: (h) => "Work: ${h?.work}",
    children: Work.staticFields,
  );

  static final Field<Hero> _appearanceField = Field<Hero>(
    (h) => h?.appearance,
    Appearance,
    "appearance",
    "Hero's appearance",
    format: (h) => "Appearance: ${h?.appearance}",
    children: Appearance.staticFields,
  );

  static final Field<Hero> _connectionsField = Field<Hero>(
    (h) => h?.connections,
    Connections,
    "connections",
    "Hero's connections",
    format: (h) => "Connections: ${h?.connections}",
    children: Connections.staticFields,
  );

  static final Field<Hero> _imageField = Field<Hero>(
    (h) => h?.image,
    Image,
    "image",
    "Hero's image",
    format: (h) => "Image: ${h?.image}",
    children: Image.staticFields,
  );

  static final List<Field<Hero>> staticFields = [
    _idField,
    _versionField,
    _serverIdField,
    _nameField,
    _powerstatsField,
    _biographyField,
    _appearanceField,
    _workField,
    _connectionsField,
    _imageField,
  ];
}
