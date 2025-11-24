package Ex.controller;

import Ex.dto.ComposanteDTO;
import Ex.service.ComposanteService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Composante (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/composante")
public class ComposanteController {

    @Autowired
    private ComposanteService composanteService;

    /**
     * GET /api/composante
     * Liste toutes les composantes (DTOs)
     */
    @GetMapping
    public ResponseEntity<List<ComposanteDTO>> getAll() {
        return ResponseEntity.ok(composanteService.getAll());
    }

    /**
     * GET /api/composante/{acronyme}
     * Récupère une composante par son acronyme (DTO)
     */
    @GetMapping("/{acronyme}")
    public ResponseEntity<?> getById(@PathVariable String acronyme) {
        Optional<ComposanteDTO> composante = composanteService.getById(acronyme);
        if (composante.isPresent()) {
            return ResponseEntity.ok(composante.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Composante non trouvée: " + acronyme);
    }

    /**
     * POST /api/composante
     * Créer une nouvelle composante
     * Body JSON:
     * {
     *   "acronyme": "FDS",
     *   "nom": "Faculté des Sciences",
     *   "responsable": "Dr. Sophie Bernard"
     * }
     */
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody ComposanteDTO dto) {
        try {
            ComposanteDTO saved = composanteService.create(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la création: " + e.getMessage());
        }
    }

    /**
     * PUT /api/composante/{acronyme}
     * Modifier une composante existante
     * Body JSON:
     * {
     *   "acronyme": "FDS",
     *   "nom": "Faculté des Sciences et Technologies",
     *   "responsable": "Dr. Marie Dupont"
     * }
     */
    @PutMapping("/{acronyme}")
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

    /**
     * DELETE /api/composante/{acronyme}
     * Supprimer une composante
     */
    @DeleteMapping("/{acronyme}")
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
}

