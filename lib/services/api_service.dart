import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/universite.dart';
import '../models/campus.dart';
import '../models/batiment.dart';
import '../models/composante.dart';
import '../models/salle.dart';
import '../models/ue.dart';
import '../models/user.dart';
import '../models/reservation_details.dart';


class ApiService {
 
  // 'http://10.0.2.2:8889' (Émulateur Android)
  // 'http://localhost:8889' (Simulateur iOS ou Web)
   //final String _baseUrl = 'http://10.0.2.2:8889';
  final String _baseUrl =  'http://localhost:8889';
  
  String? _token;

  // Setter pour le token
  void setToken(String? token) {
    _token = token;
  }

  // Headers avec authentification
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
 
  /// Récupère la liste de toutes les universités
  ///( GET /api/universite)
  Future<List<Universite>> fetchUniversites() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/universite'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        
        return jsonList
            .map((json) => Universite.fromJson(json))
            .toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Non autorisé. Veuillez vous reconnecter.');
      } else {
        throw Exception('Échec du chargement: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  /// Crée une nouvelle université via POST /api/universite
  ///
  Future<Universite> createUniversite(Universite universite) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/universite'),
      headers: _getHeaders(),
      body: jsonEncode(universite.toJson()),
    );

    if (response.statusCode == 201) { 
      // L'API renvoie l'objet créé, on le décode
      final String responseBody = utf8.decode(response.bodyBytes);
      return Universite.fromJson(jsonDecode(responseBody));
    } else {
     
      throw Exception('Échec de la création: ${response.statusCode} - ${response.body}');
    }
  }

  /// Met à jour une université via PUT /api/universite/{acronyme}
  Future<Universite> updateUniversite(Universite universite) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/universite/${universite.acronyme}'),
      headers: _getHeaders(),
      body: jsonEncode(universite.toJson()),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Universite.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la modification: ${response.statusCode} - ${response.body}');
    }
  }

  /// Supprime une université via DELETE /api/universite/{acronyme}
  Future<void> deleteUniversite(String acronyme) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/universite/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Échec de la suppression: ${response.statusCode}');
    }
  }

  Future<List<Composante>> fetchComposantesByUniversite(String acronyme) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/universite/$acronyme/composantes'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Composante.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des composantes de l\'université: ${response.statusCode}');
    }
  }

  // ==================== CAMPUS ====================
  
  Future<List<Campus>> fetchCampus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/campus'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Campus.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des campus: ${response.statusCode}');
    }
  }

  Future<Campus> createCampus(Campus campus) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/campus'),
      headers: _getHeaders(),
      body: jsonEncode(campus.toJson()),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Campus.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création du campus: ${response.statusCode}');
    }
  }

  Future<Campus> updateCampus(Campus campus) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/campus/${campus.nomC}'),
      headers: _getHeaders(),
      body: jsonEncode(campus.toJson()),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Campus.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la modification du campus: ${response.statusCode}');
    }
  }

  Future<void> deleteCampus(String nomC) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/campus/$nomC'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression du campus: ${response.statusCode}');
    }
  }

  Future<List<Campus>> fetchCampusByVille(String ville) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/campus/ville/$ville'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Campus.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des campus par ville: ${response.statusCode}');
    }
  }

  Future<List<Campus>> fetchCampusByUniversite(String acronyme) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/campus/universite/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Campus.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des campus par université: ${response.statusCode}');
    }
  }

  Future<List<Composante>> fetchComposantesByCampus(String nomC) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/campus/$nomC/composantes'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Composante.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des composantes du campus: ${response.statusCode}');
    }
  }

  // Nouveaux endpoints backend en cascade
  Future<Campus> associerComposanteACampus(String nomC, String acronyme) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/campus/$nomC/composantes/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Campus.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de l\'association de la composante au campus: ${response.statusCode}');
    }
  }

  Future<Campus> dissocierComposanteDeCampus(String nomC, String acronyme) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/campus/$nomC/composantes/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Campus.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la dissociation de la composante du campus: ${response.statusCode}');
    }
  }

  Future<Batiment> createBatimentFromCampus(String nomC, String codeB, int anneeC) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/campus/$nomC/batiments'),
      headers: _getHeaders(),
      body: jsonEncode({
        'codeB': codeB,
        'anneeC': anneeC,
        // campusId sera rempli automatiquement par le backend
      }),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Batiment.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création du bâtiment depuis le campus: ${response.statusCode}');
    }
  }

  Future<Salle> createSalleFromBatiment(String codeB, String numS, String typeS, int capacite) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/batiment/$codeB/salles'),
      headers: _getHeaders(),
      body: jsonEncode({
        'nums': numS,
        'types': typeS,
        'capacite': capacite,
        'acces': 'Normal',
        // batimentId sera rempli automatiquement par le backend
      }),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Salle.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création de la salle depuis le bâtiment: ${response.statusCode}');
    }
  }

  // Garder les anciennes méthodes pour compatibilité
  Future<void> addComposanteToCampus(String nomC, String acronyme) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/campus/$nomC/composantes/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de l\'ajout de la composante au campus: ${response.statusCode}');
    }
  }

  Future<void> removeComposanteFromCampus(String nomC, String acronyme) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/campus/$nomC/composantes/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec du retrait de la composante du campus: ${response.statusCode}');
    }
  }

  // ==================== BATIMENT ====================
  
  Future<List<Batiment>> fetchBatiments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/batiment'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Batiment.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des bâtiments: ${response.statusCode}');
    }
  }

  Future<Batiment> createBatiment(Batiment batiment) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/batiment'),
      headers: _getHeaders(),
      body: jsonEncode(batiment.toJson()),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Batiment.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création du bâtiment: ${response.statusCode}');
    }
  }

  Future<Batiment> updateBatiment(Batiment batiment) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/batiment/${batiment.codeB}'),
      headers: _getHeaders(),
      body: jsonEncode(batiment.toJson()),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Batiment.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la modification du bâtiment: ${response.statusCode}');
    }
  }

  Future<void> deleteBatiment(String codeB) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/batiment/$codeB'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression du bâtiment: ${response.statusCode}');
    }
  }

  Future<List<Batiment>> fetchBatimentsByCampus(String nomCampus) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/batiment/campus/$nomCampus'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Batiment.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des bâtiments du campus: ${response.statusCode}');
    }
  }

  // ==================== COMPOSANTE ====================
  
  Future<List<Composante>> fetchComposantes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/composante'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Composante.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des composantes: ${response.statusCode}');
    }
  }

  Future<Composante> createComposante(Composante composante) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/composante'),
      headers: _getHeaders(),
      body: jsonEncode(composante.toJson()),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Composante.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création de la composante: ${response.statusCode}');
    }
  }

  Future<Composante> updateComposante(Composante composante) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/composante/${composante.acronyme}'),
      headers: _getHeaders(),
      body: jsonEncode(composante.toJson()),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Composante.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la modification de la composante: ${response.statusCode}');
    }
  }

  Future<void> deleteComposante(String acronyme) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/composante/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de la composante: ${response.statusCode}');
    }
  }

  Future<List<Campus>> fetchCampusByComposante(String acronyme) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/composante/$acronyme/campus'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Campus.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des campus de la composante: ${response.statusCode}');
    }
  }

  // ==================== SALLE ====================
  
  Future<List<Salle>> fetchSalles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des salles: ${response.statusCode}');
    }
  }

  Future<Salle> createSalle(Salle salle) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/salle'),
      headers: _getHeaders(),
      body: jsonEncode(salle.toJson()),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Salle.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création de la salle: ${response.statusCode}');
    }
  }

  Future<Salle> updateSalle(Salle salle) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/salle/${salle.numS}'),
      headers: _getHeaders(),
      body: jsonEncode(salle.toJson()),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Salle.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la modification de la salle: ${response.statusCode}');
    }
  }

  Future<void> deleteSalle(String numS) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/salle/$numS'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de la salle: ${response.statusCode}');
    }
  }

  Future<List<Salle>> fetchSallesByBatiment(String codeBatiment) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle/batiment/$codeBatiment'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des salles du bâtiment: ${response.statusCode}');
    }
  }

  Future<List<Salle>> fetchSallesByType(String type) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle/type/$type'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des salles par type: ${response.statusCode}');
    }
  }

  Future<List<Salle>> fetchSallesAccessibles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle/accessibles'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des salles accessibles: ${response.statusCode}');
    }
  }

  Future<List<Salle>> fetchSallesByCapacite(int min, int max) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle/capacite?min=$min&max=$max'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des salles par capacité: ${response.statusCode}');
    }
  }

  // ==================== UE (Unités d'Enseignement) ====================
  
  /// Récupère toutes les UE
  Future<List<UE>> fetchUEs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ue'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => UE.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des UE: ${response.statusCode}');
    }
  }

  /// Récupère les UE d'une composante
  Future<List<UE>> fetchUEsByComposante(String acronyme) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ue/composante/$acronyme'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => UE.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des UE: ${response.statusCode}');
    }
  }

  /// Crée une nouvelle UE (ADMIN uniquement)
  Future<UE> createUE(UE ue) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ue'),
      headers: _getHeaders(),
      body: jsonEncode(ue.toJson()),
    );

    if (response.statusCode == 201) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return UE.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de la création de l\'UE: ${response.statusCode}');
    }
  }

  /// Supprime une UE (ADMIN uniquement)
  Future<void> deleteUE(int idUe) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ue/$idUe'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Échec de la suppression de l\'UE: ${response.statusCode}');
    }
  }

  /// Professeur: Ajouter une UE à enseigner
  Future<void> professorAddUE(int ueId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ue/$ueId/professeurs/add'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de l\'ajout de l\'UE: ${response.statusCode}');
    }
  }

  /// Professeur: Retirer une UE
  Future<void> professorRemoveUE(int ueId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ue/$ueId/professeurs/remove'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec du retrait de l\'UE: ${response.statusCode}');
    }
  }

  /// Récupère les UE d'un professeur spécifique
  Future<List<UE>> fetchUEsByProfesseur(int professeurId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ue/professeur/$professeurId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => UE.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des UE du professeur: ${response.statusCode}');
    }
  }

  /// Récupère les professeurs d'une UE
  Future<List<User>> fetchProfesseursByUE(int ueId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ue/$ueId/professeurs'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des professeurs: ${response.statusCode}');
    }
  }

  /// Assigner un professeur à une UE (ADMIN ou PROFESSEUR)
  Future<UE> assignProfesseurToUE(int ueId, int professeurId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ue/$ueId/professeur/$professeurId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return UE.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de l\'assignation du professeur: ${response.statusCode}');
    }
  }

  /// Retirer un professeur d'une UE (ADMIN ou PROFESSEUR)
  Future<UE> removeProfesseurFromUE(int ueId, int professeurId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ue/$ueId/professeur/$professeurId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return UE.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec du retrait du professeur: ${response.statusCode}');
    }
  }

  /// Étudiant: S'inscrire à une UE
  Future<void> studentEnrollUE(int ueId, int etudiantId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ue/$ueId/etudiant/$etudiantId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de l\'inscription: ${response.statusCode}');
    }
  }

  /// Étudiant: Se désinscrire d'une UE
  Future<void> studentUnenrollUE(int ueId, int etudiantId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ue/$ueId/etudiant/$etudiantId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la désinscription: ${response.statusCode}');
    }
  }

  /// Récupère les UE auxquelles un étudiant est inscrit
  Future<List<UE>> fetchUEsByEtudiant(int etudiantId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ue/etudiant/$etudiantId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => UE.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des UE: ${response.statusCode}');
    }
  }

  // ==================== RESERVATIONS AVEC UE ====================
  
  /// Récupère les détails enrichis d'une réservation (avec UE)
  Future<ReservationDetails> fetchReservationDetails(int reservationId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/reservation/$reservationId/details'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return ReservationDetails.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec du chargement des détails: ${response.statusCode}');
    }
  }

  /// Récupère les réservations d'une salle avec détails (professeur + UE)
  Future<List<ReservationDetails>> fetchSalleReservations(String salleNums) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/salle/$salleNums/reservations'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => ReservationDetails.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des réservations: ${response.statusCode}');
    }
  }

  // ==================== USERS ====================
  
  /// Récupère tous les utilisateurs (ADMIN uniquement)
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/users'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des utilisateurs: ${response.statusCode}');
    }
  }

}