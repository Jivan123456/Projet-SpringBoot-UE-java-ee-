import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import 'auth_service.dart';

class ReservationService {
  final String _baseUrl = 'http://localhost:8889';
  final AuthService authService;

  ReservationService(this.authService);

  /// Créer une réservation
  Future<Reservation> creerReservation({
    required String salleNums,
    required DateTime dateDebut,
    required DateTime dateFin,
    required String motif,
    int? ueId, // ID de l'UE (optionnel, pour les professeurs)
  }) async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final Map<String, dynamic> body = {
      'salleNums': salleNums,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
      'motif': motif,
    };
    
    if (ueId != null) {
      body['ueId'] = ueId;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/reservations'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Reservation.fromJson(jsonDecode(responseBody));
    } else {
      final errorMsg = utf8.decode(response.bodyBytes);
      throw Exception('Échec de création: $errorMsg');
    }
  }

  /// Mes réservations
  Future<List<Reservation>> getMesReservations() async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reservations/mes-reservations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Réservations d'une salle
  Future<List<Reservation>> getReservationsBySalle(String nums) async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reservations/salle/$nums'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Réservations en attente (ADMIN)
  Future<List<Reservation>> getReservationsEnAttente() async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/reservations/en-attente'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération: ${response.statusCode}');
    }
  }

  /// Approuver une réservation (ADMIN)
  Future<Reservation> approuverReservation(int id) async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.put(
      Uri.parse('$_baseUrl/api/reservations/$id/approuver'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Reservation.fromJson(jsonDecode(responseBody));
    } else {
      final errorMsg = utf8.decode(response.bodyBytes);
      throw Exception('Échec d\'approbation: $errorMsg');
    }
  }

  /// Refuser une réservation (ADMIN)
  Future<Reservation> refuserReservation(int id) async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.put(
      Uri.parse('$_baseUrl/api/reservations/$id/refuser'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Reservation.fromJson(jsonDecode(responseBody));
    } else {
      final errorMsg = utf8.decode(response.bodyBytes);
      throw Exception('Échec de refus: $errorMsg');
    }
  }

  /// Annuler une réservation
  Future<Reservation> annulerReservation(int id) async {
    final token = authService.token;
    if (token == null) throw Exception('Non authentifié');

    final response = await http.put(
      Uri.parse('$_baseUrl/api/reservations/$id/annuler'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return Reservation.fromJson(jsonDecode(responseBody));
    } else {
      final errorMsg = utf8.decode(response.bodyBytes);
      throw Exception('Échec d\'annulation: $errorMsg');
    }
  }
}
