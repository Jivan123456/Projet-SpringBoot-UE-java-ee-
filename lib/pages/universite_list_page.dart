import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/universite.dart';
import 'add_universite_page.dart';
import 'universite_details_page.dart';

class UniversiteListPage extends StatefulWidget {
  final AuthService? authService;

  UniversiteListPage({this.authService});

  @override
  _UniversiteListPageState createState() => _UniversiteListPageState();
}

class _UniversiteListPageState extends State<UniversiteListPage> {
  final ApiService apiService = ApiService();
  late Future<List<Universite>> _universitesFuture;
  List<Universite> _allUniversites = [];
  List<Universite> _filteredUniversites = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.authService != null) {
      apiService.setToken(widget.authService!.token);
    }
    _loadUniversites();
  }

  void _loadUniversites() {
    setState(() {
      _universitesFuture = apiService.fetchUniversites();
    });
  }

  void _filterUniversites(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUniversites = _allUniversites;
      } else {
        _filteredUniversites = _allUniversites.where((univ) {
          final nomMatch = univ.nom?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final acronymeMatch = univ.acronyme?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final presidenceMatch = univ.presidence?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return nomMatch || acronymeMatch || presidenceMatch;
        }).toList();
      }
    });
  }

  void _navigateToAddPage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AddUniversitePage()),
    );

    if (result == true) {
      _loadUniversites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService?.currentUser;
    final isAdmin = widget.authService?.isAdmin() ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Universités'),
        backgroundColor: Colors.indigo,
        actions: [
          // Badge rôle
          if (widget.authService != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                avatar: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.school,
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  user?.roleDisplay ?? 'INVITÉ',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: isAdmin ? Colors.red : Colors.blue,
              ),
            ),
          // Bouton refresh
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUniversites,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une université...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterUniversites,
            ),
          ),
          // Liste des universités
          Expanded(
            child: FutureBuilder<List<Universite>>(
              future: _universitesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  _allUniversites = snapshot.data!;
                  if (_searchQuery.isEmpty) {
                    _filteredUniversites = _allUniversites;
                  }
                  if (_filteredUniversites.isEmpty) {
                    return Center(child: Text('Aucune université trouvée.'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: _filteredUniversites.length,
                    itemBuilder: (context, index) {
                      return _buildUniversiteCard(_filteredUniversites[index]);
                    },
                  );
                }
                return Center(child: Text('Démarrage...'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToAddPage,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.add),
              tooltip: 'Ajouter Université',
            )
          : null,
    );
  }

  Widget _buildUniversiteCard(Universite universite) {
    final isAdmin = widget.authService?.isAdmin() ?? false;
    
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => UniversiteDetailsPage(
                universite: universite,
                authService: widget.authService!,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${universite.nom} (${universite.acronyme})',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8.0),
                    Text('Présidence: ${universite.presidence}'),
                    SizedBox(height: 4.0),
                    Text('Année de création: ${universite.creation}'),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  if (isAdmin) ...[
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(universite),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUniversite(universite),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Universite universite) {
    final nomController = TextEditingController(text: universite.nom);
    final presidenceController = TextEditingController(text: universite.presidence);
    final creationController = TextEditingController(text: universite.creation?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modifier Université'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: universite.acronyme),
                decoration: InputDecoration(labelText: 'Acronyme (non modifiable)'),
                enabled: false,
              ),
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom *'),
              ),
              TextField(
                controller: presidenceController,
                decoration: InputDecoration(labelText: 'Présidence *'),
              ),
              TextField(
                controller: creationController,
                decoration: InputDecoration(labelText: 'Année de création *'),
                keyboardType: TextInputType.number,
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
              if (nomController.text.isEmpty || 
                  presidenceController.text.isEmpty || 
                  creationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tous les champs sont obligatoires')),
                );
                return;
              }

              try {
                await apiService.updateUniversite(Universite(
                  acronyme: universite.acronyme,
                  nom: nomController.text,
                  presidence: presidenceController.text,
                  creation: int.parse(creationController.text),
                ));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Université modifiée'), backgroundColor: Colors.green),
                );
                _loadUniversites();
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

  Future<void> _deleteUniversite(Universite universite) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'université "${universite.nom}" ?\n\nCette action supprimera aussi tous les campus, bâtiments et salles associés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await apiService.deleteUniversite(universite.acronyme ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Université supprimée avec succès'), backgroundColor: Colors.green),
        );
        _loadUniversites();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
