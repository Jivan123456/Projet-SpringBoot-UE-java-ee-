import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../models/batiment.dart';
import '../models/campus.dart';
import '../models/universite.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'batiment_details_page.dart';
import 'campus_details_page.dart';

class SalleDetailsPage extends StatefulWidget {
  final Salle salle;
  final AuthService authService;

  SalleDetailsPage({
    Key? key,
    required this.salle,
    required this.authService,
  }) : super(key: key);

  @override
  _SalleDetailsPageState createState() => _SalleDetailsPageState();
}

class _SalleDetailsPageState extends State<SalleDetailsPage> {
  final ApiService _apiService = ApiService();
  
  Batiment? _batiment;
  Campus? _campus;
  Universite? _universite;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      // Charger le bâtiment parent
      final allBatiments = await _apiService.fetchBatiments();
      _batiment = allBatiments.firstWhere(
        (b) => b.codeB == widget.salle.batimentId,
        orElse: () => throw Exception('Bâtiment non trouvé'),
      );

      // Charger le campus parent du bâtiment
      final allCampus = await _apiService.fetchCampus();
      _campus = allCampus.firstWhere(
        (c) => c.nomC == _batiment!.campusId,
        orElse: () => throw Exception('Campus non trouvé'),
      );

      // Charger l'université parente du campus
      if (_campus!.universiteId != null) {
        final allUniversites = await _apiService.fetchUniversites();
        _universite = allUniversites.firstWhere(
          (u) => u.acronyme == _campus!.universiteId,
          orElse: () => throw Exception('Université non trouvée'),
        );
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salle ${widget.salle.numS}'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetails,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte principale de la salle
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  radius: 30,
                                  child: Icon(Icons.meeting_room, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Salle ${widget.salle.numS}',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      _buildInfoChip('Type', widget.salle.typeS?.toUpperCase() ?? 'N/A', Colors.blue),
                                      SizedBox(height: 4),
                                      _buildInfoChip('Capacité', '${widget.salle.capacite} places', Colors.green),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Fil d'Ariane (Breadcrumb) - Remontée complète
                    Text(
                      'LOCALISATION',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Université
                            if (_universite != null)
                              _buildHierarchyItem(
                                icon: Icons.school,
                                color: Colors.blue,
                                title: _universite!.nom ?? 'Université',
                                subtitle: _universite!.acronyme ?? '',
                                onTap: null, // Vous pouvez ajouter la navigation ici
                              ),
                            if (_universite != null)
                              _buildArrowDown(),
                            
                            // Campus
                            if (_campus != null)
                              _buildHierarchyItem(
                                icon: Icons.location_city,
                                color: Colors.green,
                                title: _campus!.nomC ?? 'Campus',
                                subtitle: 'Ville: ${_campus!.ville}',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => CampusDetailsPage(
                                        campus: _campus!,
                                        authService: widget.authService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            _buildArrowDown(),
                            
                            // Bâtiment
                            if (_batiment != null)
                              _buildHierarchyItem(
                                icon: Icons.apartment,
                                color: Colors.orange,
                                title: 'Bâtiment ${_batiment!.codeB}',
                                subtitle: 'Année: ${_batiment!.anneeC}',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => BatimentDetailsPage(
                                        batiment: _batiment!,
                                        authService: widget.authService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            _buildArrowDown(),
                            
                            // Salle actuelle
                            _buildHierarchyItem(
                              icon: Icons.meeting_room,
                              color: Colors.teal,
                              title: 'Salle ${widget.salle.numS}',
                              subtitle: 'Vous êtes ici',
                              onTap: null,
                              isCurrent: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Caractéristiques détaillées
                    Text(
                      'CARACTÉRISTIQUES',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 8),
                    Card(
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow('Numéro', widget.salle.numS ?? ''),
                            Divider(),
                            _buildDetailRow('Type de salle', widget.salle.typeS?.toUpperCase() ?? 'N/A'),
                            Divider(),
                            _buildDetailRow('Capacité', '${widget.salle.capacite} personnes'),
                            Divider(),
                            _buildDetailRow('Bâtiment', _batiment?.codeB ?? 'N/A'),
                            Divider(),
                            _buildDetailRow('Campus', _campus?.nomC ?? 'N/A'),
                            Divider(),
                            _buildDetailRow('Ville', _campus?.ville ?? 'N/A'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Réservations et cours (Professeur + UE)
                    Text(
                      'COURS ET RÉSERVATIONS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<List<dynamic>>(
                      future: _loadReservations(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.error_outline, color: Colors.red),
                              title: Text('Erreur de chargement'),
                            ),
                          );
                        }

                        final reservations = snapshot.data ?? [];
                        if (reservations.isEmpty) {
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.info_outline, color: Colors.grey),
                              title: Text('Aucune réservation'),
                            ),
                          );
                        }

                        return Column(
                          children: reservations.map<Widget>((res) {
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                title: Text(
                                  '${res['professeurPrenom']} ${res['professeurNom']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(res['ueNom'] ?? 'Pas d\'UE associée'),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (res['ueNom'] != null) ...[
                                          Row(
                                            children: [
                                              Icon(Icons.book, size: 20, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      res['ueNom'],
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      '${res['ueCredits']} ECTS • ${res['ueNbHeures']}h',
                                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                            SizedBox(width: 8),
                                            Text('${_formatDate(res['dateDebut'])} - ${_formatDate(res['dateFin'])}'),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.info, size: 16, color: Colors.grey),
                                            SizedBox(width: 8),
                                            Expanded(child: Text(res['motif'] ?? 'Aucun motif')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<List<dynamic>> _loadReservations() async {
    try {
      final reservations = await _apiService.fetchSalleReservations(widget.salle.numS ?? '');
      return reservations.map((r) => {
        'professeurNom': r.professeurNom,
        'professeurPrenom': r.professeurPrenom,
        'ueNom': r.ueNom,
        'ueCredits': r.ueCredits,
        'ueNbHeures': r.ueNbHeures,
        'dateDebut': r.dateDebut,
        'dateFin': r.dateFin,
        'motif': r.motif,
      }).toList();
    } catch (e) {
      print('Erreur chargement réservations: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isCurrent = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isCurrent ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 20,
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowDown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Icon(Icons.arrow_downward, color: Colors.grey.shade400, size: 20),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
