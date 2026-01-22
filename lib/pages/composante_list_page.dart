import 'package:flutter/material.dart';
import '../models/composante.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'composante_details_page.dart';

class ComposanteListPage extends StatefulWidget {
  final AuthService authService;

  ComposanteListPage({required this.authService});

  @override
  _ComposanteListPageState createState() => _ComposanteListPageState();
}

class _ComposanteListPageState extends State<ComposanteListPage> {
  final ApiService _apiService = ApiService();
  List<Composante> _composanteList = [];
  List<Composante> _filteredComposanteList = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadComposantes();
  }

  Future<void> _loadComposantes() async {
    setState(() => _isLoading = true);
    try {
      final composantes = await _apiService.fetchComposantes();
      setState(() {
        _composanteList = composantes;
        _filteredComposanteList = composantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterComposantes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredComposanteList = _composanteList;
      } else {
        _filteredComposanteList = _composanteList.where((comp) {
          final acronymeMatch = comp.acronyme?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final nomMatch = comp.nom?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final responsableMatch = comp.responsable?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return acronymeMatch || nomMatch || responsableMatch;
        }).toList();
      }
    });
  }

  void _showEditDialog(Composante composante) async {
    final nomController = TextEditingController(text: composante.nom);
    final responsableController = TextEditingController(text: composante.responsable);
    String? selectedUniversite = composante.universiteId;
    List<String> universites = [];

    try {
      final univList = await _apiService.fetchUniversites();
      universites = univList.map((u) => u.acronyme ?? '').where((a) => a.isNotEmpty).toList();
    } catch (e) {
      // Ignore errors loading universities
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Modifier Composante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: composante.acronyme),
                  decoration: InputDecoration(labelText: 'Acronyme'),
                  enabled: false,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'Nom *'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: responsableController,
                  decoration: InputDecoration(labelText: 'Responsable *'),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedUniversite,
                  decoration: InputDecoration(labelText: 'Université'),
                  items: universites.map((univ) => DropdownMenuItem(value: univ, child: Text(univ))).toList(),
                  onChanged: (val) {
                    setStateDialog(() => selectedUniversite = val);
                  },
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
                final nom = nomController.text.trim();
                final responsable = responsableController.text.trim();

                if (nom.isEmpty || responsable.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  final updatedComposante = Composante(
                    acronyme: composante.acronyme,
                    nom: nom,
                    responsable: responsable,
                    universiteId: selectedUniversite,
                  );
                  await _apiService.updateComposante(updatedComposante);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Composante modifiée avec succès'), backgroundColor: Colors.green),
                  );
                  _loadComposantes();
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
      ),
    );
  }

  Future<void> _deleteComposante(String acronyme) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer la composante "$acronyme" ?'),
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
        await _apiService.deleteComposante(acronyme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Composante supprimée'), backgroundColor: Colors.green),
        );
        _loadComposantes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDialog() async {
    final acronymeController = TextEditingController();
    final nomController = TextEditingController();
    final responsableController = TextEditingController();
    String? selectedUniversite;
    List<String> universites = [];

    try {
      final univList = await _apiService.fetchUniversites();
      universites = univList.map((u) => u.acronyme ?? '').where((a) => a.isNotEmpty).toList();
    } catch (e) {
      // Ignore errors loading universities
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Nouvelle Composante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: acronymeController,
                  decoration: InputDecoration(labelText: 'Acronyme *'),
                ),
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(labelText: 'Nom *'),
                ),
                TextField(
                  controller: responsableController,
                  decoration: InputDecoration(labelText: 'Responsable'),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedUniversite,
                  decoration: InputDecoration(labelText: 'Université'),
                  items: universites.map((univ) => DropdownMenuItem(value: univ, child: Text(univ))).toList(),
                  onChanged: (val) {
                    setStateDialog(() => selectedUniversite = val);
                  },
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
                if (acronymeController.text.isEmpty || nomController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Acronyme et nom obligatoires')),
                  );
                  return;
                }

                try {
                  await _apiService.createComposante(Composante(
                    acronyme: acronymeController.text,
                    nom: nomController.text,
                    responsable: responsableController.text.isEmpty ? null : responsableController.text,
                    universiteId: selectedUniversite,
                  ));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Composante créée'), backgroundColor: Colors.green),
                  );
                  _loadComposantes();
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authService.isAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text('Composantes'),
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
            onPressed: _loadComposantes,
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
                      hintText: 'Rechercher une composante...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterComposantes,
                  ),
                ),
                Expanded(
                  child: _filteredComposanteList.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune composante trouvée',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredComposanteList.length,
                          itemBuilder: (ctx, index) {
                            final composante = _filteredComposanteList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.category, color: Colors.white),
                        ),
                        title: Text(
                          '${composante.acronyme} - ${composante.nom}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Responsable: ${composante.responsable ?? "N/A"}'),
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(composante),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteComposante(composante.acronyme ?? ''),
                                  ),
                                ],
                              )
                            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
