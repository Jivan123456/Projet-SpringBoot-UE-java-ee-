import 'package:flutter/material.dart';
import '../models/ue.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UEDetailsPage extends StatefulWidget {
  final UE ue;
  final AuthService authService;

  UEDetailsPage({
    Key? key,
    required this.ue,
    required this.authService,
  }) : super(key: key);

  @override
  _UEDetailsPageState createState() => _UEDetailsPageState();
}

class _UEDetailsPageState extends State<UEDetailsPage> {
  final ApiService _apiService = ApiService();
  List<User> _professeurs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadProfesseurs();
  }

  Future<void> _loadProfesseurs() async {
    setState(() => _isLoading = true);
    try {
      _professeurs = await _apiService.fetchProfesseursByUE(widget.ue.idUe ?? 0);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showAddProfesseurDialog() async {
    try {
      // Charger tous les professeurs
      final allUsers = await _apiService.fetchUsers();
      final allProfesseurs = allUsers.where((u) => u.roles?.contains('ROLE_PROFESSEUR') ?? false).toList();
      
      // Filtrer ceux qui ne sont pas déjà assignés
      final professeursDisponibles = allProfesseurs
          .where((p) => !_professeurs.any((existing) => existing.id == p.id))
          .toList();

      if (professeursDisponibles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tous les professeurs sont déjà assignés à cette UE')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Assigner un professeur'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: professeursDisponibles.length,
              itemBuilder: (ctx, index) {
                final prof = professeursDisponibles[index];
                return ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text(prof.displayName),
                  subtitle: Text(prof.email ?? 'Email non défini'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await _apiService.assignProfesseurToUE(
                        widget.ue.idUe ?? 0,
                        prof.id ?? 0,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Professeur assigné avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadProfesseurs();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Annuler'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeProfesseur(int professeurId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Retirer le professeur'),
        content: Text('Êtes-vous sûr de vouloir retirer ce professeur de cette UE ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Retirer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.removeProfesseurFromUE(widget.ue.idUe ?? 0, professeurId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professeur retiré'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProfesseurs();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authService.isAdmin();
    final isProfesseur = widget.authService.isProfesseur();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ue.nom ?? 'UE'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfesseurs,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte principale de l'UE
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
                                  backgroundColor: Colors.teal,
                                  radius: 30,
                                  child: Icon(Icons.book, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.ue.nom ?? 'UE',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${widget.ue.credits ?? 0} crédits • ${widget.ue.nbHeures ?? 0}h',
                                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.ue.description != null) ...[
                              SizedBox(height: 16),
                              Text(
                                'Description',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(widget.ue.description ?? ''),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Section: Professeurs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PROFESSEURS (${_professeurs.length})',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        if (isAdmin || isProfesseur)
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () => _showAddProfesseurDialog(),
                            tooltip: 'Assigner un professeur',
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_professeurs.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucun professeur assigné'),
                          subtitle: (isAdmin || isProfesseur)
                              ? Text('Cliquez sur + pour assigner un professeur', style: TextStyle(fontSize: 12))
                              : null,
                        ),
                      )
                    else
                      ..._professeurs.map((prof) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(prof.displayName),
                            subtitle: Text(prof.email ?? 'Email non défini'),
                            trailing: (isAdmin || isProfesseur)
                                ? IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeProfesseur(prof.id ?? 0),
                                    tooltip: 'Retirer',
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}
