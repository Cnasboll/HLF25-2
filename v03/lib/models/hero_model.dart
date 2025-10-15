import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'package:v03/amendable/field_base.dart';
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
      name: _nameField.getStringForAmendment(original, amendment),
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
      serverId: _serverIdField.getString(json, "unknown-server-id"),
      name: _nameField.getString(json, "unknown-name"),
      powerStats: PowerStatsModel.fromJson(_powerstatsField.getJson(json)),
      biography: BiographyModel.fromJson(_biographyField.getJson(json)),
      appearance: AppearanceModel.fromJson(_appearanceField.getJson(json)),
      work: WorkModel.fromJson(_workField.getJson(json)),
      connections: ConnectionsModel.fromJson(_connectionsField.getJson(json)),
      image: ImageModel.fromJson(_imageField.getJson(json)),
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
  List<FieldBase<HeroModel>> get fields => staticFields;

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

  static final FieldBase<HeroModel> _idField = Field.infer(
    (h) => h.id,
    "id",
    "UUID",
    primary: true,
  );

  static final FieldBase<HeroModel> _serverIdField = Field.infer(
    (h) => h.serverId,
    "server_id",
    "Server assigned string ID",
    jsonName: "id",
    nullable: false,
    mutable: false
  );

  static final FieldBase<HeroModel> _versionField = Field.infer(
    (h) => h .version,
    "version",
    "Version number",
    nullable: false,
    assignedBySystem: true,
  );

  static final FieldBase<HeroModel> _nameField = Field.infer(
    (h) => h.name,
    "name",
    "Most commonly used name",
    nullable: false,
  );

  static final FieldBase<HeroModel> _powerstatsField = Field.infer(
    (h) => h.powerStats,
    "powerstats",
    "Power statistics which is mostly misused",
    children: PowerStatsModel.staticFields,
  );

  static final FieldBase<HeroModel> _biographyField = Field.infer(
    (h) => h.biography,
    "biography",
    "Hero's quite biased biography",
    format: (h) => "Biography: ${h?.biography}",
    children: BiographyModel.staticFields,
  );

  static final FieldBase<HeroModel> _workField = Field.infer(
    (h) => h.work,
    "work",
    "Hero's work",
    format: (h) => "Work: ${h?.work}",
    children: WorkModel.staticFields,
  );

  static final FieldBase<HeroModel> _appearanceField = Field.infer(
    (h) => h.appearance,
    "appearance",
    "Hero's appearance",
    format: (h) => "Appearance: ${h?.appearance}",
    children: AppearanceModel.staticFields,
  );

  static final FieldBase<HeroModel> _connectionsField = Field.infer(
    (h) => h.connections,
    "connections",
    "Hero's connections",
    format: (h) => "Connections: ${h?.connections}",
    children: ConnectionsModel.staticFields,
  );

  static final FieldBase<HeroModel> _imageField = Field.infer(
    (h) => h.image,
    "image",
    "Hero's image",
    format: (h) => "Image: ${h?.image}",
    children: ImageModel.staticFields,
  );

  static final List<FieldBase<HeroModel>> staticFields = [
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
