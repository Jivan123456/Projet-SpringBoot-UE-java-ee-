package Ex.dto;

/**
 * DTO pour les statistiques d'un bâtiment
 */
public class BatimentStatisticsDTO {
    private String codeBatiment;
    private String nomCampus;
    private Long nombreSalles;
    private Long capaciteTotale;

    public BatimentStatisticsDTO() {}

    public BatimentStatisticsDTO(String codeBatiment, String nomCampus,
                                  Long nombreSalles, Long capaciteTotale) {
        this.codeBatiment = codeBatiment;
        this.nomCampus = nomCampus;
        this.nombreSalles = nombreSalles;
        this.capaciteTotale = capaciteTotale;
    }

    public String getCodeBatiment() {
        return codeBatiment;
    }

    public void setCodeBatiment(String codeBatiment) {
        this.codeBatiment = codeBatiment;
    }

    public String getNomCampus() {
        return nomCampus;
    }

    public void setNomCampus(String nomCampus) {
        this.nomCampus = nomCampus;
    }

    public Long getNombreSalles() {
        return nombreSalles;
    }

    public void setNombreSalles(Long nombreSalles) {
        this.nombreSalles = nombreSalles;
    }

    public Long getCapaciteTotale() {
        return capaciteTotale;
    }

    public void setCapaciteTotale(Long capaciteTotale) {
        this.capaciteTotale = capaciteTotale;
    }

    @Override
    public String toString() {
        return "BatimentStatisticsDTO{" +
                "codeBatiment='" + codeBatiment + '\'' +
                ", nomCampus='" + nomCampus + '\'' +
                ", nombreSalles=" + nombreSalles +
                ", capaciteTotale=" + capaciteTotale +
                '}';
    }
}

