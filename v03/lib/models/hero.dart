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
    required this.powerStats,
    required this.biography,
    required this.appearance,
    required this.work,
    required this.connections,
    required this.image
  });

  Hero.newId(
    int serverId,
    String name,
    PowerStats powerStats,
    Biography biography,
    Appearance appearance,
    Work work,
    Connections connections,
    Image image
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
        image: image
      );
    
  factory Hero.fromJsonUpdate(Hero original, Map<String, dynamic> amendment) {
    return Hero(
      id: original.id,
      version: original.version + 1,
      serverId: original.serverId,
      name: _nameField.getStringForUpdate(original, amendment),
      powerStats: original.powerStats.fromJsonUpdate(amendment['powerstats'] as Map<String, dynamic>),
      biography: original.biography.fromJsonUpdate(amendment['biography'] as Map<String, dynamic>),
      appearance: original.appearance.fromJsonUpdate(amendment['appearance'] as Map<String, dynamic>),
      work: original.work.fromJsonUpdate(amendment['work'] as Map<String, dynamic>),
      connections: original.connections.fromJsonUpdate(amendment['connections'] as Map<String, dynamic>),
      image: original.image.fromJsonUpdate(amendment['image'] as Map<String, dynamic>),
    );
  }

  factory Hero.fromJsonNewId(Map<String, dynamic> json) {
    return Hero.newId(
      _serverIdField.getInt(json),
      _nameField.getString(json),
      PowerStats.fromJson(json['powerstats'] as Map<String, dynamic>),
      Biography.fromJson(json['biography'] as Map<String, dynamic>),
      Appearance.fromJson(json['appearance'] as Map<String, dynamic>),
      Work.fromJson(json['work'] as Map<String, dynamic>),
      Connections.fromJson(json['connections'] as Map<String, dynamic>),
      Image.fromJson(json['image'] as Map<String, dynamic>)
    );
  }

  factory Hero.fromRow(Row row) {
    return Hero(
      version: row['version'] as int,
      id: row['id'] as String,
      serverId: row['server_id'] as int,
      name: row['name'] as String,
      powerStats: PowerStats.fromRow(row),
      biography: Biography.fromRow(row),
      appearance: Appearance.fromRow(row),
      work: Work.fromRow(row),
      connections: Connections.fromRow(row),
      image: Image.fromRow(row),
    );
  }
  
  Hero.copy(Hero other)
    : this(
        id: other.id,
        version: other.version,
        serverId: other.serverId,
        name: other.name,
        powerStats: other.powerStats,
        biography: other.biography,
        appearance: other.appearance,
        work: other.work,
        connections: other.connections,
        image: other.image,
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
    Image? image
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
    var comparison = other.powerStats.compareTo(powerStats);

    // if powerStats are the same, sort by biography
    if (comparison == 0) {
      comparison = biography.compareTo(other.biography);
    }

    // if powerStats and biography are the same, sort by appearance
    if (comparison == 0) {
      comparison = appearance.compareTo(other.appearance);
    }

    // if powerStats, biography and appearance are the same, sort by work
    if (comparison == 0) {
      comparison = work.compareTo(other.work);
    }

    // ... connections
    if (comparison == 0) {
      comparison = connections.compareTo(other.connections);
    }

    // ... image
    if (comparison == 0) {
      comparison = image.compareTo(other.image);
    }

    return comparison;
  }

  @override
  Hero fromJsonUpdate(Map<String, dynamic> amendment) {
    return Hero.fromJsonUpdate(this, amendment);
  }

  static Hero? fromPrompt() {
    var json = Updateable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }

    return Hero.fromJsonNewId(json);
  }

  @override
  List<Field<Hero>> get fields => staticFields;

  final String id;
  final int serverId;
  final int version;
  final String name;
  final PowerStats powerStats;
  final Biography biography;
  final Appearance appearance;
  final Work work;
  final Connections connections;
  final Image image;

  static final Field<Hero> _idField = Field<Hero>(
    (h) => h.id,
    "local_id",
    "UUID",
    mutable: false,
  );

  static final Field<Hero> _serverIdField = Field<Hero>(
    (h) => h.serverId,
    "id",
    "Server assigned integer",
  );

  static final Field<Hero> _versionField = Field<Hero>(
    (v) => v.version,
    'version',
    'Version number',
    mutable: false,
  );

  static final Field<Hero> _nameField = Field<Hero>(
    (h) => h.name,
    "name",
    "Most commonly used name",
  );

  static final Field<Hero> _powerstatsField = Field<Hero>(
    (h) => h.powerStats,
    "powerstats",
    "Power statistics which is mostly misused",
  );

  static final Field<Hero> _biographyField = Field<Hero>(
    (h) => h.biography,
    "biography",
    "Hero's biography",
    format: (h) => "Biography: ${h.biography}"
  );

  static final Field<Hero> _workField = Field<Hero>(
    (h) => h.work,
    "work",
    "Hero's work",
    format: (h) => "Work: ${h.work}"
  );

    static final Field<Hero> _appearanceField = Field<Hero>(
    (h) => h.appearance,
    "appearance",
    "Hero's appearance",
    format: (h) => "Appearance: ${h.appearance}"
  );


  static final Field<Hero> _connectionsField = Field<Hero>(
    (h) => h.connections,
    "connections",
    "Hero's connections",
    format: (h) => "Connections: ${h.connections}"
  );

  static final Field<Hero> _imageField = Field<Hero>(
    (h) => h.image,
    "image",
    "Hero's image",
    format: (h) => "Image: ${h.image}"  
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
