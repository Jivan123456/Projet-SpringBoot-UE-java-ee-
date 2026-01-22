package Ex.controller;

import Ex.dto.SalleDTO;
import Ex.service.RechercheAvanceeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controller pour les recherches avancées et statistiques
 * Endpoints intelligents pour étudiants, professeurs et administrateurs
 */
@RestController
@RequestMapping("/api/recherche")
@CrossOrigin(origins = "*")
@Tag(name = "Recherches Avancées", description = "Endpoints intelligents de recherche multicritères et statistiques pour étudiants, professeurs et administrateurs")
public class RechercheAvanceeController {

    @Autowired
    private RechercheAvanceeService rechercheService;

    // ==================== RECHERCHES POUR ÉTUDIANTS ====================

    @GetMapping("/salles-revision")
    @Operation(
        summary = "Trouver des salles pour réviser",
        description = "Recherche des salles adaptées aux révisions : petites salles TD/TP (10-40 places par défaut), avec option accessibilité PMR, dans une ville spécifique. **Accessible à tous les étudiants.** Paramètres : ville (obligatoire), minCap (défaut: 10), maxCap (défaut: 40), pmr (défaut: false). Exemple : /api/recherche/salles-revision?ville=Montpellier&minCap=10&maxCap=30&pmr=true"
    )
    public ResponseEntity<List<SalleDTO>> getSallesPourReviser(
            @RequestParam(required = true) String ville,
            @RequestParam(defaultValue = "10") int minCap,
            @RequestParam(defaultValue = "40") int maxCap,
            @RequestParam(defaultValue = "false") boolean pmr) {

        List<SalleDTO> salles = rechercheService.findSallesPourReviser(minCap, maxCap, pmr, ville);
        return ResponseEntity.ok(salles);
    }

    /**
     * GET /api/recherche/salles-capacite
     * Chercher par plage de capacité
     *
     * Exemple: GET /api/recherche/salles-capacite?minCap=20&maxCap=50
     */
    @GetMapping("/salles-capacite")
    @Operation(
        summary = " Chercher par plage de capacité",
        description = "Recherche de salles dans une fourchette de capacité précise. Utile pour trouver des salles adaptées à la taille de votre groupe. **Accessible à tous les utilisateurs.** Exemple : minCap=20, maxCap=40 pour des groupes de TD."
    )
    public ResponseEntity<List<SalleDTO>> getSallesByCapacite(
            @RequestParam int minCap,
            @RequestParam int maxCap) {

        List<SalleDTO> salles = rechercheService.findSallesByCapaciteRange(minCap, maxCap);
        return ResponseEntity.ok(salles);
    }

    @GetMapping("/salles-pmr/{ville}")
    @Operation(
        summary = "Toutes les salles PMR d'une ville",
        description = "Retourne toutes les salles accessibles aux Personnes à Mobilité Réduite dans une ville donnée. Garantit une accessibilité complète. **Accessible à tous les utilisateurs.** Exemple : /api/recherche/salles-pmr/Montpellier"
    )
    public ResponseEntity<List<SalleDTO>> getSallesPMR(@PathVariable String ville) {
        List<SalleDTO> salles = rechercheService.findSallesPMRByVille(ville);
        return ResponseEntity.ok(salles);
    }

    // ==================== RECHERCHES POUR PROFESSEURS ====================

    @GetMapping("/salles-cours")
    @PreAuthorize("hasAnyRole('ADMIN', 'ETUDIANT', 'PROFESSEUR')")
    @Operation(
        summary = " Salles adaptées pour un cours",
        description = "Recherche de salles pour donner un cours selon le type (td/tp/amphi), la capacité minimale requise et le campus. **Accessible aux étudiants, professeurs et administrateurs.** Paramètres : type (td/tp/amphi), minCap (capacité min), campus (nom du campus). Exemple : /api/recherche/salles-cours?type=amphi&minCap=80&campus=Campus Triolet"
    )
    public ResponseEntity<List<SalleDTO>> getSallesPourCours(
            @RequestParam String type,
            @RequestParam int minCap,
            @RequestParam String campus) {

        List<SalleDTO> salles = rechercheService.findSallesPourCours(type, minCap, campus);
        return ResponseEntity.ok(salles);
    }

    @GetMapping("/salles-universite")
    @PreAuthorize("hasAnyRole('ADMIN', 'ETUDIANT', 'PROFESSEUR')")
    @Operation(
        summary = "Salles par université et type",
        description = "Filtre les salles par université (UM, UPVD) et type de salle (td/tp/amphi). Utile pour les professeurs qui enseignent dans plusieurs universités. **Accessible aux étudiants, professeurs et administrateurs.** Exemple : /api/recherche/salles-universite?universite=UM&type=td"
    )
    public ResponseEntity<List<SalleDTO>> getSallesByUniversite(
            @RequestParam String universite,
            @RequestParam String type) {

        List<SalleDTO> salles = rechercheService.findSallesByUniversiteAndType(universite, type);
        return ResponseEntity.ok(salles);
    }

    // ==================== RECHERCHES POUR ADMINISTRATEURS ====================

    @GetMapping("/top-salles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Top  des plus grandes salles",
        description = "Retourne le classement des N plus grandes salles par capacité. **Réservé aux administrateurs uniquement.** Utile pour identifier les amphithéâtres et grandes salles de cours. Paramètre : limit (défaut: 10). Exemple : /api/recherche/top-salles?limit=10"
    )
    public ResponseEntity<List<SalleDTO>> getTopSalles(
            @RequestParam(defaultValue = "10") int limit) {

        List<SalleDTO> salles = rechercheService.findTopSallesByCapacite(limit);
        return ResponseEntity.ok(salles);
    }

    @GetMapping("/stats-ville-type")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Statistiques par ville et type",
        description = "Analyse détaillée des salles par ville et type : nombre de salles et capacité totale pour chaque combinaison ville/type. **Réservé aux administrateurs uniquement.** Retourne : {ville, type, nombreSalles, capaciteTotale}. Utile pour la planification stratégique."
    )
    public ResponseEntity<List<Map<String, Object>>> getStatsByVilleType() {
        List<Map<String, Object>> stats = rechercheService.getStatistiquesByVilleAndType();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/stats-pmr-campus")
    @Operation(
        summary = " Nombre de salles PMR par campus",
        description = "Comptabilise le nombre de salles accessibles PMR pour chaque campus. **Accessible à tous les utilisateurs.** Retourne : {campus, nombreSallesPMR}. Utile pour évaluer l'accessibilité de chaque campus."
    )
    public ResponseEntity<List<Map<String, Object>>> getStatsPMRByCampus() {
        List<Map<String, Object>> stats = rechercheService.countSallesPMRByCampus();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/capacite-ville")
    @Operation(
        summary = " Capacité totale par ville",
        description = "Analyse de la répartition géographique : capacité totale d'accueil par ville. **Accessible à tous les utilisateurs.** Retourne : {ville, capaciteTotale}. Utile pour identifier les villes les mieux équipées."
    )
    public ResponseEntity<List<Map<String, Object>>> getCapaciteByVille() {
        List<Map<String, Object>> stats = rechercheService.getCapaciteTotaleByVille();
        return ResponseEntity.ok(stats);
    }

    // ==================== RECHERCHE MULTI-CRITÈRES ====================

    @GetMapping("/multi-criteres")
    @Operation(
        summary = " Recherche multicritères flexible",
        description = "Recherche avancée avec filtres combinables : ville, type de salle, plage de capacité, accessibilité PMR. **Accessible à tous les utilisateurs.** Tous les paramètres sont optionnels. Exemple : /api/recherche/multi-criteres?ville=Montpellier&type=td&minCap=30&pmr=true"
    )
    public ResponseEntity<List<SalleDTO>> searchMultiCriteria(
            @RequestParam(required = false) String ville,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Integer minCap,
            @RequestParam(required = false) Integer maxCap,
            @RequestParam(defaultValue = "false") boolean pmr) {

        List<SalleDTO> salles = rechercheService.searchSallesMultiCriteria(ville, type, minCap, maxCap, pmr);
        return ResponseEntity.ok(salles);
    }

    // ==================== STATISTIQUES CAMPUS ====================

    @GetMapping("/top-campus-batiments")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Campus avec le plus de bâtiments",
        description = "Classement des campus ayant le plus de bâtiments. **Réservé aux administrateurs uniquement.** Utile pour identifier les campus les plus développés en termes d'infrastructures. Paramètre : limit (défaut: 5). Retourne : {campus, nombreBatiments}."
    )
    public ResponseEntity<List<Map<String, Object>>> getTopCampusBatiments(
            @RequestParam(defaultValue = "5") int limit) {

        List<Map<String, Object>> stats = rechercheService.getCampusWithMostBatiments(limit);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/top-campus-salles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Campus avec le plus de salles",
        description = "Classement des campus ayant le plus de salles. **Réservé aux administrateurs uniquement.** Utile pour évaluer la capacité d'accueil de chaque campus. Paramètre : limit (défaut: 5). Retourne : {campus, nombreSalles, capaciteTotale}."
    )
    public ResponseEntity<List<Map<String, Object>>> getTopCampusSalles(
            @RequestParam(defaultValue = "5") int limit) {

        List<Map<String, Object>> stats = rechercheService.getCampusWithMostSalles(limit);
        return ResponseEntity.ok(stats);
    }

    /**
     * GET /api/recherche/stats-campus
     * Statistiques complètes par campus
     */
    @GetMapping("/stats-campus")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Statistiques complètes des campus",
        description = "Vue d'ensemble détaillée de tous les campus : nombre de bâtiments, nombre de salles, capacité totale, répartition par type. **Réservé aux administrateurs uniquement.** Retourne des statistiques exhaustives pour chaque campus."
    )
    public ResponseEntity<List<Map<String, Object>>> getStatsCampus() {
        List<Map<String, Object>> stats = rechercheService.getStatistiquesCompletesCampus();
        return ResponseEntity.ok(stats);
    }

    // ==================== STATISTIQUES BÂTIMENTS ====================

    @GetMapping("/top-batiments-salles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Bâtiments avec le plus de salles",
        description = "Classement des bâtiments ayant le plus de salles. **Réservé aux administrateurs uniquement.** Utile pour identifier les bâtiments les plus utilisés. Paramètre : limit (défaut: 10). Retourne : {batiment, campus, nombreSalles}."
    )
    public ResponseEntity<List<Map<String, Object>>> getTopBatimentsSalles(
            @RequestParam(defaultValue = "10") int limit) {

        List<Map<String, Object>> stats = rechercheService.getBatimentsWithMostSalles(limit);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/stats-batiments")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Statistiques complètes des bâtiments",
        description = "Analyse détaillée de tous les bâtiments : nombre de salles, capacité totale, année de construction, campus associé. **Réservé aux administrateurs uniquement.** Retourne des statistiques exhaustives pour chaque bâtiment."
    )
    public ResponseEntity<List<Map<String, Object>>> getStatsBatiments() {
        List<Map<String, Object>> stats = rechercheService.getStatistiquesCompletesBatiments();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/batiments-annee")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Bâtiments groupés par année",
        description = "Historique de la construction : nombre de bâtiments par année de construction. **Réservé aux administrateurs uniquement.** Utile pour analyser l'évolution des infrastructures. Retourne : {annee, nombreBatiments}."
    )
    public ResponseEntity<List<Map<String, Object>>> getBatimentsByAnnee() {
        List<Map<String, Object>> stats = rechercheService.countBatimentsByAnnee();
        return ResponseEntity.ok(stats);
    }

    // ==================== RECHERCHES SUPPLÉMENTAIRES CAMPUS ====================

    @GetMapping("/campus-universite/{acronyme}")
    @Operation(
        summary = "Campus d'une université",
        description = "Retourne tous les campus d'une université spécifique (UM, UPVD). **Accessible à tous les utilisateurs.** Utile pour filtrer les campus par université. Exemple : /api/recherche/campus-universite/UM"
    )
    public ResponseEntity<List<Ex.modele.Campus>> getCampusByUniversite(@PathVariable String acronyme) {
        List<Ex.modele.Campus> campus = rechercheService.getCampusByUniversite(acronyme);
        return ResponseEntity.ok(campus);
    }

    @GetMapping("/campus-capacite-min")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Campus avec capacité minimale",
        description = "Filtre les campus ayant une capacité totale d'accueil supérieure ou égale à un seuil. **Réservé aux administrateurs uniquement.** Utile pour identifier les campus les plus grands. Paramètre : min (capacité minimale). Exemple : /api/recherche/campus-capacite-min?min=100"
    )
    public ResponseEntity<List<Ex.modele.Campus>> getCampusWithMinCapacite(@RequestParam int min) {
        List<Ex.modele.Campus> campus = rechercheService.getCampusWithMinCapacite(min);
        return ResponseEntity.ok(campus);
    }

    @GetMapping("/campus-composante/{acronyme}")
    @Operation(
        summary = "Campus d'une composante",
        description = "Retourne tous les campus liés à une composante spécifique (FDS, IUT, etc.). **Accessible à tous les utilisateurs.** Utile pour voir où une composante est implantée. Exemple : /api/recherche/campus-composante/FDS"
    )
    public ResponseEntity<List<Ex.modele.Campus>> getCampusByComposante(@PathVariable String acronyme) {
        List<Ex.modele.Campus> campus = rechercheService.getCampusByComposante(acronyme);
        return ResponseEntity.ok(campus);
    }

    // ==================== RECHERCHES SUPPLÉMENTAIRES BÂTIMENTS ====================

    @GetMapping("/batiments-universite/{acronyme}")
    @Operation(
        summary = " Bâtiments d'une université",
        description = "Retourne tous les bâtiments d'une université spécifique (UM, UPVD). **Accessible à tous les utilisateurs.** Utile pour voir l'ensemble du parc immobilier d'une université. Exemple : /api/recherche/batiments-universite/UM"
    )
    public ResponseEntity<List<Ex.modele.Batiment>> getBatimentsByUniversite(@PathVariable String acronyme) {
        List<Ex.modele.Batiment> batiments = rechercheService.getBatimentsByUniversite(acronyme);
        return ResponseEntity.ok(batiments);
    }

    @GetMapping("/batiments-ville/{ville}")
    @Operation(
        summary = "Bâtiments d'une ville",
        description = "Filtre les bâtiments par localisation géographique. **Accessible à tous les utilisateurs.** Utile pour identifier les infrastructures dans une ville donnée. Exemple : /api/recherche/batiments-ville/Montpellier"
    )
    public ResponseEntity<List<Ex.modele.Batiment>> getBatimentsByVille(@PathVariable String ville) {
        List<Ex.modele.Batiment> batiments = rechercheService.getBatimentsByVille(ville);
        return ResponseEntity.ok(batiments);
    }

    @GetMapping("/batiments-recents")
    @Operation(
        summary = " Bâtiments récents",
        description = "Retourne les bâtiments construits depuis une année donnée. **Accessible à tous les utilisateurs.** Utile pour identifier les infrastructures modernes. Paramètre : annee (année de référence). Exemple : /api/recherche/batiments-recents?annee=2015 (retourne les bâtiments construits depuis 2015)"
    )
    public ResponseEntity<List<Ex.modele.Batiment>> getRecentBatiments(@RequestParam int annee) {
        List<Ex.modele.Batiment> batiments = rechercheService.getRecentBatiments(annee);
        return ResponseEntity.ok(batiments);
    }

    @GetMapping("/batiments-capacite-min")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = "Bâtiments avec capacité minimale",
        description = "Filtre les bâtiments ayant une capacité totale d'accueil supérieure ou égale à un seuil. **Réservé aux administrateurs uniquement.** Utile pour identifier les grands bâtiments. Paramètre : min (capacité minimale). Exemple : /api/recherche/batiments-capacite-min?min=200"
    )
    public ResponseEntity<List<Ex.modele.Batiment>> getBatimentsWithMinCapacite(@RequestParam int min) {
        List<Ex.modele.Batiment> batiments = rechercheService.getBatimentsWithMinCapacite(min);
        return ResponseEntity.ok(batiments);
    }

    // ==================== ANALYSE GLOBALE ====================

    @GetMapping("/analyse-globale")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
        summary = " Vue d'ensemble complète du système",
        description = "Tableau de bord global avec toutes les statistiques clés : nombre total d'universités, campus, bâtiments, salles, capacité totale d'accueil, répartition par type, accessibilité PMR globale. **Réservé aux administrateurs uniquement.** Retourne un objet JSON avec toutes les métriques principales du système. Idéal pour avoir une vision d'ensemble en un coup d'œil."
    )
    public ResponseEntity<Map<String, Object>> getAnalyseGlobale() {
        Map<String, Object> analyse = rechercheService.getAnalyseGlobale();
        return ResponseEntity.ok(analyse);
    }
}

