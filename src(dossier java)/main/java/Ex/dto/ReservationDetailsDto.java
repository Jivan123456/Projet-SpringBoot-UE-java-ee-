package Ex.dto;

import Ex.modele.Reservation;
import java.time.LocalDateTime;

/**
 * DTO enrichi pour les détails d'une réservation incluant l'UE
 */
public class ReservationDetailsDto {

    private Long id;
    private String salleNums;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String motif;
    private String statut;
    private LocalDateTime dateCreation;

    // Informations du professeur
    private Long professeurId;
    private String professeurNom;
    private String professeurPrenom;
    private String professeurEmail;

    // Informations de l'UE
    private Long ueId;
    private String ueNom;
    private String ueDescription;
    private int ueCredits;
    private int ueNbHeures;
    private String ueComposante;


    public ReservationDetailsDto() {
    }

    public ReservationDetailsDto(Reservation reservation) {
        this.id = reservation.getId();
        this.salleNums = reservation.getSalle().getNums();
        this.dateDebut = reservation.getDateDebut();
        this.dateFin = reservation.getDateFin();
        this.motif = reservation.getMotif();
        this.statut = reservation.getStatut().toString();
        this.dateCreation = reservation.getDateCreation();

        // Professeur
        if (reservation.getUser() != null) {
            this.professeurId = reservation.getUser().getId();
            this.professeurNom = reservation.getUser().getNom();
            this.professeurPrenom = reservation.getUser().getPrenom();
            this.professeurEmail = reservation.getUser().getEmail();
        }

        // UE
        if (reservation.getUe() != null) {
            this.ueId = reservation.getUe().getIdUe();
            this.ueNom = reservation.getUe().getNom();
            this.ueDescription = reservation.getUe().getDescription();
            this.ueCredits = reservation.getUe().getCredits();
            this.ueNbHeures = reservation.getUe().getNbHeures();
            if (reservation.getUe().getComposante() != null) {
                this.ueComposante = reservation.getUe().getComposante().getAcronyme();
            }
        }
    }


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

    public Long getProfesseurId() {
        return professeurId;
    }

    public void setProfesseurId(Long professeurId) {
        this.professeurId = professeurId;
    }

    public String getProfesseurNom() {
        return professeurNom;
    }

    public void setProfesseurNom(String professeurNom) {
        this.professeurNom = professeurNom;
    }

    public String getProfesseurPrenom() {
        return professeurPrenom;
    }

    public void setProfesseurPrenom(String professeurPrenom) {
        this.professeurPrenom = professeurPrenom;
    }

    public String getProfesseurEmail() {
        return professeurEmail;
    }

    public void setProfesseurEmail(String professeurEmail) {
        this.professeurEmail = professeurEmail;
    }

    public Long getUeId() {
        return ueId;
    }

    public void setUeId(Long ueId) {
        this.ueId = ueId;
    }

    public String getUeNom() {
        return ueNom;
    }

    public void setUeNom(String ueNom) {
        this.ueNom = ueNom;
    }

    public String getUeDescription() {
        return ueDescription;
    }

    public void setUeDescription(String ueDescription) {
        this.ueDescription = ueDescription;
    }

    public int getUeCredits() {
        return ueCredits;
    }

    public void setUeCredits(int ueCredits) {
        this.ueCredits = ueCredits;
    }

    public int getUeNbHeures() {
        return ueNbHeures;
    }

    public void setUeNbHeures(int ueNbHeures) {
        this.ueNbHeures = ueNbHeures;
    }

    public String getUeComposante() {
        return ueComposante;
    }

    public void setUeComposante(String ueComposante) {
        this.ueComposante = ueComposante;
    }
}

