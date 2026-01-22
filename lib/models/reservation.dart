class Reservation {
  final int? id;
  final String? salleNums;
  final String? salleNom;
  final String? batimentNom;
  final String? campusNom;
  final String? userEmail;
  final String? userNom;
  final String? userPrenom;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? motif;
  final String? statut; // EN_ATTENTE, APPROUVEE, REFUSEE, ANNULEE
  final DateTime? dateCreation;

  Reservation({
    this.id,
    this.salleNums,
    this.salleNom,
    this.batimentNom,
    this.campusNom,
    this.userEmail,
    this.userNom,
    this.userPrenom,
    this.dateDebut,
    this.dateFin,
    this.motif,
    this.statut,
    this.dateCreation,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      salleNums: json['salleNums'] ?? '',
      salleNom: json['salleNom'] ?? '',
      batimentNom: json['batimentNom'] ?? '',
      campusNom: json['campusNom'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userNom: json['userNom'] ?? '',
      userPrenom: json['userPrenom'] ?? '',
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      motif: json['motif'] ?? '',
      statut: json['statut'] ?? 'EN_ATTENTE',
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salleNums': salleNums,
      'salleNom': salleNom,
      'batimentNom': batimentNom,
      'campusNom': campusNom,
      'userEmail': userEmail,
      'userNom': userNom,
      'userPrenom': userPrenom,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'motif': motif,
      'statut': statut,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }

  String get statutDisplay {
    switch (statut) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'APPROUVEE':
        return 'Approuvée';
      case 'REFUSEE':
        return 'Refusée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut ?? 'N/A';
    }
  }

  String get dureeDisplay {
    if (dateFin == null || dateDebut == null) return '0min';
    final duree = dateFin!.difference(dateDebut!);
    final heures = duree.inHours;
    final minutes = duree.inMinutes % 60;
    if (heures > 0 && minutes > 0) {
      return '${heures}h${minutes}min';
    } else if (heures > 0) {
      return '${heures}h';
    } else {
      return '${minutes}min';
    }
  }
}
