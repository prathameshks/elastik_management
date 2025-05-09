import '../interfaces/schema_type.dart';

class WFOSchema {
  final int id;
  final String name;
  final String description;
  final SchemaType type;

  WFOSchema({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });

  factory WFOSchema.fromJson(Map<String, dynamic> json) {
    return WFOSchema(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: _parseSchemaType(json['type']),
    );
  }

  static SchemaType _parseSchemaType(String typeString) {
    return SchemaType.values.firstWhere(
      (e) => e.toString() == 'SchemaType.$typeString',
      orElse: () => SchemaType.specificDate,
    );
  }

  static WFOSchema defaultSchema() {
    return WFOSchema(
      id: 0,
      name: 'WFH',
      description: 'Working From Home',
      type: SchemaType.wfh,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WFOSchema && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
