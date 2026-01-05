package Ex.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO pour Campus (CRUD)
 * Utilisé pour créer et modifier un campus
 */
public class CampusDTO {

    @NotBlank(message = "Le nom du campus est obligatoire")
    private String nomC;

    @NotBlank(message = "La ville est obligatoire")
    private String ville;

    // ID de l'université (optionnel)
    private String universiteId;


    public CampusDTO() {
    }

    public CampusDTO(String nomC, String ville, String universiteId) {
        this.nomC = nomC;
        this.ville = ville;
        this.universiteId = universiteId;
    }


    public String getNomC() {
        return nomC;
    }

    public void setNomC(String nomC) {
        this.nomC = nomC;
    }

    public String getVille() {
        return ville;
    }

    public void setVille(String ville) {
        this.ville = ville;
    }

    public String getUniversiteId() {
        return universiteId;
    }

    public void setUniversiteId(String universiteId) {
        this.universiteId = universiteId;
    }

    @Override
    public String toString() {
        return "CampusDTO{" +
                "nomC='" + nomC + '\'' +
                ", ville='" + ville + '\'' +
                ", universiteId='" + universiteId + '\'' +
                '}';
    }
}

