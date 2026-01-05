class ReservationDetails {
  final int? id;
  final String? salleNums;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? motif;
  final String? statut;
  final DateTime? dateCreation;
  
  // Informations du professeur
  final int? professeurId;
  final String? professeurNom;
  final String? professeurPrenom;
  final String? professeurEmail;
  
  // Informations de l'UE
  final int? ueId;
  final String? ueNom;
  final String? ueDescription;
  final int? ueCredits;
  final int? ueNbHeures;
  final String? ueComposante;

  ReservationDetails({
    this.id,
    this.salleNums,
    this.dateDebut,
    this.dateFin,
    this.motif,
    this.statut,
    this.dateCreation,
    this.professeurId,
    this.professeurNom,
    this.professeurPrenom,
    this.professeurEmail,
    this.ueId,
    this.ueNom,
    this.ueDescription,
    this.ueCredits,
    this.ueNbHeures,
    this.ueComposante,
  });

  factory ReservationDetails.fromJson(Map<String, dynamic> json) {
    return ReservationDetails(
      id: json['id'],
      salleNums: json['salleNums'],
      dateDebut: json['dateDebut'] != null ? DateTime.parse(json['dateDebut']) : null,
      dateFin: json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
      motif: json['motif'],
      statut: json['statut'],
      dateCreation: json['dateCreation'] != null ? DateTime.parse(json['dateCreation']) : null,
      professeurId: json['professeurId'] ?? 0,
      professeurNom: json['professeurNom'] ?? '',
      professeurPrenom: json['professeurPrenom'] ?? '',
      professeurEmail: json['professeurEmail'] ?? '',
      ueId: json['ueId'],
      ueNom: json['ueNom'],
      ueDescription: json['ueDescription'],
      ueCredits: json['ueCredits'],
      ueNbHeures: json['ueNbHeures'],
      ueComposante: json['ueComposante'],
    );
  }
}
