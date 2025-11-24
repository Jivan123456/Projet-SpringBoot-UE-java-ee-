package Ex.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * DTO pour Universite (CRUD)
 * Utilisé pour créer et modifier une université
 */
public class UniversiteDTO {

    @NotBlank(message = "L'acronyme est obligatoire")
    private String acronyme;

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    @NotNull(message = "L'année de création est obligatoire")
    private Integer creation;

    private String presidence;

    // Constructeurs
    public UniversiteDTO() {
    }

    public UniversiteDTO(String acronyme, String nom, Integer creation, String presidence) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.creation = creation;
        this.presidence = presidence;
    }

    // Getters & Setters
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

    public Integer getCreation() {
        return creation;
    }

    public void setCreation(Integer creation) {
        this.creation = creation;
    }

    public String getPresidence() {
        return presidence;
    }

    public void setPresidence(String presidence) {
        this.presidence = presidence;
    }

    @Override
    public String toString() {
        return "UniversiteDTO{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", creation=" + creation +
                ", presidence='" + presidence + '\'' +
                '}';
    }
}

