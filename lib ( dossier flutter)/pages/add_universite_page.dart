import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/universite.dart';

class AddUniversitePage extends StatefulWidget {
  @override
  _AddUniversitePageState createState() => _AddUniversitePageState();
}

class _AddUniversitePageState extends State<AddUniversitePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Contrôleurs pour récupérer le texte des champs
  final _acronymeController = TextEditingController();
  final _nomController = TextEditingController();
  final _creationController = TextEditingController();
  final _presidenceController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitForm() async {
    // Valide tous les champs du formulaire
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Crée l'objet Universite à partir des contrôleurs
        final universite = Universite(
          acronyme: _acronymeController.text,
          nom: _nomController.text,
          creation: int.parse(_creationController.text),
          presidence: _presidenceController.text,
        );

        // Appelle le service API
        await apiService.createUniversite(universite);

        // Si tout va bien, ferme la page du formulaire
        Navigator.of(context).pop(true); // 'true' signale un succès

      } catch (e) {
        // Affiche une boîte de dialogue en cas d'erreur
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Impossible de créer l\'université: $e'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Université'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _acronymeController,
                  decoration: InputDecoration(labelText: 'Acronyme'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: _creationController,
                  decoration: InputDecoration(labelText: 'Année de création'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: _presidenceController,
                  decoration: InputDecoration(labelText: 'Présidence'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Créer'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}