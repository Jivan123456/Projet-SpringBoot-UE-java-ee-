package Ex.controller;

import Ex.dto.BatimentDTO;
import Ex.dto.SalleDTO;
import Ex.service.BatimentService;
import Ex.service.SalleService;
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
 * Controller CRUD pour l'entité Batiment (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/batiment")
@CrossOrigin(origins = "*")
@Tag(name = "Bâtiments", description = "Gestion des bâtiments universitaires (Bat9, E-Learning-1, etc.)")
public class BatimentController {

    @Autowired
    private BatimentService batimentService;

    @Autowired
    private SalleService salleService;

    @GetMapping
    @Operation(
        summary = "Lister tous les bâtiments",
        description = "Retourne la liste complète de tous les bâtiments de tous les campus avec leurs informations (code, année de construction, campus associé, nombre de salles). Accessible à tous les utilisateurs connectés."
    )
    public ResponseEntity<List<BatimentDTO>> getAll() {
        return ResponseEntity.ok(batimentService.getAll());
    }

    @GetMapping("/{codeb}")
    @Operation(
        summary = "Obtenir un bâtiment par son code",
        description = "Récupère les détails complets d'un bâtiment spécifique : code, année de construction, campus associé, liste des salles. Exemple : 'Bat9', 'E-Learning-1'."
    )
    public ResponseEntity<?> getById(@PathVariable String codeb) {
        Optional<BatimentDTO> batiment = batimentService.getById(codeb);
        if (batiment.isPresent()) {
            return ResponseEntity.ok(batiment.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Bâtiment non trouvé: " + codeb);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer un nouveau bâtiment",
        description = "Permet de créer un nouveau bâtiment dans un campus. **Réservé aux administrateurs uniquement**. Le code du bâtiment doit être unique. Le campus associé (campusId) doit exister. Exemple : {\"codeB\": \"B1\", \"anneeC\": 2020, \"campusId\": \"Campus Triolet\"}"
    )
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

    @PutMapping("/{codeb}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Modifier un bâtiment existant",
        description = "Met à jour les informations d'un bâtiment existant (code, année de construction, campus associé). **Réservé aux administrateurs uniquement**. Le code du bâtiment peut être modifié si le nouveau code n'existe pas déjà. Exemple : {\"anneeC\": 2021, \"campusId\": \"Elearning Center\"}"
    )
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

    @DeleteMapping("/{codeb}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Supprimer un bâtiment",
        description = "Supprime définitivement un bâtiment du système. **Réservé aux administrateurs uniquement**.  Cette action supprimera en cascade toutes les salles associées à ce bâtiment "
    )
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

    @GetMapping("/campus/{nomCampus}")
    @Operation(
        summary = "Lister les bâtiments d'un campus",
        description = "Retourne tous les bâtiments d'un campus spécifique avec leurs caractéristiques complètes. Utile pour consulter l'inventaire des bâtiments d'un campus. Exemple : 'Campus Triolet', 'Elearning Center'."
    )
    public ResponseEntity<List<BatimentDTO>> getByCampus(@PathVariable String nomCampus) {
        List<BatimentDTO> batiments = batimentService.getByCampus(nomCampus);
        return ResponseEntity.ok(batiments);
    }

    /**
     * POST /api/batiment/{codeB}/salles
     * Créer une salle directement depuis un bâtiment (création en cascade)
     */
    @PostMapping("/{codeB}/salles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Créer une salle depuis un bâtiment (cascade)",
        description = "Crée une nouvelle salle en pré-remplissant automatiquement la relation avec le bâtiment parent. " +
                     "**Réservé aux administrateurs uniquement**. " +
                     "Le backend vérifie que le bâtiment existe et lie automatiquement la salle. " +
                     "Exemple : POST /api/batiment/Bat9/salles avec {\"nums\": \"A205\", \"types\": \"TD\", \"capacite\": 30, \"acces\": \"Normal\"}"
    )
    public ResponseEntity<?> createSalleFromBatiment(
            @PathVariable String codeB,
            @Valid @RequestBody SalleDTO dto) {
        try {
            SalleDTO created = salleService.createFromBatiment(codeB, dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        }
    }
}

