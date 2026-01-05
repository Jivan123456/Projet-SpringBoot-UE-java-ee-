package Ex;

import Ex.CL_Appli;
import Ex.domain.*;
import Ex.modele.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Test de création de toutes les entités du modèle
 * Vérifie que les relations JPA fonctionnent correctement
 *
 * UTILISATION :
 * 1. Automatique : Décommenter @Component et lancer CL_Appli
 * 2. Indépendant : Run main() de cette classe directement
 */
// @Component // Désactivé par défaut - décommenter pour activer
public class TestCreation implements CommandLineRunner {

    /**
     * Point d'entrée pour lancer ce test indépendamment
     * Active automatiquement ce test et démarre l'application
     */
    public static void main(String[] args) {
        System.out.println("\n🚀 Lancement de TestCreation...\n");
        System.setProperty("spring.profiles.active", "test-creation");
        SpringApplication.run(CL_Appli.class, args);
    }

    @Autowired
    private UniversiteRepository universiteRepository;

    @Autowired
    private ComposanteRepository composanteRepository;

    @Autowired
    private CampusRepository campusRepository;

    @Autowired
    private BatimentRepository batimentRepository;

    @Autowired
    private SalleRepository salleRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        System.out.println("\n========== TEST DE CRÉATION DES ENTITÉS ==========\n");

        // 1. Test création Université
        testCreationUniversite();

        // 2. Test création Composante
        testCreationComposante();

        // 3. Test création Campus
        testCreationCampus();

        // 4. Test création Bâtiment
        testCreationBatiment();

        // 5. Test création Salle
        testCreationSalle();

        System.out.println("\n========== FIN DES TESTS DE CRÉATION ==========\n");
    }

    private void testCreationUniversite() {
        System.out.println("--- Test Création Université ---");

        Universite univ = new Universite("TEST_UNIV", "Université de Test", 2025, "Dr. Test");
        universiteRepository.save(univ);

        System.out.println("✓ Université créée: " + univ.getAcronyme() + " - " + univ.getNom());
        System.out.println("  Année création: " + univ.getCreation());
        System.out.println("  Président: " + univ.getPresidence());
        System.out.println();
    }

    private void testCreationComposante() {
        System.out.println("--- Test Création Composante ---");

        Composante composante = new Composante("TEST_COMP", "Composante de Test", "Responsable Test");
        composanteRepository.save(composante);

        System.out.println("✓ Composante créée: " + composante.getAcronyme() + " - " + composante.getNom());
        System.out.println("  Responsable: " + composante.getResponsable());
        System.out.println();
    }

    private void testCreationCampus() {
        System.out.println("--- Test Création Campus ---");

        // Récupérer l'université créée précédemment
        Universite univ = universiteRepository.findById("TEST_UNIV").orElse(null);

        if (univ != null) {
            Campus campus = new Campus("Campus Test", "Ville Test", univ);
            campusRepository.save(campus);

            System.out.println("✓ Campus créé: " + campus.getNomC() + " (" + campus.getVille() + ")");
            System.out.println("  Université: " + campus.getUniversite().getAcronyme());

            // Associer une composante au campus
            Composante composante = composanteRepository.findById("TEST_COMP").orElse(null);
            if (composante != null) {
                campus.addComposante(composante);
                campusRepository.save(campus);
                System.out.println("  Composante associée: " + composante.getAcronyme());
            }
        } else {
            System.out.println("✗ Université TEST_UNIV non trouvée");
        }
        System.out.println();
    }

    private void testCreationBatiment() {
        System.out.println("--- Test Création Bâtiment ---");

        // Récupérer le campus créé précédemment
        Campus campus = campusRepository.findById("Campus Test").orElse(null);

        if (campus != null) {
            Batiment batiment = new Batiment("BAT_TEST", 2025, campus);
            batimentRepository.save(batiment);

            System.out.println("✓ Bâtiment créé: " + batiment.getCodeB());
            System.out.println("  Année construction: " + batiment.getAnneeC());
            System.out.println("  Campus: " + batiment.getCampus().getNomC());
        } else {
            System.out.println("✗ Campus 'Campus Test' non trouvé");
        }
        System.out.println();
    }

    private void testCreationSalle() {
        System.out.println("--- Test Création Salle ---");

        // Récupérer le bâtiment créé précédemment
        Batiment batiment = batimentRepository.findById("BAT_TEST").orElse(null);

        if (batiment != null) {
            // Création d'une salle TD
            Salle salleTD = new Salle("TEST_TD01", 40, "td", "oui", "1", batiment);
            salleRepository.save(salleTD);

            System.out.println("✓ Salle TD créée: " + salleTD.getNums());
            System.out.println("  Capacité: " + salleTD.getCapacite() + " places");
            System.out.println("  Type: " + salleTD.getTypes());
            System.out.println("  PMR: " + salleTD.getAcces());
            System.out.println("  Étage: " + salleTD.getEtage());
            System.out.println("  Bâtiment: " + salleTD.getBatiment().getCodeB());

            // Création d'une salle TP
            Salle salleTP = new Salle("TEST_TP01", 30, "tp", "non", "2", batiment);
            salleRepository.save(salleTP);

            System.out.println("✓ Salle TP créée: " + salleTP.getNums());
            System.out.println("  Capacité: " + salleTP.getCapacite() + " places");
            System.out.println("  Type: " + salleTP.getTypes());

            // Création d'un amphi
            Salle amphi = new Salle("TEST_AMPHI01", 200, "amphi", "oui", "0", batiment);
            salleRepository.save(amphi);

            System.out.println("✓ Amphi créé: " + amphi.getNums());
            System.out.println("  Capacité: " + amphi.getCapacite() + " places");
            System.out.println("  Type: " + amphi.getTypes());
        } else {
            System.out.println("✗ Bâtiment 'BAT_TEST' non trouvé");
        }
        System.out.println();
    }
}

