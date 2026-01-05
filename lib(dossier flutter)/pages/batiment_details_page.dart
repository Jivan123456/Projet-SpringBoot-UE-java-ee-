import 'package:flutter/material.dart';
import '../models/batiment.dart';
import '../models/campus.dart';
import '../models/salle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'campus_details_page.dart';
import 'salle_details_page.dart';

class BatimentDetailsPage extends StatefulWidget {
  final Batiment batiment;
  final AuthService authService;

  BatimentDetailsPage({
    Key? key,
    required this.batiment,
    required this.authService,
  }) : super(key: key);

  @override
  _BatimentDetailsPageState createState() => _BatimentDetailsPageState();
}

class _BatimentDetailsPageState extends State<BatimentDetailsPage> {
  final ApiService _apiService = ApiService();
  
  Campus? _campus;
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
      // Charger le campus parent
      final allCampus = await _apiService.fetchCampus();
      _campus = allCampus.firstWhere(
        (c) => c.nomC == widget.batiment.campusId,
        orElse: () => throw Exception('Campus non trouvé'),
      );

      // Charger les salles de ce bâtiment
      final allSalles = await _apiService.fetchSalles();
      _salles = allSalles.where((s) => s.batimentId == widget.batiment.codeB).toList();

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
        title: Text('Bâtiment ${widget.batiment.codeB}'),
        backgroundColor: Colors.orange,
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
                    // Carte principale du bâtiment
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
                                  backgroundColor: Colors.orange,
                                  radius: 30,
                                  child: Icon(Icons.apartment, color: Colors.white, size: 30),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bâtiment ${widget.batiment.codeB}',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Année de construction: ${widget.batiment.anneeC}',
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

                    // Section: Campus parent (remontée)
                    Text(
                      'CAMPUS PARENT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    SizedBox(height: 8),
                    if (_campus != null)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.location_city, color: Colors.green),
                          title: Text(_campus!.nomC ?? 'Campus'),
                          subtitle: Text('Ville: ${_campus!.ville}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => CampusDetailsPage(
                                  campus: _campus!,
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
                          title: Text('Aucun campus associé'),
                        ),
                      ),
                    SizedBox(height: 24),

                    // Section: Salles (descente)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SALLES (${_salles.length})',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        if (widget.authService.isAdmin())
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () => _showAddSalleDialog(),
                            tooltip: 'Ajouter une salle',
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_salles.isEmpty)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey),
                          title: Text('Aucune salle'),
                          subtitle: widget.authService.isAdmin()
                              ? Text('Cliquez sur + pour créer une salle', style: TextStyle(fontSize: 12))
                              : null,
                        ),
                      )
                    else
                      ..._salles.map((salle) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.meeting_room, color: Colors.blue, size: 20),
                            ),
                            title: Text('Salle ${salle.numS}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${salle.typeS?.toUpperCase() ?? 'N/A'}'),
                                Text('Capacité: ${salle.capacite} places'),
                              ],
                            ),
                            isThreeLine: true,
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
                    SizedBox(height: 24),

                    // Résumé statistique
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RÉSUMÉ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            SizedBox(height: 12),
                            _buildStatRow(Icons.meeting_room, 'Nombre de salles', _salles.length.toString()),
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
          Icon(icon, size: 20, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddSalleDialog() {
    final numSController = TextEditingController();
    final typeSController = TextEditingController();
    final capaciteController = TextEditingController();
    String? selectedType = 'amphi';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Nouvelle Salle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numSController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de salle *',
                    hintText: 'Ex: A103, T101, E205',
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Type de salle *'),
                  items: ['amphi', 'tp', 'td', 'bureau', 'labo']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      typeSController.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: capaciteController,
                  decoration: InputDecoration(
                    labelText: 'Capacité *',
                    hintText: 'Nombre de places',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                Text(
                  'Bâtiment: ${widget.batiment.codeB}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
                    selectedType == null || 
                    capaciteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tous les champs sont obligatoires')),
                  );
                  return;
                }

                try {
                  // Le backend remplit automatiquement batimentId
                  await _apiService.createSalleFromBatiment(
                    widget.batiment.codeB ?? '',
                    numSController.text.trim(),
                    selectedType ?? 'amphi',
                    int.tryParse(capaciteController.text.trim()) ?? 0,
                  );
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Salle créée avec succès'),
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
      ),
    );
  }
}
