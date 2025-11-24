package Ex.domain;

import Ex.modele.Universite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UniversiteRepository extends JpaRepository<Universite, String> {

    /**
     * Compte le nombre de campus d'une université
     */
    @Query("SELECT COUNT(c) FROM Campus c WHERE c.universite.acronyme = :acronyme")
    Long countCampusByUniversite(@Param("acronyme") String acronyme);

    /**
     * Compte le nombre de bâtiments d'une université
     */
    @Query("SELECT COUNT(b) FROM Batiment b WHERE b.campus.universite.acronyme = :acronyme")
    Long countBatimentsByUniversite(@Param("acronyme") String acronyme);

    /**
     * Compte le nombre de salles d'une université
     */
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.campus.universite.acronyme = :acronyme")
    Long countSallesByUniversite(@Param("acronyme") String acronyme);

    /**
     * Calcule la capacité totale d'une université
     */
    @Query("SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s WHERE s.batiment.campus.universite.acronyme = :acronyme")
    Long sumCapaciteByUniversite(@Param("acronyme") String acronyme);

    /**
     * Compte le nombre de salles accessibles d'une université
     */
    @Query("SELECT COUNT(s) FROM Salle s WHERE s.batiment.campus.universite.acronyme = :acronyme AND s.acces = 'oui'")
    Long countSallesAccessiblesByUniversite(@Param("acronyme") String acronyme);

    /**
     * Compte le nombre de composantes qui exploitent les campus d'une université
     */
    @Query("SELECT COUNT(DISTINCT comp) FROM Composante comp JOIN comp.campus c WHERE c.universite.acronyme = :acronyme")
    Long countComposantesByUniversite(@Param("acronyme") String acronyme);
}

