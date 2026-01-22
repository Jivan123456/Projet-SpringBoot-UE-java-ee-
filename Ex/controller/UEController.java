package Ex.controller;

import Ex.modele.UE;
import Ex.modele.User;
import Ex.service.UEService;
import Ex.dto.UEWithProfesseursDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ue")
@CrossOrigin(origins = "*")
public class UEController {

    @Autowired
    private UEService ueService;

    // ========================================
    // Endpoints publics (lecture)
    // ========================================

    /**
     * Obtenir toutes les UE
     */
    @GetMapping
    public ResponseEntity<List<UEWithProfesseursDTO>> getAllUEs() {
        List<UE> ues = ueService.getAllUEs();
        List<UEWithProfesseursDTO> dtos = ues.stream()
                .map(UEWithProfesseursDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    /**
     * Obtenir une UE par son ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<UE> getUEById(@PathVariable Long id) {
        return ueService.getUEById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Rechercher des UE par nom
     */
    @GetMapping("/search")
    public ResponseEntity<List<UE>> searchUEs(@RequestParam String nom) {
        List<UE> ues = ueService.searchUEsByNom(nom);
        return ResponseEntity.ok(ues);
    }

    /**
     * Obtenir les UE d'une composante
     */
    @GetMapping("/composante/{acronyme}")
    public ResponseEntity<List<UE>> getUEsByComposante(@PathVariable String acronyme) {
        List<UE> ues = ueService.getUEsByComposante(acronyme);
        return ResponseEntity.ok(ues);
    }

    /**
     * Obtenir les UE par nombre de crédits
     */
    @GetMapping("/credits/{credits}")
    public ResponseEntity<List<UE>> getUEsByCredits(@PathVariable int credits) {
        List<UE> ues = ueService.getUEsByCredits(credits);
        return ResponseEntity.ok(ues);
    }

    // ========================================
    // Gestion UE (Admin uniquement)
    // ========================================

    /**
     * Créer une nouvelle UE
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UE> createUE(@RequestBody UE ue) {
        try {
            UE createdUE = ueService.createUE(ue);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdUE);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Modifier une UE
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UE> updateUE(@PathVariable Long id, @RequestBody UE ueDetails) {
        try {
            UE updatedUE = ueService.updateUE(id, ueDetails);
            return ResponseEntity.ok(updatedUE);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Supprimer une UE
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUE(@PathVariable Long id) {
        try {
            ueService.deleteUE(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // ========================================
    // Gestion Professeur - UE
    // ========================================

    /**
     * Obtenir les UE d'un professeur
     */
    @GetMapping("/professeur/{professeurId}")
    public ResponseEntity<List<UEWithProfesseursDTO>> getUEsByProfesseur(@PathVariable Long professeurId) {
        List<UE> ues = ueService.getUEsByProfesseur(professeurId);
        List<UEWithProfesseursDTO> dtos = ues.stream()
                .map(UEWithProfesseursDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    /**
     * Obtenir les professeurs d'une UE
     */
    @GetMapping("/{ueId}/professeurs")
    public ResponseEntity<List<User>> getProfesseursByUE(@PathVariable Long ueId) {
        try {
            List<User> professeurs = ueService.getProfesseursByUE(ueId);
            return ResponseEntity.ok(professeurs);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Assigner un professeur à une UE
     */
    @PostMapping("/{ueId}/professeur/{professeurId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('PROFESSEUR')")
    public ResponseEntity<UE> assignProfesseur(
            @PathVariable Long ueId,
            @PathVariable Long professeurId) {
        try {
            UE ue = ueService.assignProfesseurToUE(ueId, professeurId);
            return ResponseEntity.ok(ue);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Retirer un professeur d'une UE
     */
    @DeleteMapping("/{ueId}/professeur/{professeurId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('PROFESSEUR')")
    public ResponseEntity<UE> removeProfesseur(
            @PathVariable Long ueId,
            @PathVariable Long professeurId) {
        try {
            UE ue = ueService.removeProfesseurFromUE(ueId, professeurId);
            return ResponseEntity.ok(ue);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // ========================================
    // Gestion Étudiant - UE
    // ========================================

    /**
     * Obtenir les UE auxquelles un étudiant est inscrit
     */
    @GetMapping("/etudiant/{etudiantId}")
    public ResponseEntity<List<UEWithProfesseursDTO>> getUEsByEtudiant(@PathVariable Long etudiantId) {
        List<UE> ues = ueService.getUEsByEtudiant(etudiantId);
        List<UEWithProfesseursDTO> dtos = ues.stream()
                .map(UEWithProfesseursDTO::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    /**
     * Obtenir les étudiants inscrits à une UE
     */
    @GetMapping("/{ueId}/etudiants")
    public ResponseEntity<List<User>> getEtudiantsByUE(@PathVariable Long ueId) {
        try {
            List<User> etudiants = ueService.getEtudiantsByUE(ueId);
            return ResponseEntity.ok(etudiants);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Inscrire un étudiant à une UE
     */
    @PostMapping("/{ueId}/etudiant/{etudiantId}")
    @PreAuthorize("hasRole('ETUDIANT') or hasRole('ADMIN')")
    public ResponseEntity<UE> inscrireEtudiant(
            @PathVariable Long ueId,
            @PathVariable Long etudiantId) {
        try {
            UE ue = ueService.inscrireEtudiantToUE(ueId, etudiantId);
            return ResponseEntity.ok(ue);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    /**
     * Désinscrire un étudiant d'une UE
     */
    @DeleteMapping("/{ueId}/etudiant/{etudiantId}")
    @PreAuthorize("hasRole('ETUDIANT') or hasRole('ADMIN')")
    public ResponseEntity<UE> desinscrireEtudiant(
            @PathVariable Long ueId,
            @PathVariable Long etudiantId) {
        try {
            UE ue = ueService.desinscrireEtudiantFromUE(ueId, etudiantId);
            return ResponseEntity.ok(ue);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // ========================================
    // Statistiques
    // ========================================

    /**
     * Obtenir les statistiques d'une UE
     */
    @GetMapping("/{ueId}/stats")
    public ResponseEntity<Map<String, Object>> getUEStats(@PathVariable Long ueId) {
        try {
            Long nbProfesseurs = ueService.countProfesseurs(ueId);
            Long nbEtudiants = ueService.countEtudiants(ueId);

            return ResponseEntity.ok(Map.of(
                    "ueId", ueId,
                    "nombreProfesseurs", nbProfesseurs,
                    "nombreEtudiants", nbEtudiants
            ));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

