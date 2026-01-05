import 'package:flutter/material.dart';
import '../models/campus.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'campus_details_page.dart';

class CampusListPage extends StatefulWidget {
  final AuthService authService;

  CampusListPage({required this.authService});

  @override
  _CampusListPageState createState() => _CampusListPageState();
}

class _CampusListPageState extends State<CampusListPage> {
  final ApiService _apiService = ApiService();
  List<Campus> _campusList = [];
  List<Campus> _filteredCampusList = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadCampus();
  }

  Future<void> _loadCampus() async {
    setState(() => _isLoading = true);
    try {
      final campusList = await _apiService.fetchCampus();
      setState(() {
        _campusList = campusList;
        _filteredCampusList = campusList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterCampus(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCampusList = _campusList;
      } else {
        _filteredCampusList = _campusList.where((campus) {
          final nomMatch = campus.nomC?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final villeMatch = campus.ville?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final universiteMatch = campus.universiteId?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return nomMatch || villeMatch || universiteMatch;
        }).toList();
      }
    });
  }

  void _showEditDialog(Campus campus) {
    final villeController = TextEditingController(text: campus.ville);
    final universiteController = TextEditingController(text: campus.universiteId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier Campus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: campus.nomC),
                decoration: InputDecoration(labelText: 'Nom Campus'),
                enabled: false,
              ),
              SizedBox(height: 8),
              TextField(
                controller: villeController,
                decoration: InputDecoration(labelText: 'Ville *'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: universiteController,
                decoration: InputDecoration(labelText: 'Acronyme Université *'),
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
              final ville = villeController.text.trim();
              final universiteId = universiteController.text.trim();

              if (ville.isEmpty || universiteId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tous les champs sont obligatoires'), backgroundColor: Colors.orange),
                );
                return;
              }

              try {
                final updatedCampus = Campus(
                  nomC: campus.nomC,
                  ville: ville,
                  universiteId: universiteId,
                );
                await _apiService.updateCampus(updatedCampus);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Campus modifié avec succès'), backgroundColor: Colors.green),
                );
                _loadCampus();
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

  Future<void> _deleteCampus(String nomC) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer le campus "$nomC" ?'),
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
        await _apiService.deleteCampus(nomC);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campus supprimé'), backgroundColor: Colors.green),
        );
        _loadCampus();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDialog() {
    final nomCController = TextEditingController();
    final villeController = TextEditingController();
    final universiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouveau Campus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCController,
                decoration: InputDecoration(labelText: 'Nom Campus *'),
              ),
              TextField(
                controller: villeController,
                decoration: InputDecoration(labelText: 'Ville *'),
              ),
              TextField(
                controller: universiteController,
                decoration: InputDecoration(labelText: 'ID Université'),
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
              if (nomCController.text.isEmpty || villeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nom et ville obligatoires')),
                );
                return;
              }

              try {
                await _apiService.createCampus(Campus(
                  nomC: nomCController.text,
                  ville: villeController.text,
                  universiteId: universiteController.text.isEmpty ? null : universiteController.text,
                ));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Campus créé'), backgroundColor: Colors.green),
                );
                _loadCampus();
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
        title: Text('Campus'),
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
            onPressed: _loadCampus,
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
                      hintText: 'Rechercher un campus...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterCampus,
                  ),
                ),
                Expanded(
                  child: _filteredCampusList.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun campus trouvé',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredCampusList.length,
                          itemBuilder: (ctx, index) {
                            final campus = _filteredCampusList[index];
                            return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.location_city, color: Colors.white),
                        ),
                        title: Text(
                          campus.nomC ?? 'Campus',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Ville: ${campus.ville}\nUniversité: ${campus.universiteId ?? "N/A"}'),
                        isThreeLine: true,
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(campus),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteCampus(campus.nomC ?? ''),
                                  ),
                                ],
                              )
                            : null,
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
