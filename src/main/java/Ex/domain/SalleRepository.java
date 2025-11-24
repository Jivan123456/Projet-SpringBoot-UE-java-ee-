package Ex.domain;



import Ex.modele.Batiment;
import Ex.modele.Salle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface SalleRepository extends JpaRepository<Salle, String> {

    @Query("SELECT s FROM Salle s")
    List<Salle> findAllSalles();

    @Query("SELECT s FROM Salle s WHERE s.typeS = 'td' AND s.batiment.codeB = '36'")
    List<Salle> findTdSallesInBatiment36();

    @Query("SELECT s FROM Salle s WHERE s.batiment.codeB = :codeBatiment")
    List<Salle> findSallesByBatimentCode(String codeBatiment);

    @Query("SELECT s FROM Salle s WHERE s.batiment IN (SELECT b FROM Batiment b WHERE b.campus.nomC = :nomCampus)")
    List<Salle> findSallesByCampusName(String nomCampus);

    @Query("SELECT s.batiment, COUNT(s) FROM Salle s GROUP BY s.batiment")
    List<Object[]> countSallesByBatiment();

    @Query("SELECT s.typeS, COUNT(s) FROM Salle s GROUP BY s.typeS")
    List<Object[]> countSallesByType();

    // TP2 - Requêtes pour les services

    // Compter les salles d'un campus
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.campus.nomC = :nomCampus")
    Long countSallesByCampus(@Param("nomCampus") String nomCampus);

    // Compter les salles d'un bâtiment
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.codeB = :codeBatiment")
    Long countSallesByBatiment(@Param("codeBatiment") String codeBatiment);

    // Salles TD de moins de X places, accessibles PMR, dans une ville donnée
    @Query("SELECT s FROM Salle s WHERE s.typeS = 'td' " +
           "AND s.capacite < :maxCapacite " +
           "AND s.acces = 'oui' " +
           "AND s.batiment.campus.ville = :ville")
    List<Salle> findTdSallesAccessiblesByVille(@Param("maxCapacite") int maxCapacite,
                                                 @Param("ville") String ville);

    // Amphis d'au moins X places sur un campus
    @Query("SELECT s FROM Salle s WHERE s.typeS = 'amphi' " +
           "AND s.capacite >= :minCapacite " +
           "AND s.batiment.campus.nomC = :nomCampus")
    List<Salle> findAmphisByCampus(@Param("minCapacite") int minCapacite,
                                    @Param("nomCampus") String nomCampus);

    // Capacité totale d'un campus
    @Query("SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s WHERE s.batiment.campus.nomC = :nomCampus")
    Long sumCapaciteByCampus(@Param("nomCampus") String nomCampus);

    // Capacité totale d'un bâtiment
    @Query("SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s WHERE s.batiment.codeB = :codeBatiment")
    Long sumCapaciteByBatiment(@Param("codeBatiment") String codeBatiment);

    // Salles d'un campus filtrées par type
    @Query("SELECT s FROM Salle s WHERE s.batiment.campus.nomC = :nomCampus AND s.typeS = :typeS")
    List<Salle> findSallesByCampusAndType(@Param("nomCampus") String nomCampus,
                                            @Param("typeS") String typeS);

    // Salles d'un bâtiment filtrées par type
    @Query("SELECT s FROM Salle s WHERE s.batiment.codeB = :codeBatiment AND s.typeS = :typeS")
    List<Salle> findSallesByBatimentAndType(@Param("codeBatiment") String codeBatiment,
                                              @Param("typeS") String typeS);

    // Salles d'un bâtiment
    List<Salle> findByBatiment(Batiment batiment);
}
