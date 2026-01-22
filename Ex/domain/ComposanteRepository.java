package Ex.domain;

import Ex.modele.Composante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.stereotype.Repository;

import java.util.List;

@RepositoryRestResource(exported = false)
public interface ComposanteRepository extends JpaRepository<Composante, String> {

    // Recherche par responsable
    List<Composante> findByResponsable(String responsable);

    // Recherche par nom
    List<Composante> findByNom(String nom);

    // Compter le nombre de campus d'une composante (relation ManyToMany)
    @Query("SELECT COUNT(c) FROM Campus c JOIN c.composantes comp WHERE comp.acronyme = :acronyme")
    Long countCampusByComposante(@Param("acronyme") String acronyme);

    // Compter le nombre de bâtiments d'une composante
    @Query("SELECT COUNT(b) FROM Batiment b JOIN b.campus.composantes comp WHERE comp.acronyme = :acronyme")
    Long countBatimentsByComposante(@Param("acronyme") String acronyme);

    // Compter le nombre de salles d'une composante
    @Query("SELECT COUNT(s) FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme")
    Long countSallesByComposante(@Param("acronyme") String acronyme);

    // Capacité totale d'une composante (somme de toutes les salles)
    @Query("SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme")
    Long sumCapaciteByComposante(@Param("acronyme") String acronyme);

    // Salles par type dans une composante
    @Query("SELECT s FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme AND s.types = :typeS")
    List<Object> findSallesByComposanteAndType(@Param("acronyme") String acronyme, @Param("typeS") String typeS);

    // Compter les salles par type dans une composante
    @Query("SELECT s.types, COUNT(s) FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme GROUP BY s.types")
    List<Object[]> countSallesByTypeInComposante(@Param("acronyme") String acronyme);

    // Salles accessibles PMR dans une composante
    @Query("SELECT s FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme AND s.acces = 'oui'")
    List<Object> findSallesAccessiblesByComposante(@Param("acronyme") String acronyme);

    // Compter salles accessibles PMR
    @Query("SELECT COUNT(s) FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme AND s.acces = 'oui'")
    Long countSallesAccessiblesByComposante(@Param("acronyme") String acronyme);

    // Salles TD/TP accessibles d'une composante avec capacité min/max
    @Query("SELECT s FROM Salle s JOIN s.batiment.campus.composantes comp WHERE comp.acronyme = :acronyme " +
           "AND s.types = :typeS AND s.acces = 'oui' " +
           "AND s.capacite >= :minCapacite AND s.capacite <= :maxCapacite")
    List<Object> findSallesByComposanteTypeAndCapacite(
        @Param("acronyme") String acronyme,
        @Param("typeS") String typeS,
        @Param("minCapacite") int minCapacite,
        @Param("maxCapacite") int maxCapacite);

    // Campus d'une composante (relation ManyToMany inverse)
    @Query("SELECT c FROM Campus c JOIN c.composantes comp WHERE comp.acronyme = :acronyme")
    List<Object> findCampusByComposante(@Param("acronyme") String acronyme);
}

