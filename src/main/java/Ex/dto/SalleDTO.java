package Ex.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * DTO pour Salle (CRUD)
 * Utilisé pour créer et modifier une salle
 */
public class SalleDTO {

    @NotBlank(message = "Le numéro de salle est obligatoire")
    private String numS;

    @NotNull(message = "La capacité est obligatoire")
    @Min(value = 1, message = "La capacité doit être au moins 1")
    private Integer capacite;

    @NotBlank(message = "Le type de salle est obligatoire")
    private String typeS;

    private String acces;

    private String etage;

    @NotBlank(message = "Le bâtiment est obligatoire")
    private String batimentId;

    // Constructeurs
    public SalleDTO() {
    }

    public SalleDTO(String numS, Integer capacite, String typeS, String acces, String etage, String batimentId) {
        this.numS = numS;
        this.capacite = capacite;
        this.typeS = typeS;
        this.acces = acces;
        this.etage = etage;
        this.batimentId = batimentId;
    }

    // Getters & Setters
    public String getNumS() {
        return numS;
    }

    public void setNumS(String numS) {
        this.numS = numS;
    }

    public Integer getCapacite() {
        return capacite;
    }

    public void setCapacite(Integer capacite) {
        this.capacite = capacite;
    }

    public String getTypeS() {
        return typeS;
    }

    public void setTypeS(String typeS) {
        this.typeS = typeS;
    }

    public String getAcces() {
        return acces;
    }

    public void setAcces(String acces) {
        this.acces = acces;
    }

    public String getEtage() {
        return etage;
    }

    public void setEtage(String etage) {
        this.etage = etage;
    }

    public String getBatimentId() {
        return batimentId;
    }

    public void setBatimentId(String batimentId) {
        this.batimentId = batimentId;
    }

    @Override
    public String toString() {
        return "SalleDTO{" +
                "numS='" + numS + '\'' +
                ", capacite=" + capacite +
                ", typeS='" + typeS + '\'' +
                ", acces='" + acces + '\'' +
                ", etage='" + etage + '\'' +
                ", batimentId='" + batimentId + '\'' +
                '}';
    }
}

