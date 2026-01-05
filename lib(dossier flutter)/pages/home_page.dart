import 'package:flutter/material.dart';
import 'universite_list_page.dart';
import 'auth_page.dart';
import 'campus_list_page.dart';
import 'batiment_list_page.dart';
import 'composante_list_page.dart';
import 'salle_list_page.dart';
import 'professeur_ue_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  final AuthService authService;

  HomePage({required this.authService});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        backgroundColor: Colors.indigo,
        actions: [
          // Badge rôle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Chip(
              avatar: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.school,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                user?.roleDisplay ?? 'INVITÉ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: isAdmin ? Colors.red.shade700 : Colors.blue.shade700,
            ),
          ),
          // Bouton déconnexion
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthPage()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.prenom} ${user?.nom}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade700,
              Colors.indigo.shade400,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête avec infos utilisateur
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Bonjour, ${user?.prenom ?? "Utilisateur"}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      // Section Universités
                      _buildSectionTitle(' Universités'),
                      _buildActionCard(
                        context,
                        icon: Icons.school,
                        title: 'Universités',
                        subtitle: 'Gérer les universités',
                        color: Colors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => UniversiteListPage(authService: authService),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Section Campus
                      _buildSectionTitle(' Campus'),
                      _buildActionCard(
                        context,
                        icon: Icons.location_city,
                        title: 'Campus',
                        subtitle: 'Gérer les campus',
                        color: Colors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => CampusListPage(authService: authService),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Section Bâtiments
                      _buildSectionTitle('Bâtiments'),
                      _buildActionCard(
                        context,
                        icon: Icons.business,
                        title: 'Bâtiments',
                        subtitle: 'Gérer les bâtiments',
                        color: Colors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => BatimentListPage(authService: authService),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Section Composantes
                      _buildSectionTitle('Composantes'),
                      _buildActionCard(
                        context,
                        icon: Icons.category,
                        title: 'Composantes',
                        subtitle: 'Gérer les composantes',
                        color: Colors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ComposanteListPage(authService: authService),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Section Salles
                      _buildSectionTitle(' Salles'),
                      _buildActionCard(
                        context,
                        icon: Icons.meeting_room,
                        title: 'Salles',
                        subtitle: 'Gérer les salles',
                        color: Colors.white,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => SalleListPage(authService: authService),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Section UE pour professeurs
                      if (authService.isProfesseur()) ...[
                        _buildSectionTitle('Mes UE'),
                        _buildActionCard(
                          context,
                          icon: Icons.book,
                          title: 'Mes UE',
                          subtitle: 'Gérer mes unités d\'enseignement',
                          color: Colors.white,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ProfesseurUEPage(authService: authService),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                      ],

                      // Message pour les étudiants
                      if (!isAdmin)
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'En tant qu\'étudiant, vous pouvez consulter les données.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  '© 2025 Gestion Universités',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.indigo.shade700,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.indigo.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
