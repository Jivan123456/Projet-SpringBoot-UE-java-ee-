package Ex.dto;

import Ex.modele.UE;
import Ex.modele.User;
import java.util.List;
import java.util.stream.Collectors;

/**
 * DTO pour retourner une UE avec la liste des professeurs
 */
public class UEWithProfesseursDTO {

    private Long idUe;
    private String nom;
    private String description;
    private int nbHeures;
    private int credits;
    private String composanteAcronyme;
    private List<ProfesseurSimpleDTO> professeurs;


    public static class ProfesseurSimpleDTO {
        private Long id;
        private String nom;
        private String prenom;
        private String email;

        public ProfesseurSimpleDTO(User user) {
            this.id = user.getId();
            this.nom = user.getNom();
            this.prenom = user.getPrenom();
            this.email = user.getEmail();
        }

        // Getters
        public Long getId() { return id; }
        public String getNom() { return nom; }
        public String getPrenom() { return prenom; }
        public String getEmail() { return email; }
    }

    // Constructeur depuis UE
    public UEWithProfesseursDTO(UE ue) {
        this.idUe = ue.getIdUe();
        this.nom = ue.getNom();
        this.description = ue.getDescription();
        this.nbHeures = ue.getNbHeures();
        this.credits = ue.getCredits();
        this.composanteAcronyme = ue.getComposante() != null ? ue.getComposante().getAcronyme() : null;
        this.professeurs = ue.getProfesseurs().stream()
                .map(ProfesseurSimpleDTO::new)
                .collect(Collectors.toList());
    }


    public Long getIdUe() {
        return idUe;
    }

    public void setIdUe(Long idUe) {
        this.idUe = idUe;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getNbHeures() {
        return nbHeures;
    }

    public void setNbHeures(int nbHeures) {
        this.nbHeures = nbHeures;
    }

    public int getCredits() {
        return credits;
    }

    public void setCredits(int credits) {
        this.credits = credits;
    }

    public String getComposanteAcronyme() {
        return composanteAcronyme;
    }

    public void setComposanteAcronyme(String composanteAcronyme) {
        this.composanteAcronyme = composanteAcronyme;
    }

    public List<ProfesseurSimpleDTO> getProfesseurs() {
        return professeurs;
    }

    public void setProfesseurs(List<ProfesseurSimpleDTO> professeurs) {
        this.professeurs = professeurs;
    }
}
