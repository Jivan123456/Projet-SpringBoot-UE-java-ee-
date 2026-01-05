package Ex.dto;

import java.time.LocalDateTime;

public class ReservationDTO {
    private Long id;
    private String salleNums;
    private String salleNom;
    private String batimentNom;
    private String campusNom;
    private String userEmail;
    private String userNom;
    private String userPrenom;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String motif;
    private String statut;
    private LocalDateTime dateCreation;

    public ReservationDTO() {}


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSalleNums() {
        return salleNums;
    }

    public void setSalleNums(String salleNums) {
        this.salleNums = salleNums;
    }

    public String getSalleNom() {
        return salleNom;
    }

    public void setSalleNom(String salleNom) {
        this.salleNom = salleNom;
    }

    public String getBatimentNom() {
        return batimentNom;
    }

    public void setBatimentNom(String batimentNom) {
        this.batimentNom = batimentNom;
    }

    public String getCampusNom() {
        return campusNom;
    }

    public void setCampusNom(String campusNom) {
        this.campusNom = campusNom;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getUserNom() {
        return userNom;
    }

    public void setUserNom(String userNom) {
        this.userNom = userNom;
    }

    public String getUserPrenom() {
        return userPrenom;
    }

    public void setUserPrenom(String userPrenom) {
        this.userPrenom = userPrenom;
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

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }
}

