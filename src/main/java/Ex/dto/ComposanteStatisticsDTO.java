package Ex.dto;

/**
 * DTO pour les statistiques d'une composante
 */
public class ComposanteStatisticsDTO {
    private String acronyme;
    private String nom;
    private String responsable;
    private Long nombreCampus;
    private Long nombreBatiments;
    private Long nombreSalles;
    private Long capaciteTotale;
    private Long sallesAccessiblesPMR;

    public ComposanteStatisticsDTO() {}

    public ComposanteStatisticsDTO(String acronyme, String nom, String responsable,
                                    Long nombreCampus, Long nombreBatiments,
                                    Long nombreSalles, Long capaciteTotale,
                                    Long sallesAccessiblesPMR) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
        this.nombreCampus = nombreCampus;
        this.nombreBatiments = nombreBatiments;
        this.nombreSalles = nombreSalles;
        this.capaciteTotale = capaciteTotale;
        this.sallesAccessiblesPMR = sallesAccessiblesPMR;
    }

    // Getters et Setters
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

    public Long getNombreCampus() {
        return nombreCampus;
    }

    public void setNombreCampus(Long nombreCampus) {
        this.nombreCampus = nombreCampus;
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

    public Long getSallesAccessiblesPMR() {
        return sallesAccessiblesPMR;
    }

    public void setSallesAccessiblesPMR(Long sallesAccessiblesPMR) {
        this.sallesAccessiblesPMR = sallesAccessiblesPMR;
    }

    @Override
    public String toString() {
        return "ComposanteStatisticsDTO{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", responsable='" + responsable + '\'' +
                ", nombreCampus=" + nombreCampus +
                ", nombreBatiments=" + nombreBatiments +
                ", nombreSalles=" + nombreSalles +
                ", capaciteTotale=" + capaciteTotale +
                ", sallesAccessiblesPMR=" + sallesAccessiblesPMR +
                '}';
    }
}

