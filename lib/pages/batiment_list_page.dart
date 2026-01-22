import 'package:flutter/material.dart';
import '../models/batiment.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'batiment_details_page.dart';

class BatimentListPage extends StatefulWidget {
  final AuthService authService;

  BatimentListPage({required this.authService});

  @override
  _BatimentListPageState createState() => _BatimentListPageState();
}

class _BatimentListPageState extends State<BatimentListPage> {
  final ApiService _apiService = ApiService();
  List<Batiment> _batimentList = [];
  List<Batiment> _filteredBatimentList = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadBatiments();
  }

  Future<void> _loadBatiments() async {
    setState(() => _isLoading = true);
    try {
      final batiments = await _apiService.fetchBatiments();
      setState(() {
        _batimentList = batiments;
        _filteredBatimentList = batiments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterBatiments(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBatimentList = _batimentList;
      } else {
        _filteredBatimentList = _batimentList.where((bat) {
          final codeBMatch = bat.codeB?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final campusMatch = bat.campusId?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final anneeMatch = bat.anneeC?.toString().contains(query) ?? false;
          return codeBMatch || campusMatch || anneeMatch;
        }).toList();
      }
    });
  }

  void _showEditDialog(Batiment batiment) {
    final anneeCController = TextEditingController(text: batiment.anneeC?.toString() ?? '');
    final campusIdController = TextEditingController(text: batiment.campusId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier Bâtiment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: batiment.codeB),
                decoration: InputDecoration(labelText: 'Code Bâtiment'),
                enabled: false,
              ),
              SizedBox(height: 8),
              TextField(
                controller: anneeCController,
                decoration: InputDecoration(labelText: 'Année Construction *'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: campusIdController,
                decoration: InputDecoration(labelText: 'Nom Campus *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final anneeC = int.tryParse(anneeCController.text.trim());
              final campusId = campusIdController.text.trim();

              if (anneeC == null || campusId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tous les champs sont obligatoires'), backgroundColor: Colors.orange),
                );
                return;
              }

              try {
                final updatedBatiment = Batiment(
                  codeB: batiment.codeB,
                  anneeC: anneeC,
                  campusId: campusId,
                );
                await _apiService.updateBatiment(updatedBatiment);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bâtiment modifié avec succès'), backgroundColor: Colors.green),
                );
                _loadBatiments();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBatiment(String codeB) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer le bâtiment "$codeB" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteBatiment(codeB);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bâtiment supprimé'), backgroundColor: Colors.green),
        );
        _loadBatiments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDialog() {
    final codeBController = TextEditingController();
    final anneeCController = TextEditingController();
    final campusIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouveau Bâtiment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeBController,
                decoration: InputDecoration(labelText: 'Code Bâtiment *'),
              ),
              TextField(
                controller: anneeCController,
                decoration: InputDecoration(labelText: 'Année Construction *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: campusIdController,
                decoration: InputDecoration(labelText: 'Nom Campus *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeBController.text.isEmpty || 
                  anneeCController.text.isEmpty || 
                  campusIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tous les champs sont obligatoires')),
                );
                return;
              }

              try {
                await _apiService.createBatiment(Batiment(
                  codeB: codeBController.text,
                  anneeC: int.parse(anneeCController.text),
                  campusId: campusIdController.text,
                ));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bâtiment créé'), backgroundColor: Colors.green),
                );
                _loadBatiments();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authService.isAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bâtiments'),
        backgroundColor: Colors.indigo,
        actions: [
          // Badge rôle
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              avatar: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.school,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                widget.authService.currentUser?.roleDisplay ?? 'INVITÉ',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: isAdmin ? Colors.red : Colors.blue,
            ),
          ),
          // Bouton refresh
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBatiments,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un bâtiment...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterBatiments,
                  ),
                ),
                Expanded(
                  child: _filteredBatimentList.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun bâtiment trouvé',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredBatimentList.length,
                          itemBuilder: (ctx, index) {
                            final batiment = _filteredBatimentList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(
                          batiment.codeB ?? 'Bâtiment',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Année: ${batiment.anneeC}\nCampus: ${batiment.campusId}'),
                        isThreeLine: true,
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(batiment),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBatiment(batiment.codeB ?? ''),
                                  ),
                                ],
                              )
                            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => BatimentDetailsPage(
                                batiment: batiment,
                                authService: widget.authService,
                              ),
                            ),
                          );
                        },
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
