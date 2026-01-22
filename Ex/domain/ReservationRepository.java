package Ex.domain;

import Ex.modele.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    // Réservations d'un utilisateur
    @Query("SELECT r FROM Reservation r WHERE r.user.id = :userId ORDER BY r.dateDebut DESC")
    List<Reservation> findByUserId(@Param("userId") Long userId);

    // Réservations d'une salle
    @Query("SELECT r FROM Reservation r WHERE r.salle.nums = :nums ORDER BY r.dateDebut")
    List<Reservation> findBySalleNums(@Param("nums") String nums);

    // Vérifier disponibilité d'une salle (pas de chevauchement)
    @Query("SELECT COUNT(r) FROM Reservation r WHERE r.salle.nums = :nums " +
           "AND r.statut IN ('EN_ATTENTE', 'APPROUVEE') " +
           "AND ((r.dateDebut <= :dateFin AND r.dateFin >= :dateDebut))")
    long countConflicts(@Param("nums") String nums,
                        @Param("dateDebut") LocalDateTime dateDebut,
                        @Param("dateFin") LocalDateTime dateFin);

    // Réservations approuvées d'une salle
    @Query("SELECT r FROM Reservation r WHERE r.salle.nums = :nums AND r.statut = 'APPROUVEE' ORDER BY r.dateDebut")
    List<Reservation> findApprovedBySalle(@Param("nums") String nums);

    // Réservations en attente (pour admin)
    @Query("SELECT r FROM Reservation r WHERE r.statut = 'EN_ATTENTE' ORDER BY r.dateCreation")
    List<Reservation> findPendingReservations();

    // Réservations par statut
    @Query("SELECT r FROM Reservation r WHERE r.statut = :statut ORDER BY r.dateDebut")
    List<Reservation> findByStatut(@Param("statut") Reservation.StatutReservation statut);
}

