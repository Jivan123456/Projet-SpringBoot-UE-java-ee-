import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/universite.dart';


class ApiService {
 
  // 'http://10.0.2.2:8889' (Émulateur Android)
  // 'http://localhost:8889' (Simulateur iOS ou Web)
   //final String _baseUrl = 'http://10.0.2.2:8889';
  final String _baseUrl =  'http://localhost:8889';
 
  /// Récupère la liste de toutes les universités
  ///( GET /api/universite)
  Future<List<Universite>> fetchUniversites() async {
   
    final response = await http.get(Uri.parse('$_baseUrl/api/universite'));

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      
   
      return jsonList
          .map((json) => Universite.fromJson(json))
          .toList();
    } else {
      
      throw Exception('Échec du chargement des universités: ${response.statusCode}');
    }
  }

  /// Crée une nouvelle université via POST /api/universite
  ///
  Future<Universite> createUniversite(Universite universite) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/universite'),
      
      // En-tête  pour envoyer du JSON
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      
      // l'objet Dart encodé en chaîne JSON
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

}