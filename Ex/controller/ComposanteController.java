package Ex.controller;

import Ex.dto.ComposanteDTO;
import Ex.service.ComposanteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Composante (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/composante")
@CrossOrigin(origins = "*")
@Tag(name = "Composantes", description = "Gestion des composantes universitaires (FDS, Facultés, Instituts, etc.)")
public class    ComposanteController {

    @Autowired
    private ComposanteService composanteService;

    @GetMapping
    @Operation(
        summary = "Lister toutes les composantes",
        description = "Retourne la liste complète de toutes les composantes universitaires (Facultés, Instituts, Écoles) avec leurs informations (acronyme, nom complet, responsable). Exemple : FDS (Faculté des Sciences). Accessible à tous les utilisateurs connectés."
    )
    public ResponseEntity<List<ComposanteDTO>> getAll() {
        return ResponseEntity.ok(composanteService.getAll());
    }

    @GetMapping("/{acronyme}")
    @Operation(
        summary = "Obtenir une composante par son acronyme",
        description = "Récupère les détails complets d'une composante spécifique : acronyme, nom complet, responsable, campus associés. Exemple : 'FDS' (Faculté des Sciences), 'IUT' (Institut Universitaire de Technologie)."
    )
    public ResponseEntity<?> getById(@PathVariable String acronyme) {
        Optional<ComposanteDTO> composante = composanteService.getById(acronyme);
        if (composante.isPresent()) {
            return ResponseEntity.ok(composante.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Composante non trouvée: " + acronyme);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer une nouvelle composante",
        description = "Permet de créer une nouvelle composante universitaire (Faculté, Institut, École). **Réservé aux administrateurs uniquement**. L'acronyme doit être unique. Exemple : {\"acronyme\": \"FDS\", \"nom\": \"Faculté des Sciences\", \"responsable\": \"Dr. Sophie Bernard\"}"
    )
    public ResponseEntity<?> create(@Valid @RequestBody ComposanteDTO dto) {
        try {
            ComposanteDTO saved = composanteService.create(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la création: " + e.getMessage());
        }
    }

    @PutMapping("/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Modifier une composante existante",
        description = "Met à jour les informations d'une composante existante (nom complet, responsable). **Réservé aux administrateurs uniquement**. L'acronyme ne peut pas être modifié. Exemple : {\"nom\": \"Faculté des Sciences et Technologies\", \"responsable\": \"Dr. Marie Dupont\"}"
    )
    public ResponseEntity<?> update(@PathVariable String acronyme, @Valid @RequestBody ComposanteDTO dto) {
        try {
            ComposanteDTO updated = composanteService.update(acronyme, dto);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Erreur: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la mise à jour: " + e.getMessage());
        }
    }

    @DeleteMapping("/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Supprimer une composante",
        description = "Supprime définitivement une composante du système. **Réservé aux administrateurs uniquement**. Cette action retire uniquement la composante, les campus associés ne seront pas supprimés (relation ManyToMany)."
    )
    public ResponseEntity<?> delete(@PathVariable String acronyme) {
        try {
            if (!composanteService.exists(acronyme)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Composante non trouvée: " + acronyme);
            }
            composanteService.delete(acronyme);
            return ResponseEntity.ok("Composante supprimée: " + acronyme);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }

    /**
     * GET /api/composante/{acronyme}/campus
     * Obtenir les campus où se trouve une composante
     */
    @GetMapping("/{acronyme}/campus")
    @Operation(
        summary = "Lister les campus d'une composante",
        description = "Retourne tous les campus où est présente une composante spécifique. Par exemple, les campus où se trouve la FDS (Faculté des Sciences). Relation ManyToMany."
    )
    public ResponseEntity<?> getCampusByComposante(@PathVariable String acronyme) {
        try {
            return ResponseEntity.ok(composanteService.getCampusByComposante(acronyme));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Erreur: " + e.getMessage());
        }
    }
}

