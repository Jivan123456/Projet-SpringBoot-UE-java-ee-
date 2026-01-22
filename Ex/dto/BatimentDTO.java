package Ex.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * DTO pour Batiment (CRUD)
 * Utilisé pour créer et modifier un bâtiment
 */
public class BatimentDTO {

    @NotBlank(message = "Le code du bâtiment est obligatoire")
    private String codeB;

    @NotNull(message = "L'année de construction est obligatoire")
    private Integer anneeC;

    @NotBlank(message = "Le campus est obligatoire")
    private String campusId;


    public BatimentDTO() {
    }

    public BatimentDTO(String codeB, Integer anneeC, String campusId) {
        this.codeB = codeB;
        this.anneeC = anneeC;
        this.campusId = campusId;
    }


    public String getCodeB() {
        return codeB;
    }

    public void setCodeB(String codeB) {
        this.codeB = codeB;
    }

    public Integer getAnneeC() {
        return anneeC;
    }

    public void setAnneeC(Integer anneeC) {
        this.anneeC = anneeC;
    }

    public String getCampusId() {
        return campusId;
    }

    public void setCampusId(String campusId) {
        this.campusId = campusId;
    }

    @Override
    public String toString() {
        return "BatimentDTO{" +
                "codeB='" + codeB + '\'' +
                ", anneeC=" + anneeC +
                ", campusId='" + campusId + '\'' +
                '}';
    }
}

