package Ex.controller;

import Ex.dto.ReservationDTO;
import Ex.dto.ReservationRequest;
import Ex.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
@Tag(name = "Réservations", description = "Gestion des réservations de salles (Professeurs et Admins)")
public class ReservationController {

    @Autowired
    private ReservationService reservationService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSEUR')")
    @Operation(
        summary = " Créer une réservation",
        description = "Permet à un professeur de réserver une salle pour un créneau précis. **Accessible aux professeurs et administrateurs.** Les réservations des professeurs sont EN_ATTENTE (nécessitent approbation admin). Les réservations des admins sont APPROUVEES automatiquement. Vérifie les conflits de réservation. Exemple : {\"salleNums\": \"T101\", \"dateDebut\": \"2025-12-15T08:00:00\", \"dateFin\": \"2025-12-15T10:00:00\", \"motif\": \"Cours de Java\"}"
    )
    public ResponseEntity<?> creerReservation(@RequestBody ReservationRequest request) {
        try {
            ReservationDTO reservation = reservationService.creerReservation(request);
            return ResponseEntity.ok(reservation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }

    @GetMapping("/mes-reservations")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSEUR')")
    @Operation(
        summary = " Mes réservations",
        description = "Retourne toutes les réservations de l'utilisateur connecté. **Accessible aux professeurs et administrateurs.** Affiche l'historique complet avec les statuts (EN_ATTENTE, APPROUVEE, REFUSEE, ANNULEE)."
    )
    public ResponseEntity<List<ReservationDTO>> getMesReservations() {
        List<ReservationDTO> reservations = reservationService.getMesReservations();
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/salle/{nums}")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSEUR', 'ETUDIANT')")
    @Operation(
        summary = " Réservations d'une salle",
        description = "Affiche toutes les réservations d'une salle spécifique. **Accessible à tous les utilisateurs connectés.** Utile pour voir la disponibilité d'une salle. Exemple : /api/reservations/salle/T101"
    )
    public ResponseEntity<List<ReservationDTO>> getReservationsBySalle(@PathVariable String nums) {
        List<ReservationDTO> reservations = reservationService.getReservationsBySalle(nums);
        return ResponseEntity.ok(reservations);
    }

    @GetMapping("/en-attente")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Réservations en attente",
        description = "Liste toutes les réservations en attente d'approbation. **Réservé aux administrateurs uniquement.** Permet de gérer les demandes des professeurs."
    )
    public ResponseEntity<List<ReservationDTO>> getReservationsEnAttente() {
        List<ReservationDTO> reservations = reservationService.getReservationsEnAttente();
        return ResponseEntity.ok(reservations);
    }

    @PutMapping("/{id}/approuver")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Approuver une réservation",
        description = "Approuve une réservation en attente. **Réservé aux administrateurs uniquement.** Change le statut de EN_ATTENTE à APPROUVEE. Exemple : PUT /api/reservations/1/approuver"
    )
    public ResponseEntity<?> approuverReservation(@PathVariable Long id) {
        try {
            ReservationDTO reservation = reservationService.approuverReservation(id);
            return ResponseEntity.ok(reservation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/refuser")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Refuser une réservation",
        description = "Refuse une réservation en attente. **Réservé aux administrateurs uniquement.** Change le statut de EN_ATTENTE à REFUSEE. Exemple : PUT /api/reservations/1/refuser"
    )
    public ResponseEntity<?> refuserReservation(@PathVariable Long id) {
        try {
            ReservationDTO reservation = reservationService.refuserReservation(id);
            return ResponseEntity.ok(reservation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/annuler")
    @PreAuthorize("hasAnyRole('ADMIN', 'PROFESSEUR')")
    @Operation(
        summary = " Annuler une réservation",
        description = "Annule une réservation existante. **Accessible aux professeurs (leurs propres réservations) et administrateurs (toutes).** Change le statut à ANNULEE. Exemple : PUT /api/reservations/1/annuler"
    )
    public ResponseEntity<?> annulerReservation(@PathVariable Long id) {
        try {
            ReservationDTO reservation = reservationService.annulerReservation(id);
            return ResponseEntity.ok(reservation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }
}

