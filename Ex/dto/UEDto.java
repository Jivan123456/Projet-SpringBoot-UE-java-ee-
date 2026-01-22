package Ex.dto;

/**
 * DTO pour créer ou mettre à jour une UE
 */
public class UEDto {

    private Long idUe;
    private String nom;
    private String description;
    private int nbHeures;
    private int credits;
    private String composanteAcronyme;


    public UEDto() {
    }

    public UEDto(Long idUe, String nom, String description, int nbHeures, int credits, String composanteAcronyme) {
        this.idUe = idUe;
        this.nom = nom;
        this.description = description;
        this.nbHeures = nbHeures;
        this.credits = credits;
        this.composanteAcronyme = composanteAcronyme;
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
}

