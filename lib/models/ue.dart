class UE {
  final int? idUe;
  final String? nom;
  final String? description;
  final int? nbHeures;
  final int? credits;
  final String? composanteAcronyme;
  final List<String>? professeurs; // Noms des professeurs

  UE({
    this.idUe,
    this.nom,
    this.description,
    this.nbHeures,
    this.credits,
    this.composanteAcronyme,
    this.professeurs,
  });

  factory UE.fromJson(Map<String, dynamic> json) {
    // Extraire les noms des professeurs
    List<String> profs = [];
    if (json['professeurs'] != null) {
      for (var prof in json['professeurs']) {
        if (prof['nom'] != null && prof['prenom'] != null) {
          profs.add('${prof['prenom']} ${prof['nom']}');
        }
      }
    }
    
    return UE(
      idUe: json['idUe'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'],
      nbHeures: json['nbHeures'] ?? 0,
      credits: json['credits'] ?? 0,
      composanteAcronyme: json['composante']?['acronyme'] ?? json['composanteAcronyme'] ?? '',
      professeurs: profs.isEmpty ? null : profs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUe': idUe,
      'nom': nom,
      'description': description,
      'nbHeures': nbHeures,
      'credits': credits,
      'composanteAcronyme': composanteAcronyme,
    };
  }
}
