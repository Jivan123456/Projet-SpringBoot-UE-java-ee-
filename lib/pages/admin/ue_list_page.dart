import 'package:flutter/material.dart';
import '../../models/ue.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class UEListPage extends StatefulWidget {
  final AuthService authService;

  UEListPage({required this.authService});

  @override
  _UEListPageState createState() => _UEListPageState();
}

class _UEListPageState extends State<UEListPage> {
  final ApiService _apiService = ApiService();
  List<UE> _ueList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadUEs();
  }

  Future<void> _loadUEs() async {
    setState(() => _isLoading = true);
    try {
      final ues = await _apiService.fetchUEs();
      setState(() {
        _ueList = ues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUE(int idUe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer cette UE ?'),
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
        await _apiService.deleteUE(idUe);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('UE supprimée'), backgroundColor: Colors.green),
        );
        _loadUEs();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDialog() {
    final nomController = TextEditingController();
    final descriptionController = TextEditingController();
    final nbHeuresController = TextEditingController();
    final creditsController = TextEditingController();
    final composanteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouvelle UE'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom de l\'UE *'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: nbHeuresController,
                decoration: InputDecoration(labelText: 'Nombre d\'heures *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: creditsController,
                decoration: InputDecoration(labelText: 'Crédits ECTS *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: composanteController,
                decoration: InputDecoration(labelText: 'Acronyme Composante *'),
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
              if (nomController.text.isEmpty ||
                  nbHeuresController.text.isEmpty ||
                  creditsController.text.isEmpty ||
                  composanteController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }

              try {
                final ue = UE(
                  idUe: 0,
                  nom: nomController.text,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  nbHeures: int.parse(nbHeuresController.text),
                  credits: int.parse(creditsController.text),
                  composanteAcronyme: composanteController.text,
                );

                await _apiService.createUE(ue);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('UE créée avec succès'), backgroundColor: Colors.green),
                );
                _loadUEs();
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
        title: Text('Unités d\'Enseignement'),
        backgroundColor: Colors.deepPurple,
        actions: [
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUEs,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ueList.isEmpty
              ? Center(
                  child: Text(
                    'Aucune UE',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _ueList.length,
                  itemBuilder: (ctx, index) {
                    final ue = _ueList[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text(
                          ue.nom ?? 'UE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${ue.credits} ECTS • ${ue.nbHeures}h • ${ue.composanteAcronyme}'),
                        trailing: isAdmin
                            ? IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUE(ue.idUe ?? 0),
                              )
                            : null,
                        children: [
                          if (ue.description != null && ue.description!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(ue.description!),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
