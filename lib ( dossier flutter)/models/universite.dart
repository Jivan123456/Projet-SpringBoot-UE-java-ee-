import 'dart:convert';
//cette classe est :  "contrat" entre application Flutter et backend Spring Boot.
// entité Ex.modele.Universite
class Universite {
  final String acronyme;
  final String nom;
  final int creation;
  final String presidence;
  // Les listes 'campus' ne sont pas incluses par défaut par Spring
  // pour éviter les boucles, donc on  met pas ici.

  Universite({
    required this.acronyme,
    required this.nom,
    required this.creation,
    required this.presidence,
  });



//fromJson : Sert à transformer les données reçues 
//API Spring (format JSON) en objets Dart utilisables par l'application.
  factory Universite.fromJson(Map<String, dynamic> json) {
    return Universite(
      acronyme: json['acronyme'],
      nom: json['nom'],
      creation: json['creation'],
      presidence: json['presidence'],
    );
    
  }
 
  // Convertit l'objet Dart en Map (pr le json)
  //pour l'envoyer au backend lors de la création d'une université (POST).
 
  Map<String, dynamic> toJson() {
    return {
      'acronyme': acronyme,
      'nom': nom,
      'creation': creation,
      'presidence': presidence,
    };
  }
}
