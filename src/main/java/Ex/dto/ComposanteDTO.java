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

    // Constructeurs
    public ComposanteDTO() {
    }

    public ComposanteDTO(String acronyme, String nom, String responsable) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
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

    public String getResponsable() {
        return responsable;
    }

    public void setResponsable(String responsable) {
        this.responsable = responsable;
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

