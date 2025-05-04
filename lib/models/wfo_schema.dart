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
    required this.type
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
        orElse: () => SchemaType.specificDate);
  }
}
