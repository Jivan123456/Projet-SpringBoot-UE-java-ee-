package Ex.service;

import Ex.domain.UERepository;
import Ex.domain.UserRepository;
import Ex.modele.UE;
import Ex.modele.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UEService {

    @Autowired
    private UERepository ueRepository;

    @Autowired
    private UserRepository userRepository;

    // ========================================
    // Méthodes CRUD de base
    // ========================================

    public List<UE> getAllUEs() {
        return ueRepository.findAllOrderByNom();
    }

    public Optional<UE> getUEById(Long id) {
        return ueRepository.findById(id);
    }

    public UE createUE(UE ue) {
        return ueRepository.save(ue);
    }

    public UE updateUE(Long id, UE ueDetails) {
        UE ue = ueRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + id));

        ue.setNom(ueDetails.getNom());
        ue.setDescription(ueDetails.getDescription());
        ue.setNbHeures(ueDetails.getNbHeures());
        ue.setCredits(ueDetails.getCredits());

        if (ueDetails.getComposante() != null) {
            ue.setComposante(ueDetails.getComposante());
        }

        return ueRepository.save(ue);
    }

    public void deleteUE(Long id) {
        UE ue = ueRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + id));
        ueRepository.delete(ue);
    }

    // ========================================
    // Recherches spécifiques
    // ========================================

    public List<UE> searchUEsByNom(String nom) {
        return ueRepository.findByNomContainingIgnoreCase(nom);
    }

    public List<UE> getUEsByComposante(String acronyme) {
        return ueRepository.findByComposanteOrderByNom(acronyme);
    }

    public List<UE> getUEsByCredits(int credits) {
        return ueRepository.findByCredits(credits);
    }

    public List<UE> getUEsWithMinHours(int nbHeures) {
        return ueRepository.findByNbHeuresGreaterThanEqual(nbHeures);
    }

    // ========================================
    // Gestion Professeur - UE
    // ========================================

    /**
     * Assigner un professeur à une UE
     */
    public UE assignProfesseurToUE(Long ueId, Long professeurId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));

        User professeur = userRepository.findById(professeurId)
            .orElseThrow(() -> new RuntimeException("Professeur non trouvé avec l'id: " + professeurId));

        if (!professeur.isProfesseur()) {
            throw new RuntimeException("L'utilisateur n'est pas un professeur");
        }

        ue.addProfesseur(professeur);
        return ueRepository.save(ue);
    }

    /**
     * Retirer un professeur d'une UE
     */
    public UE removeProfesseurFromUE(Long ueId, Long professeurId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));

        User professeur = userRepository.findById(professeurId)
            .orElseThrow(() -> new RuntimeException("Professeur non trouvé avec l'id: " + professeurId));

        ue.removeProfesseur(professeur);
        return ueRepository.save(ue);
    }

    /**
     * Obtenir les UE qu'un professeur peut enseigner
     */
    public List<UE> getUEsByProfesseur(Long professeurId) {
        return ueRepository.findByProfesseurId(professeurId);
    }

    /**
     * Obtenir les professeurs d'une UE
     */
    public List<User> getProfesseursByUE(Long ueId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));
        return List.copyOf(ue.getProfesseurs());
    }

    // ========================================
    // Gestion Étudiant - UE
    // ========================================

    /**
     * Inscrire un étudiant à une UE
     */
    public UE inscrireEtudiantToUE(Long ueId, Long etudiantId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));

        User etudiant = userRepository.findById(etudiantId)
            .orElseThrow(() -> new RuntimeException("Étudiant non trouvé avec l'id: " + etudiantId));

        if (!etudiant.isEtudiant()) {
            throw new RuntimeException("L'utilisateur n'est pas un étudiant");
        }

        ue.addEtudiant(etudiant);
        return ueRepository.save(ue);
    }

    /**
     * Désinscrire un étudiant d'une UE
     */
    public UE desinscrireEtudiantFromUE(Long ueId, Long etudiantId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));

        User etudiant = userRepository.findById(etudiantId)
            .orElseThrow(() -> new RuntimeException("Étudiant non trouvé avec l'id: " + etudiantId));

        ue.removeEtudiant(etudiant);
        return ueRepository.save(ue);
    }

    /**
     * Obtenir les UE auxquelles un étudiant est inscrit
     */
    public List<UE> getUEsByEtudiant(Long etudiantId) {
        return ueRepository.findByEtudiantId(etudiantId);
    }

    /**
     * Obtenir les étudiants inscrits à une UE
     */
    public List<User> getEtudiantsByUE(Long ueId) {
        UE ue = ueRepository.findById(ueId)
            .orElseThrow(() -> new RuntimeException("UE non trouvée avec l'id: " + ueId));
        return List.copyOf(ue.getEtudiants());
    }

    // ========================================
    // Statistiques
    // ========================================

    /**
     * Compter le nombre de professeurs pour une UE
     */
    public Long countProfesseurs(Long ueId) {
        return ueRepository.countProfesseursByUeId(ueId);
    }

    /**
     * Compter le nombre d'étudiants inscrits à une UE
     */
    public Long countEtudiants(Long ueId) {
        return ueRepository.countEtudiantsByUeId(ueId);
    }

    /**
     * Vérifier si une UE existe
     */
    public boolean existsByNomAndComposante(String nom, String acronyme) {
        return ueRepository.existsByNomAndComposante(nom, acronyme);
    }
}

