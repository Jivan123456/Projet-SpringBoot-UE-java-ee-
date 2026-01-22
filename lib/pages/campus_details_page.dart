import 'package:flutter/material.dart';
import '../models/campus.dart';
import '../models/universite.dart';
import '../models/batiment.dart';
import '../models/composante.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'universite_details_page.dart';
import 'batiment_details_page.dart';
import 'composante_details_page.dart';
import 'salle_details_page.dart';

class CampusDetailsPage extends StatefulWidget {
  final Campus campus;
  final AuthService authService;

  CampusDetailsPage({
    Key? key,
    required this.campus,
    required this.authService,
  }) : super(key: key);

  @override
  _CampusDetailsPageState createState() => _CampusDetailsPageState();
}

class _CampusDetailsPageState extends State<CampusDetailsPage> {
  final ApiService _apiService = ApiService();
  
  Universite? _universite;
  List<Batiment> _batiments = [];
  List<Composante> _composantes = [];
  List<Salle> _salles = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.authService.token);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      // Charger l'université parente
      if (widget.campus.universiteId != null) {
        final universites = await _apiService.fetchUniversites();
        _universite = universites.firstWhere(
          (u) => u.acronyme == widget.campus.universiteId,
          orElse: () => throw Exception('Université non trouvée'),
        );
      }

      // Charger les composantes de ce campus
      try {
        _composantes = await _apiService.fetchComposantesByCampus(widget.campus.nomC ?? '');
        print('Composantes chargées pour ${widget.campus.nomC}: ${_composantes.length}');
      } catch (e) {
        print('Erreur chargement composantes: $e');
        _composantes = [];
      }

      // Charger les bâtiments de ce campus
      final allBatiments = await _apiService.fetchBatiments();
      _batiments = allBatiments.where((b) => b.campusId == widget.campus.nomC).toList();

      // Charger les salles des bâtiments de ce campus
      final allSalles = await _apiService.fetchSalles();
      final batimentCodes = _batiments.map((b) => b.codeB).toSet();
      _salles = allSalles.where((s) => batimentCodes.contains(s.batimentId)).toList();



      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campus.nomC ?? 'Campus'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetails,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte principale du campus
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
                                  backgroundColor: Colors.green,
                                  radius: 30,
                                  child: Icon(Icons.location_city, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.campus.nomC ?? 'Campus',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Ville: ${widget.campus.ville}',
                                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Section: Université parente (remontée)
                    Text(
                      'UNIVERSITÉ PARENTE',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 8),
                    if (_universite != null)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.school, color: Colors.blue),
                          title: Text(_universite!.nom ?? 'Université'),
                          subtitle: Text('${_universite!.acronyme ?? ''} • Créée en ${_universite!.creation ?? ''}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => UniversiteDetailsPage(
                                  universite: _universite!,
                                  authService: widget.authService,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune université associée'),
                        ),
                      ),
                    SizedBox(height: 24),

                    // Section: Composantes
                    Text(
                      'COMPOSANTES (${_composantes.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 8),
                    if (_composantes.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune composante associée'),
                          subtitle: widget.authService.isAdmin() 
                              ? Text('Cliquez sur + pour associer des composantes', style: TextStyle(fontSize: 12))
                              : null,
                          trailing: widget.authService.isAdmin()
                              ? IconButton(
                                  icon: Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => _showAddComposanteDialog(),
                                )
                              : null,
                        ),
                      )
                    else
                      ..._composantes.map((comp) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade100,
                              child: Icon(Icons.business, color: Colors.purple),
                            ),
                            title: Text(comp.nom ?? 'Composante'),
                            subtitle: Text('${comp.acronyme ?? ''} • Resp: ${comp.responsable ?? 'N/A'}'),
                            trailing: widget.authService.isAdmin()
                                ? IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeComposanteFromCampus(comp.acronyme ?? ''),
                                    tooltip: 'Retirer du campus',
                                  )
                                : Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ComposanteDetailsPage(
                                    composante: comp,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 24),

                    // Section: Bâtiments (descente)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BÂTIMENTS (${_batiments.length})',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        if (widget.authService.isAdmin())
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.orange),
                            onPressed: () => _showAddBatimentDialog(),
                            tooltip: 'Ajouter un bâtiment',
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_batiments.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucun bâtiment'),
                          subtitle: widget.authService.isAdmin()
                              ? Text('Cliquez sur + pour créer un bâtiment', style: TextStyle(fontSize: 12))
                              : null,
                        ),
                      )
                    else
                      ..._batiments.map((bat) {
                        final sallesDuBatiment = _salles.where((s) => s.batimentId == bat.codeB).length;
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Icon(Icons.apartment, color: Colors.orange),
                            ),
                            title: Text('Bâtiment ${bat.codeB}'),
                            subtitle: Text('Année: ${bat.anneeC} • $sallesDuBatiment salle(s)'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => BatimentDetailsPage(
                                    batiment: bat,
                                    authService: widget.authService,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    SizedBox(height: 24),

                    // Section: Salles (descente niveau 2)
                    Text(
                      'TOUTES LES SALLES (${_salles.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 8),
                    if (_salles.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune salle'),
                        ),
                      )
                    else
                      ..._salles.take(10).map((salle) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.meeting_room, color: Colors.blue, size: 20),
                            ),
                            title: Text('Salle ${salle.numS}'),
                            subtitle: Text('${salle.typeS?.toUpperCase() ?? 'N/A'} • ${salle.capacite ?? 0} places • Bâtiment ${salle.batimentId ?? ''}'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
                      }).toList(),
                    if (_salles.length > 10)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            '+ ${_salles.length - 10} autres salles',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    SizedBox(height: 24),

                    // Résumé statistique
                    Card(
                      color: Colors.indigo.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RÉSUMÉ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            SizedBox(height: 12),
                            _buildStatRow(Icons.business, 'Composantes', _composantes.length.toString()),
                            _buildStatRow(Icons.apartment, 'Bâtiments', _batiments.length.toString()),
                            _buildStatRow(Icons.meeting_room, 'Salles', _salles.length.toString()),
                            _buildStatRow(Icons.people, 'Capacité totale', '${_salles.fold<int>(0, (sum, s) => sum + (s.capacite ?? 0))} places'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddBatimentDialog() {
    final codeBController = TextEditingController();
    final anneeCController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouveau Bâtiment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeBController,
              decoration: InputDecoration(
                labelText: 'Code Bâtiment *',
                hintText: 'Ex: Bat9, E-Learning-1',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: anneeCController,
              decoration: InputDecoration(
                labelText: 'Année de construction *',
                hintText: 'Ex: 1970, 2020',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            Text(
              'Campus: ${widget.campus.nomC}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (codeBController.text.isEmpty || anneeCController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tous les champs sont obligatoires')),
                );
                return;
              }

              try {
                // Le backend remplit automatiquement campusId
                await _apiService.createBatimentFromCampus(
                  widget.campus.nomC ?? '',
                  codeBController.text.trim(),
                  int.tryParse(anneeCController.text.trim()) ?? 0,
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bâtiment créé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadDetails();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeComposanteFromCampus(String acronyme) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Retirer la composante'),
        content: Text('Retirer la composante "$acronyme" de ce campus ?\n\nLa composante ne sera pas supprimée, seulement dissociée de ce campus.'),
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
        // Utiliser le nouvel endpoint backend qui retourne le CampusDTO mis à jour
        await _apiService.dissocierComposanteDeCampus(
          widget.campus.nomC ?? '',
          acronyme,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Composante retirée du campus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDetails();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddComposanteDialog() async {
    try {
      // Charger toutes les composantes
      final allComposantes = await _apiService.fetchComposantes();
      
      // Filtrer celles qui ne sont pas déjà associées
      final composantesDisponibles = allComposantes
          .where((c) => !_composantes.any((existing) => existing.acronyme == c.acronyme))
          .toList();

      if (composantesDisponibles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Toutes les composantes sont déjà associées à ce campus')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ajouter une composante'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: composantesDisponibles.length,
              itemBuilder: (ctx, index) {
                final comp = composantesDisponibles[index];
                return ListTile(
                  leading: Icon(Icons.business, color: Colors.purple),
                  title: Text(comp.nom ?? 'Composante'),
                  subtitle: Text(comp.acronyme ?? ''),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      // Utiliser le nouvel endpoint backend qui retourne le CampusDTO mis à jour
                      await _apiService.associerComposanteACampus(
                        widget.campus.nomC ?? '',
                        comp.acronyme ?? '',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Composante ajoutée au campus'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadDetails();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
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
}
