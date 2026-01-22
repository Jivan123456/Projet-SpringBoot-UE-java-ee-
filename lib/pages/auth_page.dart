import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true; // true = connexion, false = inscription
  bool _isLoading = false;
  
  // Contrôleurs pour les champs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Connexion
        await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Inscription
        await _authService.register(
          _emailController.text.trim(),
          _passwordController.text,
          _nomController.text.trim(),
          _prenomController.text.trim(),
        );
      }

      // Succès - Navigation vers DashboardPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage(authService: _authService)),
      );
    } catch (e) {
      // Erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin 
              ? 'Échec de connexion. Vérifiez vos identifiants.' 
              : 'Échec d\'inscription. L\'email existe peut-être déjà.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade400, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo ou titre
                        Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Gestion Universités',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isLogin ? 'Connexion' : 'Inscription',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 4) {
                              return 'Minimum 4 caractères';
                            }
                            return null;
                          },
                        ),

                        // Champs supplémentaires pour inscription
                        if (!_isLogin) ...[
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre prénom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                                    SizedBox(width: 8),
                                    Text(
                                      'Rôles disponibles:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  ' ÉTUDIANT - Tous les nouveaux comptes',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  ' PROFESSEUR - Créé par un admin',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  ' ADMIN - admin@admin.com uniquement',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 24),

                        // Bouton de soumission
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    _isLogin ? 'Se connecter' : 'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Basculer entre connexion et inscription
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Pas de compte ? S\'inscrire'
                                : 'Déjà un compte ? Se connecter',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
