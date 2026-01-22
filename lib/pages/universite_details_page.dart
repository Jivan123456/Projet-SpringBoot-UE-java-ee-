import 'package:flutter/material.dart';
import '../models/universite.dart';
import '../models/campus.dart';
import '../models/batiment.dart';
import '../models/composante.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'campus_details_page.dart';
import 'batiment_details_page.dart';
import 'composante_details_page.dart';

class UniversiteDetailsPage extends StatefulWidget {
  final Universite universite;
  final AuthService authService;

  UniversiteDetailsPage({
    Key? key,
    required this.universite,
    required this.authService,
  }) : super(key: key);

  @override
  _UniversiteDetailsPageState createState() => _UniversiteDetailsPageState();
}

class _UniversiteDetailsPageState extends State<UniversiteDetailsPage> {
  final ApiService _apiService = ApiService();
  
  List<Campus> _campus = [];
  List<Batiment> _batiments = [];
  List<Composante> _composantes = [];
  List<Salle> _salles = [];
  
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
      // Charger les campus de cette université via l'endpoint spécifique
      _campus = await _apiService.fetchCampusByUniversite(widget.universite.acronyme ?? '');

      // Charger les composantes de cette université via l'endpoint spécifique
      _composantes = await _apiService.fetchComposantesByUniversite(widget.universite.acronyme ?? '');

      // Charger les bâtiments de ces campus
      final allBatiments = await _apiService.fetchBatiments();
      final campusIds = _campus.map((c) => c.nomC).toSet();
      _batiments = allBatiments.where((b) => campusIds.contains(b.campusId)).toList();

      // Charger les salles de ces bâtiments
      final allSalles = await _apiService.fetchSalles();
      final batimentCodes = _batiments.map((b) => b.codeB).toSet();
      _salles = allSalles.where((s) => batimentCodes.contains(s.batimentId)).toList();

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
        title: Text(widget.universite.acronyme ?? 'Université'),
        backgroundColor: Colors.blue,
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
                    // Carte principale de l'université
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
                                  backgroundColor: Colors.blue,
                                  radius: 30,
                                  child: Icon(Icons.school, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.universite.nom ?? 'Université',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        widget.universite.acronyme ?? '',
                                        style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Présidence: ${widget.universite.presidence}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                      Text(
                                        'Créée en ${widget.universite.creation}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                      ),
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

                    // Section: Campus (descente niveau 1)
                    Text(
                      'CAMPUS (${_campus.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    if (_campus.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucun campus'),
                        ),
                      )
                    else
                      ..._campus.map((campus) {
                        final batimentsDuCampus = _batiments.where((b) => b.campusId == campus.nomC).length;
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Icon(Icons.location_city, color: Colors.green),
                            ),
                            title: Text(campus.nomC ?? 'Campus'),
                            subtitle: Text('${campus.ville} • $batimentsDuCampus bâtiment(s)'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => CampusDetailsPage(
                                    campus: campus,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 24),

                    // Section: Composantes
                    Text(
                      'COMPOSANTES (${_composantes.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    if (_composantes.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune composante'),
                        ),
                      )
                    else
                      ..._composantes.map((composante) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade100,
                              child: Icon(Icons.category, color: Colors.purple),
                            ),
                            title: Text('${composante.acronyme} - ${composante.nom ?? "Composante"}'),
                            subtitle: Text('Responsable: ${composante.responsable ?? "N/A"}'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ComposanteDetailsPage(
                                    composante: composante,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 24),

                    // Section: Bâtiments (descente niveau 2)
                    Text(
                      'TOUS LES BÂTIMENTS (${_batiments.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    if (_batiments.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucun bâtiment'),
                        ),
                      )
                    else
                      ..._batiments.take(10).map((bat) {
                        final sallesDuBat = _salles.where((s) => s.batimentId == bat.codeB).length;
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Icon(Icons.apartment, color: Colors.orange, size: 20),
                            ),
                            title: Text('Bâtiment ${bat.codeB}'),
                            subtitle: Text('Campus ${bat.campusId} • Année: ${bat.anneeC} • $sallesDuBat salle(s)'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => BatimentDetailsPage(
                                    batiment: bat,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    if (_batiments.length > 10)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            '+ ${_batiments.length - 10} autres bâtiments',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    SizedBox(height: 24),

                    // Résumé statistique
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RÉSUMÉ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 12),
                            _buildStatRow(Icons.location_city, 'Campus', _campus.length.toString()),
                            _buildStatRow(Icons.category, 'Composantes', _composantes.length.toString()),
                            _buildStatRow(Icons.apartment, 'Bâtiments', _batiments.length.toString()),
                            _buildStatRow(Icons.meeting_room, 'Salles', _salles.length.toString()),
                            _buildStatRow(Icons.people, 'Capacité totale', '${_salles.fold<int>(0, (sum, s) => sum + (s.capacite ?? 0))} places'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
