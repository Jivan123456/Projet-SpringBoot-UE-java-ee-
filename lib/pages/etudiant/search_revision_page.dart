import 'package:flutter/material.dart';
import '../../services/recherche_service.dart';
import '../../models/salle.dart';

class SearchRevisionPage extends StatefulWidget {
  final RechercheService rechercheService;

  SearchRevisionPage({Key? key, required this.rechercheService}) : super(key: key);

  @override
  _SearchRevisionPageState createState() => _SearchRevisionPageState();
}

class _SearchRevisionPageState extends State<SearchRevisionPage> {
  final _villeController = TextEditingController();
  final _minCapController = TextEditingController(text: '10');
  final _maxCapController = TextEditingController(text: '40');
  
  List<Salle> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    if (_villeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une ville'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await widget.rechercheService.getSallesPourReviser(
        ville: _villeController.text,
        minCap: int.tryParse(_minCapController.text) ?? 10,
        maxCap: int.tryParse(_maxCapController.text) ?? 40,
      );
      
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, size: 32, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salles de Révision',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                            ),
                            Text(
                              'Trouvez une salle calme pour réviser',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Ville
                  TextField(
                    controller: _villeController,
                    decoration: InputDecoration(
                      labelText: 'Ville *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Ex: Montpellier, Perpignan',
                    ),
                  ),
                  SizedBox(height: 16),

                  // Capacité
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minCapController,
                          decoration: InputDecoration(
                            labelText: 'Capacité min',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people_outline),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxCapController,
                          decoration: InputDecoration(
                            labelText: 'Capacité max',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Bouton recherche
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _search,
                      icon: _isSearching ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ) : Icon(Icons.search),
                      label: Text(_isSearching ? 'Recherche...' : 'Rechercher'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Résultats
          if (_hasSearched) ...[
            Text(
              '${_results.length} salle(s) trouvée(s)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_results.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucune salle trouvée', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Essayez avec d\'autres critères',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final salle = _results[index];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 16,
                                child: Icon(Icons.meeting_room, color: Colors.white, size: 18),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  salle.numS ?? 'Salle',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Type: ${salle.typeS}',
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Icon(Icons.people, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('${salle.capacite}', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _villeController.dispose();
    _minCapController.dispose();
    _maxCapController.dispose();
    super.dispose();
  }
}
