import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/reservation_service.dart';
import '../services/recherche_service.dart';

// Pages Admin
import 'admin/users_management_page.dart';
import 'admin/reservations_approval_page.dart';
import 'admin/statistics_page.dart';
import 'admin/global_analysis_page.dart';
import 'admin/ue_list_page.dart';

// Pages Professeur
import 'professeur/create_reservation_page.dart';
import 'professeur/my_reservations_page.dart';
import 'professeur/search_cours_page.dart';
import 'professeur_ue_page.dart';

// Pages Étudiant
import 'etudiant/search_revision_page.dart';
import 'etudiant/search_salles_page.dart';
import 'etudiant/etudiant_ue_page.dart';

// Pages communes
import 'universite_list_page.dart';
import 'campus_list_page.dart';
import 'batiment_list_page.dart';
import 'salle_list_page.dart';
import 'composante_list_page.dart';
import 'auth_page.dart';

class DashboardPage extends StatefulWidget {
  final AuthService authService;

  DashboardPage({Key? key, required this.authService}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late ApiService apiService;
  late ReservationService reservationService;
  late RechercheService rechercheService;
  
  Widget _currentPage = Center(child: Text('Bienvenue !', style: TextStyle(fontSize: 24)));
  String _currentTitle = 'Tableau de bord';

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    apiService.setToken(widget.authService.token);
    reservationService = ReservationService(widget.authService);
    rechercheService = RechercheService(widget.authService);
  }

  void _navigateTo(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    final isAdmin = widget.authService.isAdmin();
    final isProfesseur = widget.authService.isProfesseur();
    final isEtudiant = widget.authService.isEtudiant();

    return Scaffold(
      body: Row(
        children: [
          // Menu latéral avec flutter_side_menu
          SideMenu(
            hasResizer: true,
            hasResizerToggle: true,
            minWidth: 200,
            maxWidth: 300,
            backgroundColor: Colors.white,
            controller: SideMenuController(),
            builder: (data) {
              return SideMenuData(
                header: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${user?.prenom} ${user?.nom}',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.red.shade700
                              : isProfesseur
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.roleDisplay ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                items: [
                  // Menu Admin
                  if (isAdmin) ...[
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () {},
                      title: 'ADMINISTRATION',
                      titleStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        UsersManagementPage(authService: widget.authService),
                        'Gestion Utilisateurs'
                      ),
                      title: 'Utilisateurs',
                      icon: Icon(Icons.people, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        ReservationsApprovalPage(reservationService: reservationService),
                        'Approbation Réservations'
                      ),
                      title: 'Réservations en attente',
                      icon: Icon(Icons.pending_actions, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        StatisticsPage(rechercheService: rechercheService),
                        'Statistiques'
                      ),
                      title: 'Statistiques',
                      icon: Icon(Icons.bar_chart, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        GlobalAnalysisPage(rechercheService: rechercheService),
                        'Analyse Globale'
                      ),
                      title: 'Analyse Globale',
                      icon: Icon(Icons.analytics, color: Colors.grey.shade700),
                    ),
                  ],

                  // Menu Professeur
                  if (isProfesseur) ...[
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () {},
                      title: 'PROFESSEUR',
                      titleStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        CreateReservationPage(reservationService: reservationService, apiService: apiService),
                        'Nouvelle Réservation'
                      ),
                      title: 'Réserver une salle',
                      icon: Icon(Icons.add_circle, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        MyReservationsPage(reservationService: reservationService),
                        'Mes Réservations'
                      ),
                      title: 'Mes réservations',
                      icon: Icon(Icons.event, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        SearchCoursPage(rechercheService: rechercheService),
                        'Recherche Salles Cours'
                      ),
                      title: 'Chercher salle cours',
                      icon: Icon(Icons.search, color: Colors.grey.shade700),
                    ),
                  ],

                  // Menu Étudiant
                  if (isEtudiant) ...[
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () {},
                      title: 'ÉTUDIANT',
                      titleStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        SearchRevisionPage(rechercheService: rechercheService),
                        'Salles de Révision'
                      ),
                      title: 'Salles de révision',
                      icon: Icon(Icons.menu_book, color: Colors.grey.shade700),
                    ),
                    SideMenuItemDataTile(
                      isSelected: false,
                      onTap: () => _navigateTo(
                        SearchSallesPage(rechercheService: rechercheService),
                        'Recherche Avancée'
                      ),
                      title: 'Recherche multicritères',
                      icon: Icon(Icons.search, color: Colors.grey.shade700),
                    ),
                  ],

                  // Menu commun à tous
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () {},
                    title: 'DONNÉES',
                    titleStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      UniversiteListPage(authService: widget.authService),
                      'Universités'
                    ),
                    title: 'Universités',
                    icon: Icon(Icons.school, color: Colors.grey.shade700),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      CampusListPage(authService: widget.authService),
                      'Campus'
                    ),
                    title: 'Campus',
                    icon: Icon(Icons.location_city, color: Colors.grey.shade700),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      BatimentListPage(authService: widget.authService),
                      'Bâtiments'
                    ),
                    title: 'Bâtiments',
                    icon: Icon(Icons.apartment, color: Colors.grey.shade700),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      SalleListPage(authService: widget.authService),
                      'Salles'
                    ),
                    title: 'Salles',
                    icon: Icon(Icons.meeting_room, color: Colors.grey.shade700),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      ComposanteListPage(authService: widget.authService),
                      'Composantes'
                    ),
                    title: 'Composantes',
                    icon: Icon(Icons.business, color: Colors.grey.shade700),
                  ),
                  SideMenuItemDataTile(
                    isSelected: false,
                    onTap: () => _navigateTo(
                      isAdmin 
                        ? UEListPage(authService: widget.authService)
                        : isProfesseur
                          ? ProfesseurUEPage(authService: widget.authService)
                          : EtudiantUEPage(authService: widget.authService),
                      'Unités d\'Enseignement'
                    ),
                    title: 'UE',
                    icon: Icon(Icons.school_outlined, color: Colors.grey.shade700),
                  ),
                ],
                footer: Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red.shade700),
                    title: Text('Déconnexion', style: TextStyle(color: Colors.red.shade700)),
                    onTap: () async {
                      await widget.authService.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => AuthPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // AppBar personnalisée
                Container(
                  height: 60,
                  color: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _currentTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenu de la page
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
                    child: _currentPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
