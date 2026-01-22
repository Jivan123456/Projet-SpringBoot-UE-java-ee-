package Ex.dto;

/**
 * DTO pour les statistiques d'une université
 */
public class UniversiteStatisticsDTO {

    private String acronyme;
    private String nom;
    private int creation;
    private String presidence;
    private Long nombreCampus;
    private Long nombreComposantes;
    private Long nombreBatiments;
    private Long nombreSalles;
    private Long capaciteTotale;
    private Long sallesAccessibles;


    public UniversiteStatisticsDTO(String acronyme, String nom, int creation, String presidence,
                                   Long nombreCampus, Long nombreComposantes, Long nombreBatiments,
                                   Long nombreSalles, Long capaciteTotale, Long sallesAccessibles) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.creation = creation;
        this.presidence = presidence;
        this.nombreCampus = nombreCampus;
        this.nombreComposantes = nombreComposantes;
        this.nombreBatiments = nombreBatiments;
        this.nombreSalles = nombreSalles;
        this.capaciteTotale = capaciteTotale;
        this.sallesAccessibles = sallesAccessibles;
    }


    public String getAcronyme() { return acronyme; }
    public void setAcronyme(String acronyme) { this.acronyme = acronyme; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public int getCreation() { return creation; }
    public void setCreation(int creation) { this.creation = creation; }

    public String getPresidence() { return presidence; }
    public void setPresidence(String presidence) { this.presidence = presidence; }

    public Long getNombreCampus() { return nombreCampus; }
    public void setNombreCampus(Long nombreCampus) { this.nombreCampus = nombreCampus; }

    public Long getNombreComposantes() { return nombreComposantes; }
    public void setNombreComposantes(Long nombreComposantes) { this.nombreComposantes = nombreComposantes; }

    public Long getNombreBatiments() { return nombreBatiments; }
    public void setNombreBatiments(Long nombreBatiments) { this.nombreBatiments = nombreBatiments; }

    public Long getNombreSalles() { return nombreSalles; }
    public void setNombreSalles(Long nombreSalles) { this.nombreSalles = nombreSalles; }

    public Long getCapaciteTotale() { return capaciteTotale; }
    public void setCapaciteTotale(Long capaciteTotale) { this.capaciteTotale = capaciteTotale; }

    public Long getSallesAccessibles() { return sallesAccessibles; }
    public void setSallesAccessibles(Long sallesAccessibles) { this.sallesAccessibles = sallesAccessibles; }

    @Override
    public String toString() {
        return "UniversiteStatisticsDTO{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", creation=" + creation +
                ", presidence='" + presidence + '\'' +
                ", nombreCampus=" + nombreCampus +
                ", nombreComposantes=" + nombreComposantes +
                ", nombreBatiments=" + nombreBatiments +
                ", nombreSalles=" + nombreSalles +
                ", capaciteTotale=" + capaciteTotale +
                ", sallesAccessibles=" + sallesAccessibles +
                '}';
    }
}

