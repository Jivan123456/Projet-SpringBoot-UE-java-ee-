package Ex.service;

import Ex.domain.ReservationRepository;
import Ex.domain.SalleRepository;
import Ex.domain.UserRepository;
import Ex.dto.ReservationDTO;
import Ex.dto.ReservationRequest;
import Ex.modele.Reservation;
import Ex.modele.Salle;
import Ex.modele.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ReservationService {

    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private SalleRepository salleRepository;

    @Autowired
    private UserRepository userRepository;

    // Créer une réservation (professeur ou admin)
    public ReservationDTO creerReservation(ReservationRequest request) {
        User currentUser = getCurrentUser();

        if (!currentUser.isProfesseur() && !currentUser.isAdmin()) {
            throw new RuntimeException("Seuls les professeurs et administrateurs peuvent réserver des salles");
        }

        // Vérifier que la salle existe
        Salle salle = salleRepository.findById(request.getSalleNums())
                .orElseThrow(() -> new RuntimeException("Salle non trouvée: " + request.getSalleNums()));

        // Vérifier les dates
        if (request.getDateDebut().isAfter(request.getDateFin())) {
            throw new RuntimeException("La date de début doit être avant la date de fin");
        }

        if (request.getDateDebut().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Impossible de réserver dans le passé");
        }

        // Vérifier disponibilité
        long conflicts = reservationRepository.countConflicts(
            request.getSalleNums(),
            request.getDateDebut(),
            request.getDateFin()
        );

        if (conflicts > 0) {
            throw new RuntimeException("Salle déjà réservée pour ce créneau");
        }

        // Créer la réservation
        Reservation reservation = new Reservation(
            salle,
            currentUser,
            request.getDateDebut(),
            request.getDateFin(),
            request.getMotif()
        );

        // Admin : approuvée automatiquement, Prof : en attente
        if (currentUser.isAdmin()) {
            reservation.setStatut(Reservation.StatutReservation.APPROUVEE);
        }

        reservation = reservationRepository.save(reservation);
        return convertToDTO(reservation);
    }

    // Mes réservations
    public List<ReservationDTO> getMesReservations() {
        User currentUser = getCurrentUser();
        return reservationRepository.findByUserId(currentUser.getId())
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Réservations d'une salle
    public List<ReservationDTO> getReservationsBySalle(String nums) {
        return reservationRepository.findBySalleNums(nums)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Réservations en attente (admin)
    public List<ReservationDTO> getReservationsEnAttente() {
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès réservé aux administrateurs");
        }
        return reservationRepository.findPendingReservations()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Approuver une réservation (admin)
    public ReservationDTO approuverReservation(Long id) {
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès réservé aux administrateurs");
        }

        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Réservation non trouvée"));

        reservation.setStatut(Reservation.StatutReservation.APPROUVEE);
        reservation = reservationRepository.save(reservation);
        return convertToDTO(reservation);
    }

    // Refuser une réservation (admin)
    public ReservationDTO refuserReservation(Long id) {
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès réservé aux administrateurs");
        }

        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Réservation non trouvée"));

        reservation.setStatut(Reservation.StatutReservation.REFUSEE);
        reservation = reservationRepository.save(reservation);
        return convertToDTO(reservation);
    }

    // Annuler sa réservation
    public ReservationDTO annulerReservation(Long id) {
        User currentUser = getCurrentUser();

        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Réservation non trouvée"));

        // Vérifier que c'est bien sa réservation ou admin
        if (!reservation.getUser().getId().equals(currentUser.getId()) && !currentUser.isAdmin()) {
            throw new RuntimeException("Vous ne pouvez annuler que vos propres réservations");
        }

        reservation.setStatut(Reservation.StatutReservation.ANNULEE);
        reservation = reservationRepository.save(reservation);
        return convertToDTO(reservation);
    }

    // Convertir en DTO
    private ReservationDTO convertToDTO(Reservation reservation) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(reservation.getId());
        dto.setSalleNums(reservation.getSalle().getNums());
        dto.setSalleNom(reservation.getSalle().getNums());

        if (reservation.getSalle().getBatiment() != null) {
            dto.setBatimentNom(reservation.getSalle().getBatiment().getCodeB());
            if (reservation.getSalle().getBatiment().getCampus() != null) {
                dto.setCampusNom(reservation.getSalle().getBatiment().getCampus().getNomC());
            }
        }

        dto.setUserEmail(reservation.getUser().getEmail());
        dto.setUserNom(reservation.getUser().getNom());
        dto.setUserPrenom(reservation.getUser().getPrenom());
        dto.setDateDebut(reservation.getDateDebut());
        dto.setDateFin(reservation.getDateFin());
        dto.setMotif(reservation.getMotif());
        dto.setStatut(reservation.getStatut().name());
        dto.setDateCreation(reservation.getDateCreation());

        return dto;
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }
}

