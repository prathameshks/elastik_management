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
    return User(
      id: json['id'],
      name: json['name'],
      designation: json['designation'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      role: json['role'],
      wfoSchema: WFOSchema.fromJson(json['wfoSchema']),
    );
  }
}
