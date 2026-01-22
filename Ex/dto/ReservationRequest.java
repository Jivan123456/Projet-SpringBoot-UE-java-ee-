package Ex.dto;

import java.time.LocalDateTime;

public class ReservationRequest {
    private String salleNums;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String motif;
    private Long ueId; // ID de l'UE pour les professeurs

    public ReservationRequest() {}


    public String getSalleNums() {
        return salleNums;
    }

    public void setSalleNums(String salleNums) {
        this.salleNums = salleNums;
    }

    public LocalDateTime getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDateTime dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDateTime getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDateTime dateFin) {
        this.dateFin = dateFin;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public Long getUeId() {
        return ueId;
    }

    public void setUeId(Long ueId) {
        this.ueId = ueId;
    }
}

