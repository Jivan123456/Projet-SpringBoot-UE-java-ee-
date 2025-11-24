package Ex.domain;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import Ex.modele.Campus;


@Repository
public interface CampusRepository extends JpaRepository<Ex.modele.Campus, String> {
	
	List<Campus> findByVille(String ville);
	
}
