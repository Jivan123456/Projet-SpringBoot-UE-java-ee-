class Composante {
  final String? acronyme;
  final String? nom;
  final String? responsable;
  final String? universiteId;

  Composante({
    this.acronyme,
    this.nom,
    this.responsable,
    this.universiteId,
  });

  factory Composante.fromJson(Map<String, dynamic> json) {
    return Composante(
      acronyme: json['acronyme'],
      nom: json['nom'],
      responsable: json['responsable'],
      universiteId: json['universiteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acronyme': acronyme,
      'nom': nom,
      'responsable': responsable,
      'universiteId': universiteId,
    };
  }
}
