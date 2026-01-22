import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import '../../services/api_service.dart';
import '../../models/salle.dart';
import '../../models/ue.dart';

class CreateReservationPage extends StatefulWidget {
  final ReservationService reservationService;
  final ApiService apiService;

  CreateReservationPage({
    Key? key,
    required this.reservationService,
    required this.apiService,
  }) : super(key: key);

  @override
  _CreateReservationPageState createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends State<CreateReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _motifController = TextEditingController();
  
  String? _selectedSalleNums;
  int? _selectedUEId;
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(Duration(hours: 2));
  
  List<Salle> _salles = [];
  List<UE> _mesUEs = [];
  Map<String, Map<String, String>> _salleDetails = {}; // numS -> {batiment, campus, ville}
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalles();
  }

  Future<void> _loadSalles() async {
    try {
      final salles = await widget.apiService.fetchSalles();
      final batiments = await widget.apiService.fetchBatiments();
      final campusList = await widget.apiService.fetchCampus();
      
      // Récupérer l'ID du professeur connecté depuis authService
      final userId = widget.reservationService.authService.currentUser?.id ?? 0;
      final mesUEs = await widget.apiService.fetchUEsByProfesseur(userId);
      
      // Créer une map pour accès rapide aux campus par nomC
      Map<String, dynamic> campusMap = {};
      for (var camp in campusList) {
        if (camp.nomC != null) campusMap[camp.nomC!] = {
          'nomC': camp.nomC,
          'ville': camp.ville,
        };
      }
      
      // Créer une map pour accès rapide aux bâtiments
      Map<String, dynamic> batimentMap = {};
      for (var bat in batiments) {
        if (bat.codeB != null) batimentMap[bat.codeB!] = {
          'codeB': bat.codeB,
          'campusId': bat.campusId,
        };
      }
      
      // Construire les détails pour chaque salle
      Map<String, Map<String, String>> details = {};
      for (var salle in salles) {
        var batiment = batimentMap[salle.batimentId];
        if (batiment != null) {
          var campus = campusMap[batiment['campusId']];
          if (salle.numS != null) details[salle.numS!] = {
            'batiment': batiment['codeB'],
            'campus': campus?['nomC'] ?? 'N/A',
            'ville': campus?['ville'] ?? 'N/A',
          };
        }
      }
      
      setState(() {
        _salles = salles;
        _salleDetails = details;
        _mesUEs = mesUEs;
        _isLoading = false;
      });
    } catch (e) {
      print(' Erreur chargement salles: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isDebut) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isDebut ? _dateDebut : _dateFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isDebut ? _dateDebut : _dateFin),
      );
      
      if (time != null) {
        setState(() {
          final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isDebut) {
            _dateDebut = newDateTime;
          } else {
            _dateFin = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSalleNums == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une salle'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_dateFin.isBefore(_dateDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La date de fin doit être après la date de début'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await widget.reservationService.creerReservation(
        salleNums: _selectedSalleNums!,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        motif: _motifController.text,
        ueId: _selectedUEId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation créée avec succès (en attente d\'approbation)'), backgroundColor: Colors.green),
      );

      // Réinitialiser le formulaire
      setState(() {
        _selectedSalleNums = null;
        _selectedUEId = null;
        _motifController.clear();
        _dateDebut = DateTime.now();
        _dateFin = DateTime.now().add(Duration(hours: 2));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvelle Réservation',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les réservations des professeurs sont en attente d\'approbation par un administrateur.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 32),

                    // Sélection de la salle
                    Text('Salle *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSalleNums,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.meeting_room),
                        hintText: 'Sélectionnez une salle',
                      ),
                      items: _salles.map((salle) {
                        final details = _salleDetails[salle.numS];
                        final location = details != null ? ' (${details['batiment']}, ${details['campus']})' : '';
                        return DropdownMenuItem(
                          value: salle.numS,
                          child: Text(
                            'Salle ${salle.numS ?? ''} - ${salle.typeS?.toUpperCase() ?? 'N/A'} (${salle.capacite ?? 0} places)$location',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSalleNums = value),
                      validator: (value) => value == null ? 'Sélectionnez une salle' : null,
                      isExpanded: true,
                      menuMaxHeight: 400,
                    ),
                    SizedBox(height: 24),

                    // Sélection de l'UE (optionnel)
                    Text('Unité d\'Enseignement (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    if (_mesUEs.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aucune UE disponible. Ajoutez des UE depuis votre profil.',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                          hintText: 'Sélectionnez une UE (optionnel)',
                        ),
                        value: _selectedUEId,
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text('Pas d\'UE associée', style: TextStyle(color: Colors.grey)),
                          ),
                          ..._mesUEs.map((ue) {
                            return DropdownMenuItem<int>(
                              value: ue.idUe,
                              child: Text(
                                '${ue.nom ?? 'UE'} (${ue.credits} ECTS • ${ue.nbHeures}h)',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) => setState(() => _selectedUEId = value),
                        isExpanded: true,
                        menuMaxHeight: 400,
                      ),
                    SizedBox(height: 24),

                    // Date et heure de début
                    Text('Date et heure de début *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context, true),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.indigo),
                            SizedBox(width: 12),
                            Text(
                              '${_dateDebut.day}/${_dateDebut.month}/${_dateDebut.year} à ${_dateDebut.hour.toString().padLeft(2, '0')}:${_dateDebut.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Date et heure de fin
                    Text('Date et heure de fin *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context, false),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.indigo),
                            SizedBox(width: 12),
                            Text(
                              '${_dateFin.day}/${_dateFin.month}/${_dateFin.year} à ${_dateFin.hour.toString().padLeft(2, '0')}:${_dateFin.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Motif
                    Text('Motif de la réservation *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _motifController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Ex: Cours de Java, TP de Physique, etc.',
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Le motif est requis' : null,
                    ),
                    SizedBox(height: 32),

                    // Boutons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSalleNums = null;
                              _selectedUEId = null;
                              _motifController.clear();
                              _dateDebut = DateTime.now();
                              _dateFin = DateTime.now().add(Duration(hours: 2));
                            });
                          },
                          child: Text('Réinitialiser'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _createReservation,
                          icon: Icon(Icons.check),
                          label: Text('Créer la réservation'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }
}
