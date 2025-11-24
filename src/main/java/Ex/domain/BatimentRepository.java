package Ex.domain;

import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import Ex.modele.*;



/*

interface BatimentRepository utilise extends JpaRepository, ce qui lui fait hériter automatiquement
de méthodes invisibles pr fichier.

La méthode pour ajouter une ligne s'appelle save() (fournie par le parent) et non create.

méthode save() est intelligente : elle génère un INSERT si l'objet est nouveau (pas d'ID) ou un UPDATE s'il existe déjà.
Service appelle simplement repository.save(objet) pour faire le travail.

c'est héritage de Spring Data qui gère la création en coulisses, sans avoir de faire "create manuellement".


 */
@Repository
public interface BatimentRepository extends JpaRepository<Batiment, String> {
	// JPQL Query
	@Query("SELECT b FROM Batiment b WHERE b.codeB IN :ids")
	List<Batiment> findByIds(@Param("ids") List<String> ids);
	
	List<Batiment> findByCampus(Campus campus);

	// TP2 - Compter les bâtiments d'un campus
	@Query("SELECT COUNT(b) FROM Batiment b WHERE b.campus.nomC = :nomCampus")
	Long countByCampus(@Param("nomCampus") String nomCampus);
}