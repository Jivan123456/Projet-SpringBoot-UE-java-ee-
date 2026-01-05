package Ex.service;

import Ex.domain.*;
import Ex.dto.SalleDTO;
import Ex.modele.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Service dédié aux recherches avancées et statistiques intelligentes
 * Utilise les nouvelles requêtes des repositories pour fournir des analyses utiles
 */
@Service
@Transactional(readOnly = true)
public class RechercheAvanceeService {

    @Autowired
    private SalleRepository salleRepository;

    @Autowired
    private CampusRepository campusRepository;

    @Autowired
    private BatimentRepository batimentRepository;

    @Autowired
    private UniversiteRepository universiteRepository;

    @Autowired
    private ComposanteRepository composanteRepository;

    @Autowired
    private DtoMapper dtoMapper;

    // ==================== RECHERCHES POUR ÉTUDIANTS ====================

    /**
     * Trouver des salles pour réviser (petites, type TD/TP, optionnel PMR)
     */
    public List<SalleDTO> findSallesPourReviser(int minCap, int maxCap, boolean needPMR, String ville) {
        return salleRepository.findSallesPourReviser(minCap, maxCap, needPMR, ville)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Chercher par plage de capacité
     */
    public List<SalleDTO> findSallesByCapaciteRange(int minCap, int maxCap) {
        return salleRepository.findSallesByCapaciteRange(minCap, maxCap)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Toutes les salles PMR d'une ville
     */
    public List<SalleDTO> findSallesPMRByVille(String ville) {
        return salleRepository.findSallesPMRByVille(ville)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    // ==================== RECHERCHES POUR PROFESSEURS ====================

    /**
     * Salles adaptées pour un cours (type + capacité min)
     */
    public List<SalleDTO> findSallesPourCours(String typeS, int minCap, String nomCampus) {
        return salleRepository.findSallesPourCours(typeS, minCap, nomCampus)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Salles par université et type
     */
    public List<SalleDTO> findSallesByUniversiteAndType(String acronyme, String typeS) {
        return salleRepository.findSallesByUniversiteAndType(acronyme, typeS)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    // ==================== RECHERCHES POUR ADMINISTRATEURS ====================

    /**
     * Top N des plus grandes salles
     */
    public List<SalleDTO> findTopSallesByCapacite(int limit) {
        return salleRepository.findTopSallesByCapacite()
                .stream()
                .limit(limit)
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Statistiques par type de salle et ville
     * Retourne: ville, type, nombre de salles, capacité totale
     */
    public List<Map<String, Object>> getStatistiquesByVilleAndType() {
        List<Object[]> results = salleRepository.getStatistiquesByVilleAndType();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("ville", row[0]);
            stat.put("type", row[1]);
            stat.put("nombreSalles", row[2]);
            stat.put("capaciteTotale", row[3]);
            return stat;
        }).collect(Collectors.toList());
    }

    /**
     * Nombre de salles PMR par campus
     */
    public List<Map<String, Object>> countSallesPMRByCampus() {
        List<Object[]> results = salleRepository.countSallesPMRByCampus();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("campus", row[0]);
            stat.put("nombreSallesPMR", row[1]);
            return stat;
        }).collect(Collectors.toList());
    }

    /**
     * Répartition géographique (capacité totale par ville)
     */
    public List<Map<String, Object>> getCapaciteTotaleByVille() {
        List<Object[]> results = salleRepository.getCapaciteTotaleByVille();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("ville", row[0]);
            stat.put("nombreSalles", row[1]);
            stat.put("capaciteTotale", row[2]);
            return stat;
        }).collect(Collectors.toList());
    }

    // ==================== RECHERCHE MULTI-CRITÈRES ====================

    /**
     * Recherche multi-critères flexible
     * Paramètres optionnels: ville, type, minCap, maxCap, needPMR
     */
    public List<SalleDTO> searchSallesMultiCriteria(String ville, String typeS,
                                                      Integer minCap, Integer maxCap,
                                                      boolean needPMR) {
        return salleRepository.searchSallesMultiCriteria(ville, typeS, minCap, maxCap, needPMR)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    // ==================== STATISTIQUES CAMPUS ====================

    /**
     * Campus avec le plus de bâtiments
     */
    public List<Map<String, Object>> getCampusWithMostBatiments(int limit) {
        List<Object[]> results = campusRepository.findCampusWithMostBatiments();
        return results.stream()
                .limit(limit)
                .map(row -> {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("campus", row[0]);
                    stat.put("nombreBatiments", row[1]);
                    return stat;
                }).collect(Collectors.toList());
    }

    /**
     * Campus avec le plus de salles
     */
    public List<Map<String, Object>> getCampusWithMostSalles(int limit) {
        List<Object[]> results = campusRepository.findCampusWithMostSalles();
        return results.stream()
                .limit(limit)
                .map(row -> {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("campus", row[0]);
                    stat.put("nombreSalles", row[1]);
                    return stat;
                }).collect(Collectors.toList());
    }

    /**
     * Statistiques complètes par campus
     */
    public List<Map<String, Object>> getStatistiquesCompletesCampus() {
        List<Object[]> results = campusRepository.getStatistiquesCompletes();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("campus", row[0]);
            stat.put("ville", row[1]);
            stat.put("universite", row[2]);
            stat.put("nombreBatiments", row[3]);
            stat.put("nombreSalles", row[4]);
            stat.put("capaciteTotale", row[5]);
            return stat;
        }).collect(Collectors.toList());
    }

    // ==================== STATISTIQUES BÂTIMENTS ====================

    /**
     * Bâtiments avec le plus de salles
     */
    public List<Map<String, Object>> getBatimentsWithMostSalles(int limit) {
        List<Object[]> results = batimentRepository.findBatimentsWithMostSalles();
        return results.stream()
                .limit(limit)
                .map(row -> {
                    Map<String, Object> stat = new HashMap<>();
                    stat.put("batiment", row[0]);
                    stat.put("campus", row[1]);
                    stat.put("nombreSalles", row[2]);
                    return stat;
                }).collect(Collectors.toList());
    }

    /**
     * Statistiques complètes par bâtiment
     */
    public List<Map<String, Object>> getStatistiquesCompletesBatiments() {
        List<Object[]> results = batimentRepository.getStatistiquesCompletes();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("batiment", row[0]);
            stat.put("anneeConstruction", row[1]);
            stat.put("campus", row[2]);
            stat.put("ville", row[3]);
            stat.put("nombreSalles", row[4]);
            stat.put("capaciteTotale", row[5]);
            return stat;
        }).collect(Collectors.toList());
    }

    /**
     * Bâtiments par année de construction
     */
    public List<Map<String, Object>> countBatimentsByAnnee() {
        List<Object[]> results = batimentRepository.countBatimentsByAnnee();
        return results.stream().map(row -> {
            Map<String, Object> stat = new HashMap<>();
            stat.put("annee", row[0]);
            stat.put("nombreBatiments", row[1]);
            return stat;
        }).collect(Collectors.toList());
    }

    // ==================== RECHERCHES SUPPLÉMENTAIRES CAMPUS ====================

    /**
     * Campus d'une université
     */
    public List<Campus> getCampusByUniversite(String acronyme) {
        return campusRepository.findByUniversite(acronyme);
    }

    /**
     * Campus avec capacité minimale
     */
    public List<Campus> getCampusWithMinCapacite(int minCapacite) {
        return campusRepository.findCampusWithMinCapacite(minCapacite);
    }

    /**
     * Campus d'une composante
     */
    public List<Campus> getCampusByComposante(String acronyme) {
        return campusRepository.findByComposante(acronyme);
    }

    // ==================== RECHERCHES SUPPLÉMENTAIRES BÂTIMENTS ====================

    /**
     * Bâtiments d'une université
     */
    public List<Batiment> getBatimentsByUniversite(String acronyme) {
        return batimentRepository.findByUniversite(acronyme);
    }

    /**
     * Bâtiments d'une ville
     */
    public List<Batiment> getBatimentsByVille(String ville) {
        return batimentRepository.findByVille(ville);
    }

    /**
     * Bâtiments récents (année >= X)
     */
    public List<Batiment> getRecentBatiments(int anneeMin) {
        return batimentRepository.findRecentBatiments(anneeMin);
    }

    /**
     * Bâtiments avec capacité minimale
     */
    public List<Batiment> getBatimentsWithMinCapacite(int minCapacite) {
        return batimentRepository.findBatimentsWithMinCapacite(minCapacite);
    }

    // ==================== ANALYSE GLOBALE ====================

    /**
     * Analyse globale du système (toutes universités)
     */
    public Map<String, Object> getAnalyseGlobale() {
        Map<String, Object> analyse = new HashMap<>();

        // Totaux généraux
        analyse.put("nombreTotalUniversites", universiteRepository.count());
        analyse.put("nombreTotalCampus", campusRepository.count());
        analyse.put("nombreTotalBatiments", batimentRepository.count());
        analyse.put("nombreTotalSalles", salleRepository.count());

        // Capacité totale
        Long capaciteTotale = salleRepository.findAll().stream()
                .mapToLong(Salle::getCapacite)
                .sum();
        analyse.put("capaciteTotale", capaciteTotale);

        // Salles PMR
        long sallesPMR = salleRepository.findAll().stream()
                .filter(s -> "oui".equalsIgnoreCase(s.getAcces()))
                .count();
        analyse.put("nombreSallesPMR", sallesPMR);
        analyse.put("pourcentagePMR", String.format("%.1f%%", (sallesPMR * 100.0 / salleRepository.count())));

        // Répartition par type
        Map<String, Long> repartitionTypes = salleRepository.findAll().stream()
                .collect(Collectors.groupingBy(Salle::getTypes, Collectors.counting()));
        analyse.put("repartitionParType", repartitionTypes);

        return analyse;
    }
}

