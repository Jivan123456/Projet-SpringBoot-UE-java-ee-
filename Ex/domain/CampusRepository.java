package Ex.domain;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.stereotype.Repository;

import Ex.modele.Campus;


@RepositoryRestResource(exported = false)
public interface CampusRepository extends JpaRepository<Ex.modele.Campus, String> {
	
	List<Campus> findByVille(String ville);
	
	// ==================== RECHERCHES AVANCÉES ====================

	// Campus par université
	@Query("SELECT c FROM Campus c WHERE c.universite.acronyme = :acronyme")
	List<Campus> findByUniversite(@Param("acronyme") String acronyme);

	// Campus avec le plus de bâtiments (top N)
	@Query("SELECT c.nomC, COUNT(b) FROM Campus c LEFT JOIN c.batiments b " +
	       "GROUP BY c.nomC ORDER BY COUNT(b) DESC")
	List<Object[]> findCampusWithMostBatiments();

	// Campus avec le plus de salles
	@Query("SELECT c.nomC, COUNT(s) FROM Campus c " +
	       "LEFT JOIN c.batiments b " +
	       "LEFT JOIN b.salles s " +
	       "GROUP BY c.nomC ORDER BY COUNT(s) DESC")
	List<Object[]> findCampusWithMostSalles();

	// Campus avec capacité totale > X
	@Query("SELECT c FROM Campus c WHERE " +
	       "(SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s WHERE s.batiment.campus = c) >= :minCapacite")
	List<Campus> findCampusWithMinCapacite(@Param("minCapacite") int minCapacite);

	// Statistiques par campus : nombre de bâtiments, salles, capacité
	@Query("SELECT c.nomC, c.ville, c.universite.acronyme, " +
	       "COUNT(DISTINCT b.codeB), " +
	       "COUNT(s.nums), " +
	       "COALESCE(SUM(s.capacite), 0) " +
	       "FROM Campus c " +
	       "LEFT JOIN c.batiments b " +
	       "LEFT JOIN b.salles s " +
	       "GROUP BY c.nomC, c.ville, c.universite.acronyme " +
	       "ORDER BY c.nomC")
	List<Object[]> getStatistiquesCompletes();

	// Campus avec composantes (ManyToMany)
	@Query("SELECT c FROM Campus c JOIN c.composantes comp WHERE comp.acronyme = :acronyme")
	List<Campus> findByComposante(@Param("acronyme") String acronyme);
}
