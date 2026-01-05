import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthService {
  final String _baseUrl = 'http://localhost:8889';
  String? _token;
  User? _currentUser;

 
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  /// Connexion
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final authResponse = AuthResponse.fromJson(jsonDecode(responseBody));
      
      // Sauvegarde du token et user
      _token = authResponse.token;
      _currentUser = authResponse.toUser();
      
      // Persister dans SharedPreferences
      await _saveAuthData(authResponse);
      
      return authResponse;
    } else {
      print('Erreur login: ${response.statusCode}');
      print('URL: $_baseUrl/api/auth/login');
      print('Body: ${response.body}');
      throw Exception('Échec de connexion: ${response.statusCode} - ${response.body}');
    }
  }

  /// Inscription
  Future<AuthResponse> register(String email, String password, String nom, String prenom) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
      }),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final authResponse = AuthResponse.fromJson(jsonDecode(responseBody));
      
      // Sauvegarde du token et user
      _token = authResponse.token;
      _currentUser = authResponse.toUser();
      
      // Persister dans SharedPreferences
      await _saveAuthData(authResponse);
      
      return authResponse;
    } else {
      throw Exception('Échec d\'inscription: ${response.statusCode}');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  /// Récupérer les infos utilisateur connecté
  Future<User> getCurrentUser() async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      _currentUser = User.fromJson(jsonDecode(responseBody));
      return _currentUser!;
    } else {
      throw Exception('Échec de récupération utilisateur: ${response.statusCode}');
    }
  }

  /// Charger les données d'auth depuis le stockage local
  Future<bool> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      _token = token;
      _currentUser = User.fromJson(jsonDecode(userData));
      return true;
    }
    return false;
  }

  /// Sauvegarder les données d'auth
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authResponse.token);
    await prefs.setString('user_data', jsonEncode(authResponse.toUser().toJson()));
  }

  /// Vérifier si l'utilisateur est admin
  bool isAdmin() {
    return _currentUser?.isAdmin ?? false;
  }

  /// Vérifier si l'utilisateur est étudiant
  bool isEtudiant() {
    return _currentUser?.isEtudiant ?? false;
  }

  /// Vérifier si l'utilisateur est professeur
  bool isProfesseur() {
    return _currentUser?.isProfesseur ?? false;
  }

  /// Créer un compte professeur (ADMIN uniquement)
  Future<User> createProfesseur(String email, String password, String nom, String prenom) async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/create-professeur'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
      }),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final authResponse = AuthResponse.fromJson(jsonDecode(responseBody));
      return authResponse.toUser();
    } else {
      throw Exception('Échec de création du professeur: ${response.statusCode}');
    }
  }

  /// Créer un utilisateur avec rôle spécifique (ADMIN uniquement)
  Future<User> createUser(String email, String password, String nom, String prenom, String role) async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    print('FLUTTER DEBUG - Token: ${_token?.substring(0, 20)}...');
    print('FLUTTER DEBUG - Role envoyé: $role');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'role': role,
      }),
    );
    
    print('FLUTTER DEBUG - Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final authResponse = AuthResponse.fromJson(jsonDecode(responseBody));
      return authResponse.toUser();
    } else {
      throw Exception('Échec de création de l\'utilisateur: ${response.statusCode}');
    }
  }

  /// Modifier un utilisateur (ADMIN uniquement)
  Future<User> updateUser(String email, String? password, String nom, String prenom, String role) async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    final body = {
      'nom': nom,
      'prenom': prenom,
      'role': role,
    };
    
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/auth/users/$email'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      return User.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Échec de modification de l\'utilisateur: ${response.statusCode}');
    }
  }

  /// Liste de tous les utilisateurs (ADMIN uniquement)
  Future<List<User>> getAllUsers() async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/users'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(responseBody);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération des utilisateurs: ${response.statusCode}');
    }
  }

  /// Supprimer un utilisateur (ADMIN uniquement)
  Future<void> deleteUser(String email) async {
    if (_token == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/auth/users/$email'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de suppression de l\'utilisateur: ${response.statusCode}');
    }
  }
}
