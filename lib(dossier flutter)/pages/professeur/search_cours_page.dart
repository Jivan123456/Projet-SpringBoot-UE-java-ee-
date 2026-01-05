import 'package:flutter/material.dart';
import '../../services/recherche_service.dart';
import '../../models/salle.dart';

class SearchCoursPage extends StatefulWidget {
  final RechercheService rechercheService;

  SearchCoursPage({Key? key, required this.rechercheService}) : super(key: key);

  @override
  _SearchCoursPageState createState() => _SearchCoursPageState();
}

class _SearchCoursPageState extends State<SearchCoursPage> {
  final _campusController = TextEditingController();
  final _minCapController = TextEditingController(text: '30');
  
  String _selectedType = 'td';
  List<Salle> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    if (_campusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un nom de campus'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await widget.rechercheService.getSallesPourCours(
        type: _selectedType,
        minCap: int.tryParse(_minCapController.text) ?? 30,
        campus: _campusController.text,
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
                  Text(
                    ' Rechercher une salle pour cours',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 24),

                  // Type de salle
                  Text('Type de salle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('TD'),
                          value: 'td',
                          groupValue: _selectedType,
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('TP'),
                          value: 'tp',
                          groupValue: _selectedType,
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Amphi'),
                          value: 'amphi',
                          groupValue: _selectedType,
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Capacité minimale
                  TextField(
                    controller: _minCapController,
                    decoration: InputDecoration(
                      labelText: 'Capacité minimale',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),

                  // Campus
                  TextField(
                    controller: _campusController,
                    decoration: InputDecoration(
                      labelText: 'Nom du campus',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                      hintText: 'Ex: Campus Triolet, Campus Saint-Priest',
                    ),
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
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
                          Text('Type: ${salle.typeS?.toUpperCase() ?? 'N/A'}'),
                          Text('Capacité: ${salle.capacite} places'),

                        ],
                      ),
                      isThreeLine: true,
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
    _campusController.dispose();
    _minCapController.dispose();
    super.dispose();
  }
}
