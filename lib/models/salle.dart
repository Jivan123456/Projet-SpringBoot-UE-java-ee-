class Salle {
  final String? numS;
  final int? capacite;
  final String? typeS;
  final String? acces;
  final String? batimentId;

  Salle({
    this.numS,
    this.capacite,
    this.typeS,
    this.acces,
    this.batimentId,
  });



  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      numS: json['nums'],  // Backend utilise 'nums' (minuscule)
      capacite: json['capacite'],
      typeS: json['types'],  // Backend utilise 'types' (minuscule)
      acces: json['acces'],
      batimentId: json['batimentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nums': numS,  // Backend attend 'nums' (minuscule)
      'capacite': capacite,
      'types': typeS,  // Backend attend 'types' (minuscule)
      'acces': acces,
      'batimentId': batimentId,
    };
  }
}

// Enum pour les types de salle
enum TypeSalle {
  AMPHI,
  SC,
  TD,
  TP,
  NUMERIQUE;

  String get description {
    switch (this) {
      case TypeSalle.AMPHI:
        return 'Amphithéâtre';
      case TypeSalle.SC:
        return 'Salle de cours';
      case TypeSalle.TD:
        return 'Travaux dirigés';
      case TypeSalle.TP:
        return 'Travaux pratiques';
      case TypeSalle.NUMERIQUE:
        return 'Salle numérique';
    }
  }
}
