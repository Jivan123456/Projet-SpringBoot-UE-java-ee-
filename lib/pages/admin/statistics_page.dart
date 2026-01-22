import 'package:flutter/material.dart';
import '../../services/recherche_service.dart';

class StatisticsPage extends StatefulWidget {
  final RechercheService rechercheService;

  StatisticsPage({Key? key, required this.rechercheService}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Salles'),
              Tab(text: 'Campus'),
              Tab(text: 'Bâtiments'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _StatsSalles(rechercheService: widget.rechercheService),
              _StatsCampus(rechercheService: widget.rechercheService),
              _StatsBatiments(rechercheService: widget.rechercheService),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _StatsSalles extends StatefulWidget {
  final RechercheService rechercheService;

  const _StatsSalles({required this.rechercheService});

  @override
  __StatsSallesState createState() => __StatsSallesState();
}

class __StatsSallesState extends State<_StatsSalles> {
  List<Map<String, dynamic>> _statsVilleType = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.rechercheService.getStatsByVilleType();
      setState(() {
        _statsVilleType = stats;
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

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Statistiques par Ville et Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._statsVilleType.map((stat) {
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text(
                    '${stat['nombreSalles'] ?? 0}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  '${stat['ville'] ?? 'N/A'} - ${stat['type'] ?? 'N/A'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Capacité totale: ${stat['capaciteTotale'] ?? 0} places',
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatsCampus extends StatefulWidget {
  final RechercheService rechercheService;

  const _StatsCampus({required this.rechercheService});

  @override
  __StatsCampusState createState() => __StatsCampusState();
}

class __StatsCampusState extends State<_StatsCampus> {
  List<Map<String, dynamic>> _statsCampus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.rechercheService.getStatsCampus();
      setState(() {
        _statsCampus = stats;
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

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            ' Statistiques des Campus',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._statsCampus.map((stat) {
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['campus']?.toString() ?? 'N/A',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.apartment,
                            label: 'Bâtiments',
                            value: '${stat['nombreBatiments'] ?? 0}',
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.meeting_room,
                            label: 'Salles',
                            value: '${stat['nombreSalles'] ?? 0}',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.people,
                      label: 'Capacité totale',
                      value: '${stat['capaciteTotale'] ?? 0} places',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatsBatiments extends StatefulWidget {
  final RechercheService rechercheService;

  const _StatsBatiments({required this.rechercheService});

  @override
  __StatsBatimentsState createState() => __StatsBatimentsState();
}

class __StatsBatimentsState extends State<_StatsBatiments> {
  List<Map<String, dynamic>> _statsBatiments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.rechercheService.getStatsBatiments();
      setState(() {
        _statsBatiments = stats;
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

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            ' Statistiques des Bâtiments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._statsBatiments.map((stat) {
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.apartment, color: Colors.white),
                ),
                title: Text(
                  stat['batiment']?.toString() ?? 'N/A',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${stat['campusNom'] ?? 'N/A'}'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.meeting_room,
                                label: 'Salles',
                                value: '${stat['nombreSalles'] ?? 0}',
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.people,
                                label: 'Capacité',
                                value: '${stat['capaciteTotale'] ?? 0}',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (stat['anneeConstruction'] != null) ...[
                          SizedBox(height: 12),
                          _StatCard(
                            icon: Icons.calendar_today,
                            label: 'Année de construction',
                            value: '${stat['anneeConstruction']}',
                            color: Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
