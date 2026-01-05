import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salle.dart';
import '../models/campus.dart';
import '../models/batiment.dart';
import 'auth_service.dart';

class RechercheService {
  final String _baseUrl = 'http://localhost:8889';
  final AuthService _authService;

  RechercheService(this._authService);

  /// Salles pour réviser (étudiants)
  Future<List<Salle>> getSallesPourReviser({
    required String ville,
    int minCap = 10,
    int maxCap = 40,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/salles-revision?ville=$ville&minCap=$minCap&maxCap=$maxCap'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Salles par capacité
  Future<List<Salle>> getSallesByCapacite(int minCap, int maxCap) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/salles-capacite?minCap=$minCap&maxCap=$maxCap'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Salles pour un cours (professeurs)
  Future<List<Salle>> getSallesPourCours({
    required String type,
    required int minCap,
    required String campus,
  }) async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/salles-cours?type=$type&minCap=$minCap&campus=${Uri.encodeComponent(campus)}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Salles par université et type
  Future<List<Salle>> getSallesByUniversite(String universite, String type) async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/salles-universite?universite=$universite&type=$type'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Recherche multicritères
  Future<List<Salle>> searchMultiCriteria({
    String? ville,
    String? type,
    int? minCap,
    int? maxCap,
  }) async {
    final params = <String>[];
    if (ville != null) params.add('ville=${Uri.encodeComponent(ville)}');
    if (type != null) params.add('type=$type');
    if (minCap != null) params.add('minCap=$minCap');
    if (maxCap != null) params.add('maxCap=$maxCap');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/multi-criteres?${params.join('&')}'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Top salles (admin)
  Future<List<Salle>> getTopSalles({int limit = 10}) async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/top-salles?limit=$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Salle.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Statistiques ville/type (admin)
  Future<List<Map<String, dynamic>>> getStatsByVilleType() async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/stats-ville-type'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Capacité totale par ville
  Future<List<Map<String, dynamic>>> getCapaciteByVille() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/capacite-ville'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Analyse globale (admin)
  Future<Map<String, dynamic>> getAnalyseGlobale() async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/analyse-globale'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Campus par université
  Future<List<Campus>> getCampusByUniversite(String acronyme) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/campus-universite/$acronyme'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Campus.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Bâtiments par ville
  Future<List<Batiment>> getBatimentsByVille(String ville) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/batiments-ville/$ville'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Batiment.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Bâtiments récents
  Future<List<Batiment>> getRecentBatiments(int annee) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/batiments-recents?annee=$annee'),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Batiment.fromJson(json)).toList();
    } else {
      throw Exception('Échec de recherche: ${response.statusCode}');
    }
  }

  /// Statistiques campus
  Future<List<Map<String, dynamic>>> getStatsCampus() async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/stats-campus'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Statistiques bâtiments
  Future<List<Map<String, dynamic>>> getStatsBatiments() async {
    final token = _authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/recherche/stats-batiments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return List<Map<String, dynamic>>.from(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }
}
