        package Ex;

        import java.util.ArrayList;
        import java.util.List;

        import org.springframework.beans.factory.annotation.Autowired;
        import org.springframework.boot.CommandLineRunner;
        import org.springframework.boot.SpringApplication;
        import org.springframework.boot.autoconfigure.SpringBootApplication;
        import org.springframework.core.annotation.Order;

        import jakarta.transaction.Transactional;
        import Ex.domain.BatimentRepository;
        import Ex.domain.CampusRepository;
        import Ex.modele.*;
        import Ex.service.*;
        import Ex.dto.*;

        @Transactional
        @SpringBootApplication
        @Order(1)
        public class CL_Appli implements CommandLineRunner {
                 @Autowired
                 private BatimentRepository br;
                 @Autowired
                 private CampusRepository cr;

                 // Services CRUD
                 @Autowired
                 private UniversiteService universiteService;
                 @Autowired
                 private ComposanteService composanteService;
                 @Autowired
                 private CampusService campusService;
                 @Autowired
                 private BatimentService batimentService;
                 @Autowired
                 private SalleService salleService;





                public static void main(String[] args) {
                    SpringApplication.run(CL_Appli.class, args);

                }

            public void run(String... args) {
                tsLesBatiments();
                campusParVille("Montpellier");
                List<String> codes = new ArrayList<>();
                codes.add("triolet_b36");
                codes.add("triolet_b16");
                certainsBatiments(codes);

                // TP2: Création du campus FDE Nimes avec les services CRUD
                creerCampusFDENimes();

                System.out.println("\n========== EXERCICE 3: INITIALISATION DES UNIVERSITÉS ==========");

                // Initialisation de l'Université de Montpellier (UM)
                System.out.println("\n--- Initialisation de l'Université de Montpellier (UM) ---");
                initializeUM();

                // Initialisation de l'Université Paul Valéry (UPVD) avec l'Elearning Center
                System.out.println("\n--- Initialisation de l'Université Paul Valéry (UPVD) ---");
                initializeUPVD();

                System.out.println("\n========== INITIALISATION TERMINÉE ==========\n");
               }

            // Création du campus FDE Nimes avec DTOs
            private void creerCampusFDENimes() {
                // Vérifier si le campus existe déjà
                if (campusService.exists("FDE Nimes")) {
                    System.out.println("✓ Campus 'FDE Nimes' existe déjà");
                    return;
                }


                CampusDTO campusDTO = new CampusDTO();
                campusDTO.setNomC("FDE Nimes");
                campusDTO.setVille("Nimes");
                campusService.create(campusDTO);


                BatimentDTO batimentDTO = new BatimentDTO();
                batimentDTO.setCodeB("bt1 nimes");
                batimentDTO.setAnneeC(2024);
                batimentDTO.setCampusId("FDE Nimes");
                batimentService.create(batimentDTO);


                SalleDTO s1 = new SalleDTO();
                s1.setNumS("N101");
                s1.setCapacite(30);
                s1.setTypeS("td");
                s1.setAcces("oui");
                s1.setEtage("1");
                s1.setBatimentId("bt1 nimes");
                salleService.create(s1);

                SalleDTO s2 = new SalleDTO();
                s2.setNumS("N102");
                s2.setCapacite(40);
                s2.setTypeS("tp");
                s2.setAcces("non");
                s2.setEtage("2");
                s2.setBatimentId("bt1 nimes");
                salleService.create(s2);

                System.out.println("✓ Campus 'FDE Nimes', bâtiment 'bt1 nimes' et 2 salles créés");
            }


            private void initializeUM() {

                if (!universiteService.exists("UM")) {
                    UniversiteDTO umDTO = new UniversiteDTO();
                    umDTO.setAcronyme("UM");
                    umDTO.setNom("Université de Montpellier");
                    umDTO.setCreation(1289);
                    umDTO.setPresidence("Président UM");
                    universiteService.create(umDTO);
                    System.out.println("✓ Université UM créée");
                }

                // Créer la composante FDS avec DTO
                if (!composanteService.exists("FDS")) {
                    ComposanteDTO fdsDTO = new ComposanteDTO();
                    fdsDTO.setAcronyme("FDS");
                    fdsDTO.setNom("Faculté des Sciences");
                    fdsDTO.setResponsable("Doyen FDS");
                    composanteService.create(fdsDTO);
                    System.out.println("✓ Composante FDS créée");
                }

                // Créer le campus Triolet avec DTO
                if (!campusService.exists("Campus Triolet")) {
                    CampusDTO trioletDTO = new CampusDTO();
                    trioletDTO.setNomC("Campus Triolet");
                    trioletDTO.setVille("Montpellier");
                    trioletDTO.setUniversiteId("UM");
                    campusService.create(trioletDTO);
                    System.out.println("✓ Campus Triolet créé");

                    // Note: L'association composante-campus se fait via une table de liaison
                    // Pour l'instant, on ne gère pas cette relation dans les DTOs simples
                    System.out.println("✓ Composante FDS associée au Campus Triolet");
                }

                // Créer le bâtiment Bat9 avec DTO
                if (!batimentService.exists("Bat9")) {
                    BatimentDTO bat9DTO = new BatimentDTO();
                    bat9DTO.setCodeB("Bat9");
                    bat9DTO.setAnneeC(1970);
                    bat9DTO.setCampusId("Campus Triolet");
                    batimentService.create(bat9DTO);
                    System.out.println("✓ Bâtiment Bat9 créé");

                    // Créer des salles avec DTO
                    SalleDTO t101 = new SalleDTO();
                    t101.setNumS("T101");
                    t101.setCapacite(40);
                    t101.setTypeS("tp");
                    t101.setAcces("non");
                    t101.setEtage("1");
                    t101.setBatimentId("Bat9");
                    salleService.create(t101);

                    SalleDTO t102 = new SalleDTO();
                    t102.setNumS("T102");
                    t102.setCapacite(30);
                    t102.setTypeS("td");
                    t102.setAcces("oui");
                    t102.setEtage("1");
                    t102.setBatimentId("Bat9");
                    salleService.create(t102);

                    SalleDTO a103 = new SalleDTO();
                    a103.setNumS("A103");
                    a103.setCapacite(50);
                    a103.setTypeS("amphi");
                    a103.setAcces("oui");
                    a103.setEtage("0");
                    a103.setBatimentId("Bat9");
                    salleService.create(a103);

                    System.out.println("✓ 3 salles créées pour le bâtiment Bat9");
                }
            }

            // Initialisation Université Paul Valéry avec DTOs
            private void initializeUPVD() {
                // Créer l'université UPVD avec DTO
                if (!universiteService.exists("UPVD")) {
                    UniversiteDTO upvdDTO = new UniversiteDTO();
                    upvdDTO.setAcronyme("UPVD");
                    upvdDTO.setNom("Université Paul Valéry Montpellier 3");
                    upvdDTO.setCreation(1970);
                    upvdDTO.setPresidence("Président UPVD");
                    universiteService.create(upvdDTO);
                    System.out.println("✓ Université UPVD créée");
                }

                // Créer le campus Elearning Center avec DTO
                if (!campusService.exists("Elearning Center")) {
                    CampusDTO elearningDTO = new CampusDTO();
                    elearningDTO.setNomC("Elearning Center");
                    elearningDTO.setVille("Montpellier");
                    elearningDTO.setUniversiteId("UPVD");
                    campusService.create(elearningDTO);
                    System.out.println("✓ Campus Elearning Center créé");
                }

                // Créer le bâtiment E-Learning-1 avec DTO
                if (!batimentService.exists("E-Learning-1")) {
                    BatimentDTO elearningBatDTO = new BatimentDTO();
                    elearningBatDTO.setCodeB("E-Learning-1");
                    elearningBatDTO.setAnneeC(2015);
                    elearningBatDTO.setCampusId("Elearning Center");
                    batimentService.create(elearningBatDTO);
                    System.out.println("✓ Bâtiment E-Learning-1 créé");

                    // Créer des salles numériques avec DTO
                    SalleDTO e101 = new SalleDTO();
                    e101.setNumS("E101");
                    e101.setCapacite(25);
                    e101.setTypeS("numerique");
                    e101.setAcces("oui");
                    e101.setEtage("1");
                    e101.setBatimentId("E-Learning-1");
                    salleService.create(e101);

                    SalleDTO e102 = new SalleDTO();
                    e102.setNumS("E102");
                    e102.setCapacite(25);
                    e102.setTypeS("numerique");
                    e102.setAcces("oui");
                    e102.setEtage("1");
                    e102.setBatimentId("E-Learning-1");
                    salleService.create(e102);

                    SalleDTO e201 = new SalleDTO();
                    e201.setNumS("E201");
                    e201.setCapacite(30);
                    e201.setTypeS("numerique");
                    e201.setAcces("oui");
                    e201.setEtage("2");
                    e201.setBatimentId("E-Learning-1");
                    salleService.create(e201);

                    SalleDTO e202 = new SalleDTO();
                    e202.setNumS("E202");
                    e202.setCapacite(30);
                    e202.setTypeS("numerique");
                    e202.setAcces("oui");
                    e202.setEtage("2");
                    e202.setBatimentId("E-Learning-1");
                    salleService.create(e202);

                    System.out.println("✓ 4 salles créées pour le bâtiment E-Learning-1");
                }
            }



            public void tsLesBatiments()
            {  Iterable<Batiment> e = br.findAll();
              System.out.println("La liste des batiments");
               for (Batiment b : e) {
                  System.out.println(b.getCodeB()+"\t "+b.getAnneeC()+"\t "+b.getCampus().getNomC());
               }
            }

            public void campusParVille(String ville)
            {  Iterable<Campus> e = cr.findByVille(ville);
              System.out.println("La liste des campus de "+ville);
               for (Campus c : e) {
                  System.out.println(c.toString());
               }
            }

            public void certainsBatiments(List<String> codes)
            {  Iterable<Batiment> e = br.findByIds(codes);
              System.out.println("La liste de certains batiments");
               for (Batiment b : e) {
                  System.out.println(b.getCodeB()+"\t "+b.getAnneeC()+"\t "+b.getCampus().getNomC());
               }
            }














        }
