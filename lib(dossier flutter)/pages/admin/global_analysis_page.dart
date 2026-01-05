import 'package:flutter/material.dart';
import '../../services/recherche_service.dart';

class GlobalAnalysisPage extends StatefulWidget {
  final RechercheService rechercheService;

  GlobalAnalysisPage({Key? key, required this.rechercheService}) : super(key: key);

  @override
  _GlobalAnalysisPageState createState() => _GlobalAnalysisPageState();
}

class _GlobalAnalysisPageState extends State<GlobalAnalysisPage> {
  Map<String, dynamic>? _analyse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyse();
  }

  Future<void> _loadAnalyse() async {
    setState(() => _isLoading = true);
    try {
      final analyse = await widget.rechercheService.getAnalyseGlobale();
      print('=== DEBUG ANALYSE GLOBALE ===');
      print('Données reçues: $analyse');
      print('Clés disponibles: ${analyse.keys.toList()}');
      print('=============================');
      setState(() {
        _analyse = analyse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_analyse == null) {
      return Center(
        child: Text('Aucune donnée disponible', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyse,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' Analyse Globale du Système',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 24),

            // Vue d'ensemble
            _SectionCard(
              title: ' Vue d\'ensemble',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.school,
                        label: 'Universités',
                        value: '${_analyse!['nombreTotalUniversites'] ?? 0}',
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.location_city,
                        label: 'Campus',
                        value: '${_analyse!['nombreTotalCampus'] ?? 0}',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.apartment,
                        label: 'Bâtiments',
                        value: '${_analyse!['nombreTotalBatiments'] ?? 0}',
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.meeting_room,
                        label: 'Salles',
                        value: '${_analyse!['nombreTotalSalles'] ?? 0}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _MetricCard(
                  icon: Icons.people,
                  label: 'Capacité Totale d\'Accueil',
                  value: '${_analyse!['capaciteTotale'] ?? 0} places',
                  color: Colors.red,
                ),
              ],
            ),

            SizedBox(height: 24),

            // Répartition par type
            if (_analyse!['repartitionParType'] != null) ...[
              _SectionCard(
                title: ' Répartition par Type de Salle',
                children: [
                  ..._buildTypeStats(_analyse!['repartitionParType']),
                ],
              ),
              SizedBox(height: 24),
            ],

          ],
        ),
      ),
    );
  }



  List<Widget> _buildTypeStats(Map<String, dynamic> repartition) {
    final types = repartition.keys.toList();
    return types.map((type) {
      final data = repartition[type];
      
      // Gérer le cas où data est un nombre simple ou une Map
      final int nombre;
      final int capacite;
      
      if (data is Map<String, dynamic>) {
        nombre = data['nombre'] ?? 0;
        capacite = data['capacite'] ?? 0;
      } else if (data is int) {
        nombre = data;
        capacite = 0;
      } else {
        nombre = 0;
        capacite = 0;
      }
      
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                type.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$nombre salles'),
                      if (capacite > 0)
                        Text('$capacite places', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: nombre / (_analyse!['nombreTotalSalles'] ?? 1),
                    backgroundColor: Colors.grey.shade300,
                    color: _getTypeColor(type),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'td':
        return Colors.blue;
      case 'tp':
        return Colors.green;
      case 'amphi':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
