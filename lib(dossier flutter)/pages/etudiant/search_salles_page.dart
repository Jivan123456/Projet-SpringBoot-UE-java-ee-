import 'package:flutter/material.dart';
import '../../services/recherche_service.dart';
import '../../models/salle.dart';

class SearchSallesPage extends StatefulWidget {
  final RechercheService rechercheService;

  SearchSallesPage({Key? key, required this.rechercheService}) : super(key: key);

  @override
  _SearchSallesPageState createState() => _SearchSallesPageState();
}

class _SearchSallesPageState extends State<SearchSallesPage> {
  final _villeController = TextEditingController();
  final _minCapController = TextEditingController();
  final _maxCapController = TextEditingController();
  
  String? _selectedType;
  List<Salle> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await widget.rechercheService.searchMultiCriteria(
        ville: _villeController.text.isEmpty ? null : _villeController.text,
        type: _selectedType,
        minCap: _minCapController.text.isEmpty ? null : int.tryParse(_minCapController.text),
        maxCap: _maxCapController.text.isEmpty ? null : int.tryParse(_maxCapController.text),
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

  void _resetFilters() {
    setState(() {
      _villeController.clear();
      _minCapController.clear();
      _maxCapController.clear();
      _selectedType = null;
      _results = [];
      _hasSearched = false;
    });
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
                      Icon(Icons.search, size: 32, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recherche Multicritères',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                            Text(
                              'Combinez plusieurs filtres pour trouver la salle idéale',
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
                      labelText: 'Ville (optionnel)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Ex: Montpellier',
                    ),
                  ),
                  SizedBox(height: 16),

                  // Type de salle
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type de salle (optionnel)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Tous les types')),
                      DropdownMenuItem(value: 'td', child: Text('TD')),
                      DropdownMenuItem(value: 'tp', child: Text('TP')),
                      DropdownMenuItem(value: 'amphi', child: Text('Amphi')),
                    ],
                    onChanged: (value) => setState(() => _selectedType = value),
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

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: Icon(Icons.refresh),
                          label: Text('Réinitialiser'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
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
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Résultats
          if (_hasSearched) ...[
            Row(
              children: [
                Text(
                  '${_results.length} salle(s) trouvée(s)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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
                      'Modifiez vos critères de recherche',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final salle = _results[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: salle.typeS == 'amphi' ? Colors.purple : Colors.blue,
                        child: Icon(Icons.meeting_room, color: Colors.white),
                      ),
                      title: Text(
                        'Salle ${salle.numS}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(' Type: ${salle.typeS?.toUpperCase() ?? 'N/A'}'),
                          Text('Capacité: ${salle.capacite} places'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: salle.typeS == 'amphi' ? Colors.purple.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          salle.typeS?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: salle.typeS == 'amphi' ? Colors.purple : Colors.blue,
                          ),
                        ),
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
