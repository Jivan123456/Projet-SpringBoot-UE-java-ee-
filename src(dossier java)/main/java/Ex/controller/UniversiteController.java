package Ex.controller;

import Ex.dto.CampusDTO;
import Ex.dto.ComposanteDTO;
import Ex.dto.UniversiteDTO;
import Ex.service.UniversiteService;
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
 * Controller CRUD pour l'entité Universite (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/universite")
@CrossOrigin(origins = "*")
@Tag(name = "Universités", description = "Gestion des universités (UM, UPVD, etc.)")
public class UniversiteController {

    @Autowired
    private UniversiteService universiteService;

    @GetMapping
    @Operation(
        summary = "Lister toutes les universités",
        description = "Retourne la liste complète de toutes les universités enregistrées dans le système avec leurs informations (acronyme, nom, année de création, présidence). Accessible à tous les utilisateurs connectés."
    )
    public ResponseEntity<List<UniversiteDTO>> getAll() {
        return ResponseEntity.ok(universiteService.getAll());
    }

    @GetMapping("/{acronyme}")
    @Operation(
        summary = "Obtenir une université par son acronyme",
        description = "Récupère les détails d'une université spécifique en utilisant son acronyme (ex: UM, UPVD). Retourne les informations complètes : nom, année de création, présidence, campus associés."
    )
    public ResponseEntity<?> getById(@PathVariable String acronyme) {
        Optional<UniversiteDTO> universite = universiteService.getById(acronyme);
        if (universite.isPresent()) {
            return ResponseEntity.ok(universite.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Université non trouvée: " + acronyme);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer une nouvelle université",
        description = "Permet de créer une nouvelle université dans le système. **Réservé aux administrateurs uniquement**. L'acronyme doit être unique. Exemple de données requises : {\"acronyme\": \"UM\", \"nom\": \"Université de Montpellier\", \"creation\": 1289, \"presidence\": \"Président UM\"}"
    )
    public ResponseEntity<?> create(@Valid @RequestBody UniversiteDTO dto) {
        try {
            UniversiteDTO saved = universiteService.create(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur lors de la création: " + e.getMessage());
        }
    }

    @PutMapping("/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Modifier une université existante",
        description = "Met à jour les informations d'une université existante (nom, année de création, présidence). **Réservé aux administrateurs uniquement**. L'acronyme ne peut pas être modifié. Exemple : {\"nom\": \"Nouveau nom\", \"presidence\": \"Nouveau président\"}"
    )
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

    @DeleteMapping("/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Supprimer une université",
        description = "Supprime définitivement une université du système. **Réservé aux administrateurs uniquement**. ⚠️ ATTENTION : Cette action supprimera en cascade tous les campus, bâtiments et salles associés à cette université !"
    )
    public ResponseEntity<?> delete(@PathVariable String acronyme) {
        try {
            universiteService.delete(acronyme);
            return ResponseEntity.ok("Université supprimée: " + acronyme);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erreur lors de la suppression: " + e.getMessage());
        }
    }

    @GetMapping("/{acronyme}/composantes")
    @Operation(
        summary = "Lister les composantes d'une université",
        description = "Retourne toutes les composantes (UFR, Écoles, Instituts) qui appartiennent administrativement à cette université. Ex: Polytech, FDS pour l'UM."
    )
    public ResponseEntity<?> getComposantesByUniversite(@PathVariable String acronyme) {
        try {
            List<ComposanteDTO> composantes = universiteService.getComposantesByUniversite(acronyme);
            return ResponseEntity.ok(composantes);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Université non trouvée: " + acronyme);
        }
    }

    /**
     * POST /api/universite/{acronyme}/campus
     * Créer un campus directement depuis une université (création en cascade)
     */
    @PostMapping("/{acronyme}/campus")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Créer un campus depuis une université (cascade)",
        description = "Crée un nouveau campus en pré-remplissant automatiquement la relation avec l'université parente. " +
                     "**Réservé aux administrateurs uniquement**. " +
                     "Le backend vérifie que l'université existe et lie automatiquement le campus. " +
                     "Exemple : POST /api/universite/UM/campus avec {\"nomC\": \"Campus Science\", \"ville\": \"Montpellier\"}"
    )
    public ResponseEntity<?> createCampusFromUniversite(
            @PathVariable String acronyme,
            @Valid @RequestBody CampusDTO dto) {
        try {
            CampusDTO created = universiteService.createCampusFromUniversite(acronyme, dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        }
    }
}

