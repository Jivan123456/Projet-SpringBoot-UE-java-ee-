package Ex.domain;



import Ex.modele.Batiment;
import Ex.modele.Salle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.stereotype.Repository;

import java.util.List;


@RepositoryRestResource(exported = false)
public interface SalleRepository extends JpaRepository<Salle, String> {

    @Query("SELECT s FROM Salle s")
    List<Salle> findAllSalles();

    @Query("SELECT s FROM Salle s WHERE s.types = 'td' AND s.batiment.codeB = '36'")
    List<Salle> findTdSallesInBatiment36();

    @Query("SELECT s FROM Salle s WHERE s.batiment.codeB = :codeBatiment")
    List<Salle> findSallesByBatimentCode(String codeBatiment);

    @Query("SELECT s FROM Salle s WHERE s.batiment IN (SELECT b FROM Batiment b WHERE b.campus.nomC = :nomCampus)")
    List<Salle> findSallesByCampusName(String nomCampus);

    @Query("SELECT s.batiment, COUNT(s) FROM Salle s GROUP BY s.batiment")
    List<Object[]> countSallesByBatiment();

    @Query("SELECT s.types, COUNT(s) FROM Salle s GROUP BY s.types")
    List<Object[]> countSallesByType();

    // TP2 - Requêtes pour les services

    // Compter les salles d'un campus
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.campus.nomC = :nomCampus")
    Long countSallesByCampus(@Param("nomCampus") String nomCampus);

    // Compter les salles d'un bâtiment
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.codeB = :codeBatiment")
    Long countSallesByBatiment(@Param("codeBatiment") String codeBatiment);

    // Salles TD de moins de X places, accessibles PMR, dans une ville donnée
    @Query("SELECT s FROM Salle s WHERE s.types = 'td' " +
           "AND s.capacite < :maxCapacite " +
           "AND s.acces = 'oui' " +
           "AND s.batiment.campus.ville = :ville")
    List<Salle> findTdSallesAccessiblesByVille(@Param("maxCapacite") int maxCapacite,
                                                 @Param("ville") String ville);

    // Amphis d'au moins X places sur un campus
    @Query("SELECT s FROM Salle s WHERE s.types = 'amphi' " +
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
    @Query("SELECT s FROM Salle s WHERE s.batiment.campus.nomC = :nomCampus AND s.types = :typeS")
    List<Salle> findSallesByCampusAndType(@Param("nomCampus") String nomCampus,
                                            @Param("typeS") String typeS);

    // Salles d'un bâtiment filtrées par type
    @Query("SELECT s FROM Salle s WHERE s.batiment.codeB = :codeBatiment AND s.types = :typeS")
    List<Salle> findSallesByBatimentAndType(@Param("codeBatiment") String codeBatiment,
                                              @Param("typeS") String typeS);

    // Salles d'un bâtiment
    List<Salle> findByBatiment(Batiment batiment);

    // ==================== RECHERCHES AVANCÉES ====================

    // 1️⃣ ÉTUDIANTS : Salles pour réviser (petites, type TD/TP, optionnel PMR)
    @Query("SELECT s FROM Salle s WHERE s.capacite BETWEEN :minCap AND :maxCap " +
           "AND s.types IN ('td', 'tp') " +
           "AND (:needPMR = false OR s.acces = 'oui') " +
           "AND s.batiment.campus.ville = :ville " +
           "ORDER BY s.capacite ASC")
    List<Salle> findSallesPourReviser(@Param("minCap") int minCap,
                                       @Param("maxCap") int maxCap,
                                       @Param("needPMR") boolean needPMR,
                                       @Param("ville") String ville);

    // 2️⃣ ÉTUDIANTS : Chercher par plage de capacité (ex: 20-40 places)
    @Query("SELECT s FROM Salle s WHERE s.capacite BETWEEN :minCap AND :maxCap " +
           "ORDER BY s.capacite ASC")
    List<Salle> findSallesByCapaciteRange(@Param("minCap") int minCap,
                                            @Param("maxCap") int maxCap);

    // 3️⃣ ÉTUDIANTS : Toutes les salles PMR d'une ville
    @Query("SELECT s FROM Salle s WHERE s.acces = 'oui' " +
           "AND s.batiment.campus.ville = :ville " +
           "ORDER BY s.batiment.campus.nomC, s.batiment.codeB")
    List<Salle> findSallesPMRByVille(@Param("ville") String ville);

    // 4️⃣ PROFESSEURS : Salles adaptées pour un cours (type + capacité min)
    @Query("SELECT s FROM Salle s WHERE s.types = :typeS " +
           "AND s.capacite >= :minCap " +
           "AND s.batiment.campus.nomC = :nomCampus " +
           "ORDER BY s.capacite ASC")
    List<Salle> findSallesPourCours(@Param("typeS") String typeS,
                                     @Param("minCap") int minCap,
                                     @Param("nomCampus") String nomCampus);

    // 5️⃣ PROFESSEURS : Salles par université et type
    @Query("SELECT s FROM Salle s WHERE s.types = :typeS " +
           "AND s.batiment.campus.universite.acronyme = :acronyme " +
           "ORDER BY s.capacite DESC")
    List<Salle> findSallesByUniversiteAndType(@Param("acronyme") String acronyme,
                                                @Param("typeS") String typeS);

    // 6️⃣ ADMIN : Top N des plus grandes salles (toutes universités)
    @Query("SELECT s FROM Salle s ORDER BY s.capacite DESC")
    List<Salle> findTopSallesByCapacite();

    // 7️⃣ ADMIN : Statistiques par type de salle et ville
    @Query("SELECT s.batiment.campus.ville, s.types, COUNT(s), COALESCE(SUM(s.capacite), 0) " +
           "FROM Salle s " +
           "GROUP BY s.batiment.campus.ville, s.types " +
           "ORDER BY s.batiment.campus.ville, s.types")
    List<Object[]> getStatistiquesByVilleAndType();

    // 8️⃣ ADMIN : Nombre de salles PMR par campus
    @Query("SELECT s.batiment.campus.nomC, COUNT(s) " +
           "FROM Salle s WHERE s.acces = 'oui' " +
           "GROUP BY s.batiment.campus.nomC " +
           "ORDER BY COUNT(s) DESC")
    List<Object[]> countSallesPMRByCampus();

    // 9️⃣ RECHERCHE MULTI-CRITÈRES : Ville + Type + Capacité + PMR
    @Query("SELECT s FROM Salle s WHERE " +
           "(:ville IS NULL OR s.batiment.campus.ville = :ville) " +
           "AND (:typeS IS NULL OR s.types = :typeS) " +
           "AND (:minCap IS NULL OR s.capacite >= :minCap) " +
           "AND (:maxCap IS NULL OR s.capacite <= :maxCap) " +
           "AND (:needPMR = false OR s.acces = 'oui') " +
           "ORDER BY s.batiment.campus.ville, s.capacite ASC")
    List<Salle> searchSallesMultiCriteria(@Param("ville") String ville,
                                           @Param("typeS") String typeS,
                                           @Param("minCap") Integer minCap,
                                           @Param("maxCap") Integer maxCap,
                                           @Param("needPMR") boolean needPMR);

    // 🔟 ADMIN : Répartition géographique (capacité totale par ville)
    @Query("SELECT s.batiment.campus.ville, COUNT(s), COALESCE(SUM(s.capacite), 0) " +
           "FROM Salle s " +
           "GROUP BY s.batiment.campus.ville " +
           "ORDER BY SUM(s.capacite) DESC")
    List<Object[]> getCapaciteTotaleByVille();
}
