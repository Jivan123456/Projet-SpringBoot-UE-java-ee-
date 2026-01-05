import 'package:flutter/material.dart';
import '../models/ue.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'ue_details_page.dart';

class ProfesseurUEPage extends StatefulWidget {
  final AuthService authService;

  ProfesseurUEPage({required this.authService});

  @override
  _ProfesseurUEPageState createState() => _ProfesseurUEPageState();
}

class _ProfesseurUEPageState extends State<ProfesseurUEPage> {
  final ApiService _apiService = ApiService();
  List<UE> _mesUEs = [];
  List<UE> _autresUEs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('PROF UE PAGE - Token: ${widget.authService.token?.substring(0, 20)}...');
    print('PROF UE PAGE - User: ${widget.authService.currentUser?.email}');
    print('PROF UE PAGE - Roles: ${widget.authService.currentUser?.roles}');
    print('PROF UE PAGE - isProfesseur: ${widget.authService.currentUser?.isProfesseur}');
    _apiService.setToken(widget.authService.token);
    _loadUEs();
  }

  Future<void> _loadUEs() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.authService.currentUser?.id ?? 0;
      print('DEBUG Prof UE - User ID: $userId');
      
      // Charger mes UE
      _mesUEs = await _apiService.fetchUEsByProfesseur(userId);
      print('DEBUG Prof UE - Mes UE: ${_mesUEs.length}');
      
      // Charger toutes les UE pour pouvoir en ajouter
      final toutesUEs = await _apiService.fetchUEs();
      print('DEBUG Prof UE - Toutes les UE: ${toutesUEs.length}');
      
      _autresUEs = toutesUEs.where((ue) => !_mesUEs.any((mes) => mes.idUe == ue.idUe)).toList();
      print('DEBUG Prof UE - Autres UE disponibles: ${_autresUEs.length}');
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('DEBUG Prof UE - Erreur: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showAddUEDialog() async {
    if (_autresUEs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucune UE disponible à ajouter')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajouter une UE'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _autresUEs.length,
            itemBuilder: (ctx, index) {
              final ue = _autresUEs[index];
              return ListTile(
                leading: Icon(Icons.book, color: Colors.teal),
                title: Text(ue.nom ?? 'UE'),
                subtitle: Text('${ue.credits} crédits • ${ue.nbHeures}h'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    final userId = widget.authService.currentUser?.id ?? 0;
                    await _apiService.assignProfesseurToUE(ue.idUe ?? 0, userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('UE ajoutée à votre liste'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUEs();
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
  }

  Future<void> _removeUE(UE ue) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Retirer l\'UE'),
        content: Text('Êtes-vous sûr de vouloir vous retirer de "${ue.nom}" ?'),
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
        final userId = widget.authService.currentUser?.id ?? 0;
        await _apiService.removeProfesseurFromUE(ue.idUe ?? 0, userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('UE retirée de votre liste'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUEs();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes UE'),
        backgroundColor: Colors.teal,
        actions: [
          // Badge rôle
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Chip(
              avatar: Icon(Icons.school, color: Colors.white, size: 16),
              label: Text(
                'PROFESSEUR',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Colors.blue,
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
          : RefreshIndicator(
              onRefresh: _loadUEs,
              child: _mesUEs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune UE assignée',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cliquez sur + pour ajouter une UE',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _mesUEs.length,
                      itemBuilder: (ctx, index) {
                        final ue = _mesUEs[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.book, color: Colors.white),
                            ),
                            title: Text(
                              ue.nom ?? 'UE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${ue.credits ?? 0} crédits • ${ue.nbHeures ?? 0}h\n${ue.composanteAcronyme ?? ""}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeUE(ue),
                                  tooltip: 'Me retirer de cette UE',
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => UEDetailsPage(
                                    ue: ue,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUEDialog,
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        tooltip: 'Ajouter une UE',
      ),
    );
  }
}
