import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/universite.dart';
import 'add_universite_page.dart';

class UniversiteListPage extends StatefulWidget {
  @override
  _UniversiteListPageState createState() => _UniversiteListPageState();
}

class _UniversiteListPageState extends State<UniversiteListPage> {
  final ApiService apiService = ApiService();
  late Future<List<Universite>> _universitesFuture;

  @override
  void initState() {
    super.initState();
    _loadUniversites();
  }

  void _loadUniversites() {
    setState(() {
      _universitesFuture = apiService.fetchUniversites();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Universités'),
      ),
      body: FutureBuilder<List<Universite>>(
        future: _universitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final universitesList = snapshot.data!;
            if (universitesList.isEmpty) {
              return Center(child: Text('Aucune université trouvée.'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: universitesList.length,
              itemBuilder: (context, index) {
                return _buildUniversiteCard(universitesList[index]);
              },
            );
          }
          return Center(child: Text('Démarrage...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: Icon(Icons.add),
        tooltip: 'Ajouter Université',
      ),
    );
  }

  Widget _buildUniversiteCard(Universite universite) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
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
    );
  }
}
