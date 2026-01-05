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
    private String nums;

    @NotNull(message = "La capacité est obligatoire")
    @Min(value = 1, message = "La capacité doit être au moins 1")
    private Integer capacite;

    @NotBlank(message = "Le type de salle est obligatoire")
    private String types;

    private String acces;

    private String etage;

    @NotBlank(message = "Le bâtiment est obligatoire")
    private String batimentId;

    public SalleDTO() {
    }

    public SalleDTO(String nums, Integer capacite, String types, String acces, String etage, String batimentId) {
        this.nums = nums;
        this.capacite = capacite;
        this.types = types;
        this.acces = acces;
        this.etage = etage;
        this.batimentId = batimentId;
    }


    public String getNums() {
        return nums;
    }

    public void setNums(String nums) {
        this.nums = nums;
    }

    public Integer getCapacite() {
        return capacite;
    }

    public void setCapacite(Integer capacite) {
        this.capacite = capacite;
    }

    public String getTypes() {
        return types;
    }

    public void setTypes(String types) {
        this.types = types;
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
                "nums='" + nums + '\'' +
                ", capacite=" + capacite +
                ", types='" + types + '\'' +
                ", acces='" + acces + '\'' +
                ", etage='" + etage + '\'' +
                ", batimentId='" + batimentId + '\'' +
                '}';
    }
}

