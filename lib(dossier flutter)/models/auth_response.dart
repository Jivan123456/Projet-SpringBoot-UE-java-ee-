import 'user.dart';

class AuthResponse {
  final String token;
  final int? id;
  final String email;
  final String nom;
  final String prenom;
  final Set<String> roles;

  AuthResponse({
    required this.token,
    this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      roles: Set<String>.from(json['roles'] ?? []),
    );
  }

  User toUser() {
    return User(
      id: id,
      email: email,
      nom: nom,
      prenom: prenom,
      roles: roles,
    );
  }
}
