import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation.dart';

class MyReservationsPage extends StatefulWidget {
  final ReservationService reservationService;

  MyReservationsPage({Key? key, required this.reservationService}) : super(key: key);

  @override
  _MyReservationsPageState createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
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
      final reservations = await widget.reservationService.getMesReservations();
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

  Future<void> _annulerReservation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'annulation'),
        content: Text('Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.reservationService.annulerReservation(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation annulée'), backgroundColor: Colors.green),
        );
        _loadReservations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'APPROUVEE':
        return Colors.green;
      case 'REFUSEE':
        return Colors.red;
      case 'ANNULEE':
        return Colors.grey;
      default:
        return Colors.blue;
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
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(fontSize: 20, color: Colors.grey),
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
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reservation.salleNom ?? 'Salle',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatutColor(reservation.statut ?? 'EN_ATTENTE'),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reservation.statutDisplay,
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.meeting_room, size: 16, color: Colors.grey),
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
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
                      SizedBox(width: 4),
                      Text(
                        '${reservation.dateDebut?.day ?? 0}/${reservation.dateDebut?.month ?? 0}/${reservation.dateDebut?.year ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.indigo),
                      SizedBox(width: 4),
                      Text(
                        '${reservation.dateDebut?.hour.toString().padLeft(2, '0') ?? '00'}:${reservation.dateDebut?.minute.toString().padLeft(2, '0') ?? '00'} - ${reservation.dateFin?.hour.toString().padLeft(2, '0') ?? '00'}:${reservation.dateFin?.minute.toString().padLeft(2, '0') ?? '00'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${reservation.dureeDisplay})',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, size: 16, color: Colors.grey.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reservation.motif ?? '',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reservation.statut == 'EN_ATTENTE' || reservation.statut == 'APPROUVEE') ...[
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _annulerReservation(reservation.id ?? 0),
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text('Annuler', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
