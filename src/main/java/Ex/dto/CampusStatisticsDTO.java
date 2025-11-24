package Ex.dto;

/**
 * DTO pour les statistiques d'un campus
 */
public class CampusStatisticsDTO {
    private String nomCampus;
    private String ville;
    private Long nombreBatiments;
    private Long nombreSalles;
    private Long capaciteTotale;

    public CampusStatisticsDTO() {}

    public CampusStatisticsDTO(String nomCampus, String ville, Long nombreBatiments,
                                Long nombreSalles, Long capaciteTotale) {
        this.nomCampus = nomCampus;
        this.ville = ville;
        this.nombreBatiments = nombreBatiments;
        this.nombreSalles = nombreSalles;
        this.capaciteTotale = capaciteTotale;
    }

    // Getters et Setters
    public String getNomCampus() {
        return nomCampus;
    }

    public void setNomCampus(String nomCampus) {
        this.nomCampus = nomCampus;
    }

    public String getVille() {
        return ville;
    }

    public void setVille(String ville) {
        this.ville = ville;
    }

    public Long getNombreBatiments() {
        return nombreBatiments;
    }

    public void setNombreBatiments(Long nombreBatiments) {
        this.nombreBatiments = nombreBatiments;
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
        return "CampusStatisticsDTO{" +
                "nomCampus='" + nomCampus + '\'' +
                ", ville='" + ville + '\'' +
                ", nombreBatiments=" + nombreBatiments +
                ", nombreSalles=" + nombreSalles +
                ", capaciteTotale=" + capaciteTotale +
                '}';
    }
}

