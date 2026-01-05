package Ex.controller;

import Ex.dto.BatimentDTO;
import Ex.dto.CampusDTO;
import Ex.service.BatimentService;
import Ex.service.CampusService;
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
 * Controller CRUD pour l'entité Campus (utilise des DTOs)
 */
@RestController
@RequestMapping("/api/campus")
@CrossOrigin(origins = "*")
@Tag(name = "Campus", description = "Gestion des campus universitaires (Triolet, Elearning Center, etc.)")
public class CampusController {

    @Autowired
    private CampusService campusService;

    @Autowired
    private BatimentService batimentService;

    @GetMapping
    @Operation(
        summary = "Lister tous les campus",
        description = "Retourne la liste complète de tous les campus de toutes les universités avec leurs informations (nom, ville, université associée, bâtiments). Accessible à tous les utilisateurs connectés."
    )
    public ResponseEntity<List<CampusDTO>> getAll() {
        return ResponseEntity.ok(campusService.getAll());
    }

    @GetMapping("/{nomc}")
    @Operation(
        summary = "Obtenir un campus par son nom",
        description = "Récupère les détails complets d'un campus spécifique : nom, ville, université associée, liste des bâtiments et composantes. Exemple : 'Campus Triolet', 'Elearning Center'."
    )
    public ResponseEntity<?> getById(@PathVariable String nomc) {
        Optional<CampusDTO> campus = campusService.getById(nomc);
        if (campus.isPresent()) {
            return ResponseEntity.ok(campus.get());
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body("Campus non trouvé: " + nomc);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer un nouveau campus",
        description = "Permet de créer un nouveau campus dans le système. **Réservé aux administrateurs uniquement**. Le nom du campus doit être unique. L'université associée (universiteId) doit exister. Exemple : {\"nomC\": \"Campus Triolet\", \"ville\": \"Montpellier\", \"universiteId\": \"UM\"}"
    )
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

    @PutMapping("/{nomc}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Modifier un campus existant",
        description = "Met à jour les informations d'un campus existant (nom, ville, université associée). **Réservé aux administrateurs uniquement**. Le nom du campus peut être modifié si le nouveau nom n'existe pas déjà. Exemple : {\"ville\": \"Nîmes\", \"universiteId\": \"UPVD\"}"
    )
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

    @DeleteMapping("/{nomc}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Supprimer un campus",
        description = "Supprime définitivement un campus du système. **Réservé aux administrateurs uniquement**.  Cette action supprimera en cascade tous les bâtiments et salles associés à ce campus !"
    )
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

    @GetMapping("/ville/{ville}")
    @Operation(
        summary = "Lister les campus d'une ville",
        description = "Retourne tous les campus situés dans une ville spécifique (ex: Montpellier, Nîmes). Utile pour filtrer les campus par localisation géographique."
    )
    public ResponseEntity<List<CampusDTO>> getByVille(@PathVariable String ville) {
        List<CampusDTO> campus = campusService.getByVille(ville);
        return ResponseEntity.ok(campus);
    }

    /**
     * GET /api/campus/universite/{acronyme}
     * Liste les campus d'une université (DTOs)
     */
    @GetMapping("/universite/{acronyme}")
    @Operation(
        summary = "Lister les campus d'une université",
        description = "Retourne tous les campus appartenant à une université spécifique (ex: tous les campus de l'UM). Utile pour voir l'organisation géographique d'une université."
    )
    public ResponseEntity<List<CampusDTO>> getByUniversite(@PathVariable String acronyme) {
        List<CampusDTO> campus = campusService.getByUniversite(acronyme);
        return ResponseEntity.ok(campus);
    }

    /**
     * GET /api/campus/{nomc}/composantes
     * Obtenir les composantes d'un campus
     */
    @GetMapping("/{nomc}/composantes")
    @Operation(
        summary = "Lister les composantes d'un campus",
        description = "Retourne toutes les composantes (Facultés, Instituts) présentes sur un campus spécifique. Par exemple, la FDS sur le Campus Triolet. Relation ManyToMany."
    )
    public ResponseEntity<?> getComposantesByCampus(@PathVariable String nomc) {
        try {
            return ResponseEntity.ok(campusService.getComposantesByCampus(nomc));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Erreur: " + e.getMessage());
        }
    }

    /**
     * POST /api/campus/{nomc}/batiments
     * Créer un bâtiment directement depuis un campus (création en cascade)
     */
    @PostMapping("/{nomc}/batiments")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Créer un bâtiment depuis un campus (cascade)",
        description = "Crée un nouveau bâtiment en pré-remplissant automatiquement la relation avec le campus parent. " +
                     "**Réservé aux administrateurs uniquement**. " +
                     "Le backend vérifie que le campus existe et lie automatiquement le bâtiment. " +
                     "Exemple : POST /api/campus/Campus Triolet/batiments avec {\"codeB\": \"Bat10\", \"anneeC\": 2020}"
    )
    public ResponseEntity<?> createBatimentFromCampus(
            @PathVariable String nomc,
            @Valid @RequestBody BatimentDTO dto) {
        try {
            BatimentDTO created = batimentService.createFromCampus(nomc, dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        }
    }

    /**
     * POST /api/campus/{nomc}/composantes/{acronyme}
     * Associer une composante à un campus (retourne le CampusDTO mis à jour)
     */
    @PostMapping("/{nomc}/composantes/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "🔗 Associer une composante à un campus (ManyToMany)",
        description = "Ajoute une composante (Faculté, Institut) à un campus. **Réservé aux administrateurs uniquement**. " +
                     "Relation ManyToMany : une composante peut être sur plusieurs campus. " +
                     "Retourne le CampusDTO mis à jour avec la nouvelle composante. " +
                     "Exemple : POST /api/campus/Campus Triolet/composantes/FDS"
    )
    public ResponseEntity<?> associerComposante(@PathVariable String nomc, @PathVariable String acronyme) {
        try {
            CampusDTO updated = campusService.associerComposante(nomc, acronyme);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        }
    }

    /**
     * DELETE /api/campus/{nomc}/composantes/{acronyme}
     * Dissocier une composante d'un campus (retourne le CampusDTO mis à jour)
     */
    @DeleteMapping("/{nomc}/composantes/{acronyme}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Dissocier une composante d'un campus (ManyToMany)",
        description = "Retire l'association entre une composante et un campus. **Réservé aux administrateurs uniquement**. " +
                     "La composante elle-même n'est PAS supprimée, seulement le lien avec ce campus. " +
                     "Retourne le CampusDTO mis à jour. " +
                     "Exemple : DELETE /api/campus/Campus Triolet/composantes/FDS"
    )
    public ResponseEntity<?> dissocierComposante(@PathVariable String nomc, @PathVariable String acronyme) {
        try {
            CampusDTO updated = campusService.dissocierComposante(nomc, acronyme);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Erreur: " + e.getMessage());
        }
    }
}

