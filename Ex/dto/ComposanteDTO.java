package Ex.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO pour Composante (CRUD)
 * Utilisé pour créer et modifier une composante
 */
public class ComposanteDTO {

    @NotBlank(message = "L'acronyme est obligatoire")
    private String acronyme;

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    private String responsable;

    private String universiteId;


    public ComposanteDTO() {
    }

    public ComposanteDTO(String acronyme, String nom, String responsable) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
    }

    public ComposanteDTO(String acronyme, String nom, String responsable, String universiteId) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
        this.universiteId = universiteId;
    }


    public String getAcronyme() {
        return acronyme;
    }

    public void setAcronyme(String acronyme) {
        this.acronyme = acronyme;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getResponsable() {
        return responsable;
    }

    public void setResponsable(String responsable) {
        this.responsable = responsable;
    }

    public String getUniversiteId() {
        return universiteId;
    }

    public void setUniversiteId(String universiteId) {
        this.universiteId = universiteId;
    }

    @Override
    public String toString() {
        return "ComposanteDTO{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", responsable='" + responsable + '\'' +
                '}';
    }
}

