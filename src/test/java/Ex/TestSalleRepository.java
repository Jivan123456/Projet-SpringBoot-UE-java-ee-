package Ex;

import Ex.CL_Appli;
import Ex.domain.SalleRepository;
import Ex.modele.Salle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Test du repository Salle
 * Démontre l'utilisation des requêtes JPQL personnalisées
 *
 * UTILISATION :
 * 1. Automatique : Décommenter @Component et lancer CL_Appli
 * 2. Indépendant : Run main() de cette classe directement
 */
// @Component // Désactivé pour le TP2 - utilisez TestCampusCapacityService à la place
public class TestSalleRepository implements CommandLineRunner {

    /**
     * Point d'entrée pour lancer ce test indépendamment
     * Active automatiquement ce test et démarre l'application
     */
    public static void main(String[] args) {
        System.out.println("\n🚀 Lancement de TestSalleRepository...\n");
        SpringApplication.run(CL_Appli.class, args);
    }

    @Autowired
    private SalleRepository salleRepository;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("\n========== TEST SALLE REPOSITORY ==========\n");

        // 1. Toutes les salles
        System.out.println("1. Toutes les salles :");
        List<Salle> allSalles = salleRepository.findAllSalles();
        allSalles.forEach(System.out::println);

        // 2. Salles TD dans bâtiment 36
        System.out.println("\n2. Salles TD dans bâtiment 36 :");
        List<Salle> td36 = salleRepository.findTdSallesInBatiment36();
        td36.forEach(System.out::println);

        // 3. Salles par code bâtiment (ex: 42)
        String codeBatiment = "42";
        System.out.println("\n3. Salles dans bâtiment " + codeBatiment + " :");
        salleRepository.findSallesByBatimentCode(codeBatiment).forEach(System.out::println);

        // 4. Salles d'un campus (ex: LyonTech)
        String campus = "LyonTech";
        System.out.println("\n4. Salles dans campus " + campus + " :");
        salleRepository.findSallesByCampusName(campus).forEach(System.out::println);

        // 5. Nombre de salles par bâtiment
        System.out.println("\n5. Nombre de salles par bâtiment :");
        List<Object[]> countByBatiment = salleRepository.countSallesByBatiment();
        for (Object[] row : countByBatiment) {
            System.out.println("Bâtiment : " + row[0] + " → " + row[1] + " salles");
        }

        // 6. Nombre de salles par type
        System.out.println("\n6. Nombre de salles par type :");
        List<Object[]> countByType = salleRepository.countSallesByType();
        for (Object[] row : countByType) {
            System.out.println("Type : " + row[0] + " → " + row[1] + " salles");
        }

        System.out.println("\n========== FIN TEST SALLE REPOSITORY ==========\n");
    }
}

