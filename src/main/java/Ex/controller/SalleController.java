package Ex.controller;

import Ex.dto.SalleDTO;
import Ex.service.SalleService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Salle (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/salle")
public class SalleController {

    @Autowired
    private SalleService salleService;

    /**
     * GET /api/salle
     * Liste toutes les salles (DTOs)
     */
    @GetMapping
    public ResponseEntity<List<SalleDTO>> getAll() {
        return ResponseEntity.ok(salleService.getAll());
    }

    /**
     * GET /api/salle/{nums}
     * Récupère une salle par son numéro (DTO)
     */
    @GetMapping("/{nums}")
    public ResponseEntity<?> getById(@PathVariable String nums) {
        Optional<SalleDTO> salle = salleService.getById(nums);
        if (salle.isPresent()) {
            return ResponseEntity.ok(salle.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Salle non trouvée: " + nums);
    }

    /**
     * POST /api/salle
     * Créer une nouvelle salle
     * Body JSON:
     * {
     *   "numS": "T101",
     *   "capacite": 30,
     *   "typeS": "td",
     *   "acces": "oui",
     *   "etage": "1",
     *   "batimentId": "Bat9"
     * }
     */
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody SalleDTO dto) {
        try {
            SalleDTO saved = salleService.create(dto);
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
     * PUT /api/salle/{nums}
     * Modifier une salle existante
     * Body JSON:
     * {
     *   "numS": "T101",
     *   "capacite": 35,
     *   "typeS": "td",
     *   "acces": "oui",
     *   "etage": "1",
     *   "batimentId": "Bat9"
     * }
     */
    @PutMapping("/{nums}")
    public ResponseEntity<?> update(@PathVariable String nums, @Valid @RequestBody SalleDTO dto) {
        try {
            SalleDTO updated = salleService.update(nums, dto);
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
     * DELETE /api/salle/{nums}
     * Supprimer une salle
     */
    @DeleteMapping("/{nums}")
    public ResponseEntity<?> delete(@PathVariable String nums) {
        try {
            if (!salleService.exists(nums)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Salle non trouvée: " + nums);
            }
            salleService.delete(nums);
            return ResponseEntity.ok("Salle supprimée: " + nums);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }

    /**
     * GET /api/salle/batiment/{codeBatiment}
     * Liste les salles d'un bâtiment (DTOs)
     */
    @GetMapping("/batiment/{codeBatiment}")
    public ResponseEntity<List<SalleDTO>> getByBatiment(@PathVariable String codeBatiment) {
        List<SalleDTO> salles = salleService.getByBatiment(codeBatiment);
        return ResponseEntity.ok(salles);
    }

    /**
     * GET /api/salle/type/{types}
     * Liste les salles d'un type (td, tp, amphi, sc, numerique) (DTOs)
     */
    @GetMapping("/type/{types}")
    public ResponseEntity<List<SalleDTO>> getByType(@PathVariable String types) {
        List<SalleDTO> salles = salleService.getByType(types);
        return ResponseEntity.ok(salles);
    }

    /**
     * GET /api/salle/accessibles
     * Liste les salles accessibles PMR (DTOs)
     */
    @GetMapping("/accessibles")
    public ResponseEntity<List<SalleDTO>> getAccessibles() {
        List<SalleDTO> salles = salleService.getAccessibles();
        return ResponseEntity.ok(salles);
    }

    /**
     * GET /api/salle/capacite
     * Recherche par capacité minimale et maximale (DTOs)
     * Ex: /api/salle/capacite?min=20&max=50
     */
    @GetMapping("/capacite")
    public ResponseEntity<List<SalleDTO>> getByCapacite(
            @RequestParam(defaultValue = "0") int min,
            @RequestParam(defaultValue = "1000") int max) {
        List<SalleDTO> salles = salleService.getByCapacite(min, max);
        return ResponseEntity.ok(salles);
    }
}

