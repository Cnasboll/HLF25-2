import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'package:v03/models/appearance_model.dart';
import 'package:v03/models/biography_model.dart';
import 'package:v03/models/connections_model.dart';
import 'package:v03/models/image_model.dart';
import 'package:v03/models/power_stats_model.dart';
import 'package:v03/models/work_model.dart';
import 'package:v03/amendable/field.dart';
import 'package:v03/amendable/amendable.dart';

class HeroModel extends Amendable<HeroModel> {
  HeroModel({
    required this.id,
    required this.serverId,
    required this.version,
    required this.name,
    required this.powerStats,
    required this.biography,
    required this.appearance,
    required this.work,
    required this.connections,
    required this.image,
  });

  HeroModel.newId(
    String serverId,
    String name,
    PowerStatsModel powerStats,
    BiographyModel biography,
    AppearanceModel appearance,
    WorkModel work,
    ConnectionsModel connections,
    ImageModel image,
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

  factory HeroModel.amendWith(
    HeroModel original,
    Map<String, dynamic>? amendment,
  ) {
    return HeroModel(
      id: original.id,
      version: original.version + 1,
      serverId: original.serverId,
      name: _nameField.getStringFromJsonForAmendment(original, amendment),
      powerStats: original.powerStats.fromChildJsonAmendment(_powerstatsField, amendment),
      biography: original.biography.fromChildJsonAmendment(_biographyField, amendment),
      appearance: original.appearance.fromChildJsonAmendment(_appearanceField, amendment),
      work: original.work.fromChildJsonAmendment(_workField, amendment),
      connections: original.connections.fromChildJsonAmendment(_connectionsField, amendment),
      image: original.image.fromChildJsonAmendment(_imageField, amendment),
    );
  }

  HeroModel.fromJsonAndId(Map<String, dynamic> json, String id) : this(
      id : id,
      version: 1,
      serverId: _serverIdField.getStringFromJson(json, "unknown-server-id"),
      name: _nameField.getStringFromJson(json, "unknown-name"),
      powerStats: PowerStatsModel.fromJson(_powerstatsField.getJsonFromJson(json)),
      biography: BiographyModel.fromJson(_biographyField.getJsonFromJson(json)),
      appearance: AppearanceModel.fromJson(_appearanceField.getJsonFromJson(json)),
      work: WorkModel.fromJson(_workField.getJsonFromJson(json)),
      connections: ConnectionsModel.fromJson(_connectionsField.getJsonFromJson(json)),
      image: ImageModel.fromJson(_imageField.getJsonFromJson(json)),
    );

  factory HeroModel.fromRow(Row row) {
    return HeroModel(
      version: _versionField.getIntFromRow(row, -1),
      id: _idField.getStringFromRow(row, "unknown-id"),
      serverId: _serverIdField.getStringFromRow(row, "unknown-server-id"),
      name: _nameField.getNullableStringFromRow(row) as String,
      powerStats: PowerStatsModel.fromRow(row),
      biography: BiographyModel.fromRow(row),
      appearance: AppearanceModel.fromRow(row),
      work: WorkModel.fromRow(row),
      connections: ConnectionsModel.fromRow(row),
      image: ImageModel.fromRow(row),
    );
  }

  HeroModel.from(HeroModel other)
    : this(
        id: other.id,
        version: other.version,
        serverId: other.serverId,
        name: other.name,
        powerStats: PowerStatsModel.from(other.powerStats),
        biography: BiographyModel.from(other.biography),
        appearance: AppearanceModel.from(other.appearance),
        work: WorkModel.from(other.work),
        connections: ConnectionsModel.from(other.connections),
        image: ImageModel.from(other.image),
      );

  HeroModel copyWith({
    String? id,
    int? version,
    String? serverId,
    String? name,
    PowerStatsModel? powerStats,
    BiographyModel? biography,
    AppearanceModel? appearance,
    WorkModel? work,
    ConnectionsModel? connections,
    ImageModel? image,
  }) {
    return HeroModel(
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
  int compareTo(HeroModel other) {
    int comparison = powerStats.compareTo(other.powerStats);
    if (comparison != 0) {
      return comparison;
    }

    // if powerStats are the same, sort other, fields ascending in order of significance which is
    // appearance, biography, id, serverId, version, name, work, connections, image
    // (id is before serverId as it is more unique, version is after serverId
    comparison = appearance.compareTo(other.appearance);
    if (comparison != 0) {
      return comparison;
    }
    comparison = biography.compareTo(other.biography);
    if (comparison != 0) {
      return comparison;
    }
    for (var field in [     
      _idField,
      _serverIdField,
      _versionField,
      _nameField,
    ]) {
      comparison = field.compareField(this, other);
      if (comparison != 0) {
        return comparison;
      }
    }

    comparison = work.compareTo(other.work);
    if (comparison != 0) {
      return comparison;
    }
    comparison = connections.compareTo(other.connections);
    if (comparison != 0) {
      return comparison;
    }
    comparison = image.compareTo(other.image);
    if (comparison != 0) {
      return comparison;
    }

    return 0;
  }

  @override
  HeroModel amendWith(Map<String, dynamic>? amendment) {
    return HeroModel.amendWith(this, amendment);
  }

  static HeroModel? fromPrompt() {
    var json = Amendable.promptForJson(staticFields);
    if (json == null) {
      return null;
    }

    return HeroModel.fromJsonAndId(json, Uuid().v4());
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
  List<query<HeroModel>> get fields => staticFields;

  final String id;
  // "ID" field in JSON is "serverId" here to avoid confusion with our own "id" field.
  // It appears to be an integer in the JSON, but is actually a string.
  final String serverId;
  final int version;
  final String name;
  final PowerStatsModel powerStats;
  final BiographyModel biography;
  final AppearanceModel appearance;
  final WorkModel work;
  final ConnectionsModel connections;
  final ImageModel image;

  static final query<HeroModel> _idField = query<HeroModel>(
    (h) => h?.id ?? Uuid(),
    String,
    "id",
    "UUID",
    primary: true,
  );

  static final query<HeroModel> _serverIdField = query<HeroModel>(
    (h) => h?.serverId,
    String,
    "server_id",
    "Server assigned string ID",
    jsonName: "id",
    nullable: false,
    mutable: false
  );

  static final query<HeroModel> _versionField = query<HeroModel>(
    (v) => v?.version ?? 1,
    int,
    'version',
    'Version number',
    nullable: false,
    assignedBySystem: true,
  );

  static final query<HeroModel> _nameField = query<HeroModel>(
    (h) => h?.name ?? '',
    String,
    "name",
    "Most commonly used name",
    nullable: false,
  );

  static final query<HeroModel> _powerstatsField = query<HeroModel>(
    (h) => h?.powerStats,
    PowerStatsModel,
    "powerstats",
    "Power statistics which is mostly misused",
    children: PowerStatsModel.staticFields,
  );

  static final query<HeroModel> _biographyField = query<HeroModel>(
    (h) => h?.biography,
    BiographyModel,
    "biography",
    "Hero's quite biased biography",
    format: (h) => "Biography: ${h?.biography}",
    children: BiographyModel.staticFields,
  );

  static final query<HeroModel> _workField = query<HeroModel>(
    (h) => h?.work,
    WorkModel,
    "work",
    "Hero's work",
    format: (h) => "Work: ${h?.work}",
    children: WorkModel.staticFields,
  );

  static final query<HeroModel> _appearanceField = query<HeroModel>(
    (h) => h?.appearance,
    AppearanceModel,
    "appearance",
    "Hero's appearance",
    format: (h) => "Appearance: ${h?.appearance}",
    children: AppearanceModel.staticFields,
  );

  static final query<HeroModel> _connectionsField = query<HeroModel>(
    (h) => h?.connections,
    ConnectionsModel,
    "connections",
    "Hero's connections",
    format: (h) => "Connections: ${h?.connections}",
    children: ConnectionsModel.staticFields,
  );

  static final query<HeroModel> _imageField = query<HeroModel>(
    (h) => h?.image,
    ImageModel,
    "image",
    "Hero's image",
    format: (h) => "Image: ${h?.image}",
    children: ImageModel.staticFields,
  );

  static final List<query<HeroModel>> staticFields = [
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
