package Ex.controller;

import Ex.dto.UniversiteDTO;
import Ex.service.UniversiteService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Universite (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/universite")
public class UniversiteController {

    @Autowired
    private UniversiteService universiteService;

    /**
     * GET /api/universite
     * Liste toutes les universités (DTOs)
     */
    @GetMapping
    public ResponseEntity<List<UniversiteDTO>> getAll() {
        return ResponseEntity.ok(universiteService.getAll());
    }

    /**
     * GET /api/universite/{acronyme}
     * Récupère une université par son acronyme (DTO)
     */
    @GetMapping("/{acronyme}")
    public ResponseEntity<?> getById(@PathVariable String acronyme) {
        Optional<UniversiteDTO> universite = universiteService.getById(acronyme);
        if (universite.isPresent()) {
            return ResponseEntity.ok(universite.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Université non trouvée: " + acronyme);
    }

    /**
     * POST /api/universite
     * Créer une nouvelle université
     * Body JSON:
     * {
     *   "acronyme": "UM",
     *   "nom": "Université de Montpellier",
     *   "creation": 1289,
     *   "presidence": "Président UM"
     * }
     */
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody UniversiteDTO dto) {
        try {
            UniversiteDTO saved = universiteService.create(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la création: " + e.getMessage());
        }
    }

    /**
     * PUT /api/universite/{acronyme}
     * Modifier une université existante
     * Body JSON:
     * {
     *   "acronyme": "UM",
     *   "nom": "Université de Montpellier",
     *   "creation": 1289,
     *   "presidence": "Nouveau Président"
     * }
     */
    @PutMapping("/{acronyme}")
    public ResponseEntity<?> update(@PathVariable String acronyme, @Valid @RequestBody UniversiteDTO dto) {
        try {
            UniversiteDTO updated = universiteService.update(acronyme, dto);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Université non trouvée: " + acronyme);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la mise à jour: " + e.getMessage());
        }
    }

    /**
     * DELETE /api/universite/{acronyme}
     * Supprimer une université
     */
    @DeleteMapping("/{acronyme}")
    public ResponseEntity<?> delete(@PathVariable String acronyme) {
        try {
            universiteService.delete(acronyme);
            return ResponseEntity.ok("Université supprimée: " + acronyme);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }
}

