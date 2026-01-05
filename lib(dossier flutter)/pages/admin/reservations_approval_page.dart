import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation.dart';

class ReservationsApprovalPage extends StatefulWidget {
  final ReservationService reservationService;

  ReservationsApprovalPage({Key? key, required this.reservationService}) : super(key: key);

  @override
  _ReservationsApprovalPageState createState() => _ReservationsApprovalPageState();
}

class _ReservationsApprovalPageState extends State<ReservationsApprovalPage> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final reservations = await widget.reservationService.getReservationsEnAttente();
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approuverReservation(int id) async {
    try {
      await widget.reservationService.approuverReservation(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Réservation approuvée'), backgroundColor: Colors.green),
      );
      _loadReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _refuserReservation(int id) async {
    try {
      await widget.reservationService.refuserReservation(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Réservation refusée'), backgroundColor: Colors.orange),
      );
      _loadReservations();
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

    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Aucune réservation en attente',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Toutes les demandes ont été traitées !',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${reservation.userPrenom} ${reservation.userNom}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              reservation.userEmail ?? '',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ' En attente',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  
                  // Info salle
                  Row(
                    children: [
                      Icon(Icons.meeting_room, size: 20, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        reservation.salleNom ?? 'Salle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.tag, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Salle ${reservation.salleNums}'),
                      SizedBox(width: 16),
                      Icon(Icons.apartment, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(reservation.batimentNom ?? 'Bâtiment'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(reservation.campusNom ?? 'Campus'),
                    ],
                  ),
                  
                  Divider(height: 24),
                  
                  // Date et heure
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        '${reservation.dateDebut?.day ?? 0}/${reservation.dateDebut?.month ?? 0}/${reservation.dateDebut?.year ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        '${reservation.dateDebut?.hour.toString().padLeft(2, '0') ?? '00'}:${reservation.dateDebut?.minute.toString().padLeft(2, '0') ?? '00'} - ${reservation.dateFin?.hour.toString().padLeft(2, '0') ?? '00'}:${reservation.dateFin?.minute.toString().padLeft(2, '0') ?? '00'}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${reservation.dureeDisplay})',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Motif
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.description, size: 18, color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Motif:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                reservation.motif ?? '',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _refuserReservation(reservation.id ?? 0),
                        icon: Icon(Icons.close, color: Colors.red),
                        label: Text('Refuser', style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _approuverReservation(reservation.id ?? 0),
                        icon: Icon(Icons.check),
                        label: Text('Approuver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
