package Ex.controller;

import Ex.dto.CampusDTO;
import Ex.service.CampusService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Campus (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/campus")
public class CampusController {

    @Autowired
    private CampusService campusService;

    /**
     * GET /api/campus
     * Liste tous les campus (DTOs)
     */
    @GetMapping
    public ResponseEntity<List<CampusDTO>> getAll() {
        return ResponseEntity.ok(campusService.getAll());
    }

    /**
     * GET /api/campus/{nomc}
     * Récupère un campus par son nom (DTO)
     */
    @GetMapping("/{nomc}")
    public ResponseEntity<?> getById(@PathVariable String nomc) {
        Optional<CampusDTO> campus = campusService.getById(nomc);
        if (campus.isPresent()) {
            return ResponseEntity.ok(campus.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Campus non trouvé: " + nomc);
    }

    /**
     * POST /api/campus
     * Créer un nouveau campus
     * Body JSON:
     * {
     *   "nomC": "Campus Triolet",
     *   "ville": "Montpellier",
     *   "universiteId": "UM"
     * }
     */
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody CampusDTO dto) {
        try {
            CampusDTO saved = campusService.create(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la création: " + e.getMessage());
        }
    }

    /**
     * PUT /api/campus/{nomc}
     * Modifier un campus existant
     * Body JSON:
     * {
     *   "nomC": "Campus Triolet",
     *   "ville": "Nîmes",
     *   "universiteId": "UM"
     * }
     */
    @PutMapping("/{nomc}")
    public ResponseEntity<?> update(@PathVariable String nomc, @Valid @RequestBody CampusDTO dto) {
        try {
            CampusDTO updated = campusService.update(nomc, dto);
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
     * DELETE /api/campus/{nomc}
     * Supprimer un campus
     */
    @DeleteMapping("/{nomc}")
    public ResponseEntity<?> delete(@PathVariable String nomc) {
        try {
            if (!campusService.exists(nomc)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Campus non trouvé: " + nomc);
            }
            campusService.delete(nomc);
            return ResponseEntity.ok("Campus supprimé: " + nomc);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }

    /**
     * GET /api/campus/ville/{ville}
     * Liste les campus d'une ville (DTOs)
     */
    @GetMapping("/ville/{ville}")
    public ResponseEntity<List<CampusDTO>> getByVille(@PathVariable String ville) {
        List<CampusDTO> campus = campusService.getByVille(ville);
        return ResponseEntity.ok(campus);
    }

    /**
     * GET /api/campus/universite/{acronyme}
     * Liste les campus d'une université (DTOs)
     */
    @GetMapping("/universite/{acronyme}")
    public ResponseEntity<List<CampusDTO>> getByUniversite(@PathVariable String acronyme) {
        List<CampusDTO> campus = campusService.getByUniversite(acronyme);
        return ResponseEntity.ok(campus);
    }
}

