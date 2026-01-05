class User {
  final int? id;
  final String? email;
  final String? nom;
  final String? prenom;
  final Set<String>? roles;

  User({
    this.id,
    this.email,
    this.nom,
    this.prenom,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      roles: Set<String>.from(json['roles'] ?? []),
    );
  }

  // Le backend envoie toujours les rôles avec préfixe "ROLE_"
  bool get isAdmin => roles?.contains('ROLE_ADMIN') ?? false;
  bool get isEtudiant => roles?.contains('ROLE_ETUDIANT') ?? false;
  bool get isProfesseur => roles?.contains('ROLE_PROFESSEUR') ?? false;
  
  String get roleDisplay {
    if (isAdmin) return 'ADMIN';
    if (isProfesseur) return 'PROFESSEUR';
    if (isEtudiant) return 'ÉTUDIANT';
    return 'INCONNU';
  }

  String get displayName {
    return '${prenom ?? ''} ${nom ?? ''}'.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'roles': roles?.toList() ?? [],
    };
  }
}
