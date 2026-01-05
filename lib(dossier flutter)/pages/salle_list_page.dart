import 'package:flutter/material.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'salle_details_page.dart';

class SalleListPage extends StatefulWidget {
  final AuthService authService;

  SalleListPage({required this.authService});

  @override
  _SalleListPageState createState() => _SalleListPageState();
}

class _SalleListPageState extends State<SalleListPage> {
  final ApiService _apiService = ApiService();
  List<Salle> _salleList = [];
  List<Salle> _filteredSalleList = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadSalles();
  }

  Future<void> _loadSalles() async {
    setState(() => _isLoading = true);
    try {
      final salles = await _apiService.fetchSalles();
      setState(() {
        _salleList = salles;
        _filteredSalleList = salles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _filterSalles(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSalleList = _salleList;
      } else {
        _filteredSalleList = _salleList.where((salle) {
          final numSMatch = salle.numS?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final typeMatch = salle.typeS?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final batimentMatch = salle.batimentId?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final capaciteMatch = salle.capacite?.toString().contains(query) ?? false;
          return numSMatch || typeMatch || batimentMatch || capaciteMatch;
        }).toList();
      }
    });
  }

  void _showEditDialog(Salle salle) {
    final capaciteController = TextEditingController(text: salle.capacite?.toString() ?? '');
    final accesController = TextEditingController(text: salle.acces);
    final batimentIdController = TextEditingController(text: salle.batimentId);
    String selectedType = salle.typeS ?? 'AMPHI';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Modifier Salle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: salle.numS),
                  decoration: InputDecoration(labelText: 'Numéro Salle'),
                  enabled: false,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: capaciteController,
                  decoration: InputDecoration(labelText: 'Capacité *'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Type de Salle *'),
                  items: ['AMPHI', 'COURS', 'TD', 'TP', 'BUREAU', 'REUNION', 'BIBLIOTHEQUE', 'AUTRE']
                      .map((type) => DropdownMenuItem(value: type, child: Text(_getTypeDescription(type))))
                      .toList(),
                  onChanged: (val) {
                    setStateDialog(() => selectedType = val ?? 'AMPHI');
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  controller: accesController,
                  decoration: InputDecoration(labelText: 'Accès *'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: batimentIdController,
                  decoration: InputDecoration(labelText: 'Code Bâtiment *'),
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
                final capacite = int.tryParse(capaciteController.text.trim());
                final acces = accesController.text.trim();
                final batimentId = batimentIdController.text.trim();

                if (capacite == null || acces.isEmpty || batimentId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  final updatedSalle = Salle(
                    numS: salle.numS,
                    capacite: capacite,
                    typeS: selectedType,
                    acces: acces,
                    batimentId: batimentId,
                  );
                  await _apiService.updateSalle(updatedSalle);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Salle modifiée avec succès'), backgroundColor: Colors.green),
                  );
                  _loadSalles();
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

  Future<void> _deleteSalle(String numS) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer la salle "$numS" ?'),
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
        await _apiService.deleteSalle(numS);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Salle supprimée'), backgroundColor: Colors.green),
        );
        _loadSalles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDialog() {
    final numSController = TextEditingController();
    final capaciteController = TextEditingController();
    final accesController = TextEditingController();
    final batimentIdController = TextEditingController();
    String selectedType = 'AMPHI';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Nouvelle Salle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numSController,
                  decoration: InputDecoration(labelText: 'Numéro Salle *'),
                ),
                TextField(
                  controller: capaciteController,
                  decoration: InputDecoration(labelText: 'Capacité *'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Type *'),
                  items: TypeSalle.values.map((type) {
                    return DropdownMenuItem(
                      value: type.name,
                      child: Text(type.description),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedType = value!;
                    });
                  },
                ),
                TextField(
                  controller: accesController,
                  decoration: InputDecoration(labelText: 'Accès'),
                ),
                TextField(
                  controller: batimentIdController,
                  decoration: InputDecoration(labelText: 'Code Bâtiment *'),
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
                if (numSController.text.isEmpty || 
                    capaciteController.text.isEmpty || 
                    batimentIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Numéro, capacité et bâtiment obligatoires')),
                  );
                  return;
                }

                try {
                  await _apiService.createSalle(Salle(
                    numS: numSController.text,
                    capacite: int.parse(capaciteController.text),
                    typeS: selectedType,
                    acces: accesController.text.isEmpty ? null : accesController.text,
                    batimentId: batimentIdController.text,
                  ));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Salle créée'), backgroundColor: Colors.green),
                  );
                  _loadSalles();
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

  String _getTypeDescription(String typeCode) {
    try {
      return TypeSalle.values.firstWhere((t) => t.name == typeCode).description;
    } catch (e) {
      return typeCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authService.isAdmin();

    return Scaffold(
      appBar: AppBar(
        title: Text('Salles'),
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
            onPressed: _loadSalles,
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
                      hintText: 'Rechercher une salle...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _filterSalles,
                  ),
                ),
                Expanded(
                  child: _filteredSalleList.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune salle trouvée',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredSalleList.length,
                          itemBuilder: (ctx, index) {
                            final salle = _filteredSalleList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.meeting_room, color: Colors.white),
                        ),
                        title: Text(
                          'Salle ${salle.numS}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Type: ${_getTypeDescription(salle.typeS ?? 'N/A')}\n'
                          'Capacité: ${salle.capacite}\n'
                          'Bâtiment: ${salle.batimentId}',
                        ),
                        isThreeLine: true,
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditDialog(salle),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteSalle(salle.numS ?? ''),
                                  ),
                                ],
                              )
                            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => SalleDetailsPage(
                                salle: salle,
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
