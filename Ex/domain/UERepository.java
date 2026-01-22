package Ex.domain;

import Ex.modele.UE;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UERepository extends JpaRepository<UE, Long> {

    // Recherche par nom
    List<UE> findByNomContainingIgnoreCase(String nom);

    // Recherche par composante
    @Query("SELECT u FROM UE u WHERE u.composante.acronyme = :acronyme")
    List<UE> findByComposante(@Param("acronyme") String acronyme);

    // UE enseignées par un professeur
    @Query("SELECT u FROM UE u JOIN u.professeurs p WHERE p.id = :professorId")
    List<UE> findByProfesseurId(@Param("professorId") Long professorId);

    // UE auxquelles un étudiant est inscrit
    @Query("SELECT u FROM UE u JOIN u.etudiants e WHERE e.id = :etudiantId")
    List<UE> findByEtudiantId(@Param("etudiantId") Long etudiantId);

    // Recherche par nombre de crédits
    List<UE> findByCredits(int credits);

    // UE avec un certain nombre minimum d'heures
    List<UE> findByNbHeuresGreaterThanEqual(int nbHeures);

    // Vérifier si une UE existe par nom et composante
    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END FROM UE u WHERE u.nom = :nom AND u.composante.acronyme = :acronyme")
    boolean existsByNomAndComposante(@Param("nom") String nom, @Param("acronyme") String acronyme);

    // Compter le nombre de professeurs pour une UE
    @Query("SELECT COUNT(p) FROM UE u JOIN u.professeurs p WHERE u.idUe = :ueId")
    Long countProfesseursByUeId(@Param("ueId") Long ueId);

    // Compter le nombre d'étudiants inscrits à une UE
    @Query("SELECT COUNT(e) FROM UE u JOIN u.etudiants e WHERE u.idUe = :ueId")
    Long countEtudiantsByUeId(@Param("ueId") Long ueId);

    // UE disponibles pour inscription (avec places disponibles)
    @Query("SELECT u FROM UE u ORDER BY u.nom")
    List<UE> findAllOrderByNom();

    // UE par composante avec statistiques
    @Query("SELECT u FROM UE u WHERE u.composante.acronyme = :acronyme ORDER BY u.nom")
    List<UE> findByComposanteOrderByNom(@Param("acronyme") String acronyme);
}

