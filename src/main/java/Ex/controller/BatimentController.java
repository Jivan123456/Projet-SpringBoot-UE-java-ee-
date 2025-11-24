package Ex.controller;

import Ex.dto.BatimentDTO;
import Ex.service.BatimentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controller CRUD pour l'entité Batiment (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/batiment")
public class BatimentController {

    @Autowired
    private BatimentService batimentService;

    /**
     * GET /api/batiment
     * Liste tous les bâtiments (DTOs)
     */
    @GetMapping
    public ResponseEntity<List<BatimentDTO>> getAll() {
        return ResponseEntity.ok(batimentService.getAll());
    }

    /**
     * GET /api/batiment/{codeb}
     * Récupère un bâtiment par son code (DTO)
     */
    @GetMapping("/{codeb}")
    public ResponseEntity<?> getById(@PathVariable String codeb) {
        Optional<BatimentDTO> batiment = batimentService.getById(codeb);
        if (batiment.isPresent()) {
            return ResponseEntity.ok(batiment.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Bâtiment non trouvé: " + codeb);
    }

    /**
     * POST /api/batiment
     * Créer un nouveau bâtiment
     * Body JSON:
     * {
     *   "codeB": "B1",
     *   "anneeC": 2020,
     *   "campusId": "Campus Triolet"
     * }
     */
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody BatimentDTO dto) {
        try {
            BatimentDTO saved = batimentService.create(dto);
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
     * PUT /api/batiment/{codeb}
     * Modifier un bâtiment existant
     * Body JSON:
     * {
     *   "codeB": "B1",
     *   "anneeC": 2021,
     *   "campusId": "Campus Triolet"
     * }
     */
    @PutMapping("/{codeb}")
    public ResponseEntity<?> update(@PathVariable String codeb, @Valid @RequestBody BatimentDTO dto) {
        try {
            BatimentDTO updated = batimentService.update(codeb, dto);
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
     * DELETE /api/batiment/{codeb}
     * Supprimer un bâtiment
     */
    @DeleteMapping("/{codeb}")
    public ResponseEntity<?> delete(@PathVariable String codeb) {
        try {
            if (!batimentService.exists(codeb)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Bâtiment non trouvé: " + codeb);
            }
            batimentService.delete(codeb);
            return ResponseEntity.ok("Bâtiment supprimé: " + codeb);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }

    /**
     * GET /api/batiment/campus/{nomCampus}
     * Liste les bâtiments d'un campus (DTOs)
     */
    @GetMapping("/campus/{nomCampus}")
    public ResponseEntity<List<BatimentDTO>> getByCampus(@PathVariable String nomCampus) {
        List<BatimentDTO> batiments = batimentService.getByCampus(nomCampus);
        return ResponseEntity.ok(batiments);
    }
}

