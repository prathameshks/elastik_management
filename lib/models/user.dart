import '../models/wfo_schema.dart';

class User {
  final int id;
  final String name;
  final String designation;
  final String email;
  String? passwordHash;
  String imageUrl;
  String role;
  WFOSchema wfoSchema;

  User({
    required this.id,
    required this.name,
    required this.designation,
    required this.imageUrl,
    required this.email,
    required this.role,
    required this.wfoSchema,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as int,
        name: json['name'] as String,
        designation: json['designation'] as String,
        email: json['email'] as String,
        imageUrl: json['imageUrl'] as String,
        role: json['role'] as String,
        wfoSchema: WFOSchema.fromJson(
          json['wfoSchema'] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      throw TypeError();
    }
  }
}
