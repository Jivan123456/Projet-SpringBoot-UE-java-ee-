package Ex.domain;

import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import Ex.modele.*;




@RepositoryRestResource(exported = false)
public interface BatimentRepository extends JpaRepository<Batiment, String> {
	// JPQL Query
	@Query("SELECT b FROM Batiment b WHERE b.codeB IN :ids")
	List<Batiment> findByIds(@Param("ids") List<String> ids);
	
	List<Batiment> findByCampus(Campus campus);

	// TP2 - Compter les bâtiments d'un campus
	@Query("SELECT COUNT(b) FROM Batiment b WHERE b.campus.nomC = :nomCampus")
	Long countByCampus(@Param("nomCampus") String nomCampus);

	// ==================== RECHERCHES AVANCÉES ====================

	// Bâtiments par université
	@Query("SELECT b FROM Batiment b WHERE b.campus.universite.acronyme = :acronyme " +
	       "ORDER BY b.campus.nomC, b.anneeC DESC")
	List<Batiment> findByUniversite(@Param("acronyme") String acronyme);

	// Bâtiments par ville
	@Query("SELECT b FROM Batiment b WHERE b.campus.ville = :ville " +
	       "ORDER BY b.campus.nomC, b.codeB")
	List<Batiment> findByVille(@Param("ville") String ville);

	// Bâtiments les plus récents (année >= X)
	@Query("SELECT b FROM Batiment b WHERE b.anneeC >= :anneeMin " +
	       "ORDER BY b.anneeC DESC")
	List<Batiment> findRecentBatiments(@Param("anneeMin") int anneeMin);

	// Bâtiments avec le plus de salles
	@Query("SELECT b.codeB, b.campus.nomC, COUNT(s) FROM Batiment b " +
	       "LEFT JOIN b.salles s " +
	       "GROUP BY b.codeB, b.campus.nomC " +
	       "ORDER BY COUNT(s) DESC")
	List<Object[]> findBatimentsWithMostSalles();

	// Bâtiments avec capacité totale > X
	@Query("SELECT b FROM Batiment b WHERE " +
	       "(SELECT COALESCE(SUM(s.capacite), 0) FROM Salle s WHERE s.batiment = b) >= :minCapacite")
	List<Batiment> findBatimentsWithMinCapacite(@Param("minCapacite") int minCapacite);

	// Statistiques par bâtiment : nombre de salles et capacité totale
	@Query("SELECT b.codeB, b.anneeC, b.campus.nomC, b.campus.ville, " +
	       "COUNT(s.nums), COALESCE(SUM(s.capacite), 0) " +
	       "FROM Batiment b " +
	       "LEFT JOIN b.salles s " +
	       "GROUP BY b.codeB, b.anneeC, b.campus.nomC, b.campus.ville " +
	       "ORDER BY b.campus.ville, b.campus.nomC")
	List<Object[]> getStatistiquesCompletes();

	// Bâtiments par année de construction (groupés)
	@Query("SELECT b.anneeC, COUNT(b) FROM Batiment b " +
	       "GROUP BY b.anneeC " +
	       "ORDER BY b.anneeC DESC")
	List<Object[]> countBatimentsByAnnee();
}