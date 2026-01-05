import 'package:flutter/material.dart';
import '../models/composante.dart';
import '../models/campus.dart';
import '../models/universite.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'campus_details_page.dart';
import 'universite_details_page.dart';

class ComposanteDetailsPage extends StatefulWidget {
  final Composante composante;
  final AuthService authService;

  ComposanteDetailsPage({
    Key? key,
    required this.composante,
    required this.authService,
  }) : super(key: key);

  @override
  _ComposanteDetailsPageState createState() => _ComposanteDetailsPageState();
}

class _ComposanteDetailsPageState extends State<ComposanteDetailsPage> {
  final ApiService _apiService = ApiService();
  
  List<Campus> _campusAssocies = [];
  List<Universite> _universitesAssociees = [];
  
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
      // Charger les campus associés à cette composante via l'API
      _campusAssocies = await _apiService.fetchCampusByComposante(widget.composante.acronyme ?? '');
      
      // Charger l'université de cette composante
      if (widget.composante.universiteId != null && widget.composante.universiteId!.isNotEmpty) {
        try {
          final allUniversites = await _apiService.fetchUniversites();
          _universitesAssociees = allUniversites.where((u) => u.acronyme == widget.composante.universiteId).toList();
        } catch (e) {
          _universitesAssociees = [];
        }
      } else {
        _universitesAssociees = [];
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
        title: Text(widget.composante.acronyme ?? 'Composante'),
        backgroundColor: Colors.purple,
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
                    // Carte principale de la composante
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
                                  backgroundColor: Colors.purple,
                                  radius: 30,
                                  child: Icon(Icons.business, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.composante.acronyme ?? 'Composante',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        widget.composante.nom ?? '',
                                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                      ),
                                      if (widget.composante.responsable != null) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.person, size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              'Responsable: ${widget.composante.responsable}',
                                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
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

                    // Section: Université de rattachement
                    Text(
                      'UNIVERSITÉ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                    SizedBox(height: 8),
                    if (_universitesAssociees.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune université associée'),
                        ),
                      )
                    else
                      ..._universitesAssociees.map((univ) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.school, color: Colors.blue),
                            ),
                            title: Text(univ.nom ?? 'Université'),
                            subtitle: Text('${univ.acronyme} • Créée en ${univ.creation}'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => UniversiteDetailsPage(
                                    universite: univ,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 24),

              
                    // Section: Campus associés
                    Text(
                      'CAMPUS ASSOCIÉS (${_campusAssocies.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                    ),
                    SizedBox(height: 8),
                    if (_campusAssocies.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucun campus associé'),
                        ),
                      )
                    else
                      ..._campusAssocies.map((campus) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Icon(Icons.location_city, color: Colors.green),
                            ),
                            title: Text(campus.nomC ?? 'Campus'),
                            subtitle: Text('Ville: ${campus.ville}'),
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

                    // Résumé statistique
                    Card(
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RÉSUMÉ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                            SizedBox(height: 12),
                            _buildStatRow(Icons.school, 'Universités', _universitesAssociees.length.toString()),
                            _buildStatRow(Icons.location_city, 'Campus exploités', _campusAssocies.length.toString()),
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
          Icon(icon, size: 20, color: Colors.purple),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
