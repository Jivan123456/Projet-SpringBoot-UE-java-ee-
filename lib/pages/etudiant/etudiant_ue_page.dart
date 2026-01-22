import 'package:flutter/material.dart';
import '../../models/ue.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class EtudiantUEPage extends StatefulWidget {
  final AuthService authService;

  EtudiantUEPage({required this.authService});

  @override
  _EtudiantUEPageState createState() => _EtudiantUEPageState();
}

class _EtudiantUEPageState extends State<EtudiantUEPage> {
  final ApiService _apiService = ApiService();
  List<UE> _mesUEs = [];
  List<UE> _autresUEs = [];
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
      final userId = widget.authService.currentUser?.id ?? 0;
      final mesUEs = await _apiService.fetchUEsByEtudiant(userId);
      final toutesUEs = await _apiService.fetchUEs();
      
      final mesUEsIds = mesUEs.map((ue) => ue.idUe).toSet();
      final autresUEs = toutesUEs.where((ue) => !mesUEsIds.contains(ue.idUe)).toList();
      
      setState(() {
        _mesUEs = mesUEs;
        _autresUEs = autresUEs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _enrollUE(UE ue) async {
    try {
      final userId = widget.authService.currentUser?.id ?? 0;
      await _apiService.studentEnrollUE(ue.idUe ?? 0, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie'), backgroundColor: Colors.green),
      );
      _loadUEs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _unenrollUE(UE ue) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Se désinscrire'),
        content: Text('Voulez-vous vous désinscrire de "${ue.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Se désinscrire', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final userId = widget.authService.currentUser?.id ?? 0;
        await _apiService.studentUnenrollUE(ue.idUe ?? 0, userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Désinscription réussie'), backgroundColor: Colors.green),
        );
        _loadUEs();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  int _getTotalCredits() {
    return _mesUEs.fold(0, (sum, ue) => sum + (ue.credits ?? 0));
  }

  int _getTotalHeures() {
    return _mesUEs.fold(0, (sum, ue) => sum + (ue.nbHeures ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Inscriptions UE'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUEs,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé
                  Card(
                    color: Colors.indigo.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'MON PARCOURS',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.book, '${_mesUEs.length}', 'UE'),
                              _buildStatItem(Icons.star, '${_getTotalCredits()}', 'ECTS'),
                              _buildStatItem(Icons.schedule, '${_getTotalHeures()}h', 'Total'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Mes UE
                  Text(
                    'MES UE INSCRITES (${_mesUEs.length})',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 16),
                  if (_mesUEs.isEmpty)
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.grey),
                        title: Text('Aucune inscription'),
                        subtitle: Text('Inscrivez-vous à des UE ci-dessous'),
                      ),
                    )
                  else
                    ..._mesUEs.map((ue) => Card(
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 12),
                          color: Colors.indigo.shade50,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Text(
                                '${ue.credits}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              ue.nom ?? 'UE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${ue.nbHeures}h • ${ue.composanteAcronyme}'),
                                if (ue.professeurs != null && ue.professeurs!.isNotEmpty)
                                  Text(
                                    'Professeur: ${ue.professeurs!.join(", ")}',
                                    style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.w500),
                                  ),
                                if (ue.description != null && ue.description!.isNotEmpty)
                                  Text(
                                    ue.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _unenrollUE(ue),
                            ),
                          ),
                        )),
                  SizedBox(height: 32),

                  // Autres UE disponibles
                  Text(
                    'S\'INSCRIRE À DES UE (${_autresUEs.length})',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 16),
                  if (_autresUEs.isEmpty)
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Vous êtes inscrit à toutes les UE disponibles'),
                      ),
                    )
                  else
                    ..._autresUEs.map((ue) => Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${ue.credits}',
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(ue.nom ?? 'UE'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${ue.nbHeures}h • ${ue.composanteAcronyme}'),
                                if (ue.professeurs != null && ue.professeurs!.isNotEmpty)
                                  Text(
                                    'Professeur: ${ue.professeurs!.join(", ")}',
                                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                                  ),
                                if (ue.description != null && ue.description!.isNotEmpty)
                                  Text(
                                    ue.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => _enrollUE(ue),
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 32),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
