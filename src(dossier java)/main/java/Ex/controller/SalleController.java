package Ex.controller;

import Ex.dto.SalleDTO;
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
 * Controller CRUD pour l'entité Salle (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/salle")
@CrossOrigin(origins = "*")
@Tag(name = "Salles", description = "Gestion des salles de cours (TD, TP, Amphi, etc.)")
public class SalleController {

    @Autowired
    private SalleService salleService;

    @GetMapping
    @Operation(
        summary = "Lister toutes les salles",
        description = "Retourne la liste complète de toutes les salles de tous les bâtiments avec leurs informations (numéro, capacité, type, accessibilité PMR, étage, bâtiment associé). Accessible à tous les utilisateurs connectés."
    )
    public ResponseEntity<List<SalleDTO>> getAll() {
        return ResponseEntity.ok(salleService.getAll());
    }

    @GetMapping("/{nums}")
    @Operation(
        summary = "Obtenir une salle par son numéro",
        description = "Récupère les détails complets d'une salle spécifique : numéro, capacité, type (td/tp/amphi), accessibilité PMR, étage, bâtiment associé. Exemple : 'T101', 'N102'."
    )
    public ResponseEntity<?> getById(@PathVariable String nums) {
        Optional<SalleDTO> salle = salleService.getById(nums);
        if (salle.isPresent()) {
            return ResponseEntity.ok(salle.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Salle non trouvée: " + nums);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer une nouvelle salle",
        description = "Permet de créer une nouvelle salle dans un bâtiment. **Réservé aux administrateurs uniquement**. Le numéro de salle doit être unique. Le bâtiment associé (batimentId) doit exister. Types acceptés : 'td', 'tp', 'amphi'. Accessibilité PMR : 'oui' ou 'non'. Exemple : {\"numS\": \"T101\", \"capacite\": 30, \"typeS\": \"td\", \"acces\": \"oui\", \"etage\": \"1\", \"batimentId\": \"Bat9\"}"
    )
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

    @PutMapping("/{nums}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Modifier une salle existante",
        description = "Met à jour les informations d'une salle existante (numéro, capacité, type, accessibilité PMR, étage, bâtiment associé). **Réservé aux administrateurs uniquement**. Le numéro de salle peut être modifié si le nouveau numéro n'existe pas déjà. Exemple : {\"capacite\": 35, \"typeS\": \"tp\", \"acces\": \"non\"}"
    )
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


    @DeleteMapping("/{nums}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Supprimer une salle",
        description = "Supprime définitivement une salle du système. **Réservé aux administrateurs uniquement**. Cette action est irréversible."
    )
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

    @GetMapping("/batiment/{codeBatiment}")
    @Operation(
        summary = "Lister les salles d'un bâtiment",
        description = "Retourne toutes les salles d'un bâtiment spécifique avec leurs caractéristiques complètes. Utile pour consulter l'inventaire des salles d'un bâtiment. Exemple : 'Bat9', 'E-Learning-1'."
    )
    public ResponseEntity<List<SalleDTO>> getByBatiment(@PathVariable String codeBatiment) {
        List<SalleDTO> salles = salleService.getByBatiment(codeBatiment);
        return ResponseEntity.ok(salles);
    }

    @GetMapping("/type/{types}")
    @Operation(
        summary = "Lister les salles par type",
        description = "Retourne toutes les salles d'un type spécifique : 'td' (Travaux Dirigés), 'tp' (Travaux Pratiques), 'amphi' (Amphithéâtre), 'sc' (Salle de Cours), 'numerique' (Salle Numérique). Utile pour trouver rapidement toutes les salles d'un même type. Exemple : /api/salle/type/td"
    )
    public ResponseEntity<List<SalleDTO>> getByType(@PathVariable String types) {
        List<SalleDTO> salles = salleService.getByType(types);
        return ResponseEntity.ok(salles);
    }



    @GetMapping("/capacite")
    public ResponseEntity<List<SalleDTO>> getByCapacite(
            @RequestParam(defaultValue = "0") int min,
            @RequestParam(defaultValue = "1000") int max) {
        List<SalleDTO> salles = salleService.getByCapacite(min, max);
        return ResponseEntity.ok(salles);
    }
}

