package Ex.modele;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.HashSet;
import java.util.Set;

/**
 * Entité représentant une Unité d'Enseignement (UE)
 * Une UE est définie par une composante et peut être enseignée par plusieurs professeurs
 */
@Entity
@Table(name = "ue")
public class UE {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idUe;

    @Column(nullable = false)
    private String nom;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private int nbHeures; // Nombre d'heures de cours

    @Column(nullable = false)
    private int credits; // Nombre de crédits ECTS

    // Une UE appartient à une composante
    @ManyToOne
    @JoinColumn(name = "composante_acronyme", nullable = false)
    private Composante composante;

    // Professeurs qui peuvent enseigner cette UE (relation Many-to-Many)
    @ManyToMany(mappedBy = "ues")
    @JsonIgnore
    private Set<User> professeurs = new HashSet<>();

    // Étudiants inscrits à cette UE (relation Many-to-Many)
    @ManyToMany(mappedBy = "uesInscrites")
    @JsonIgnore
    private Set<User> etudiants = new HashSet<>();

    // Réservations associées à cette UE
    @OneToMany(mappedBy = "ue")
    @JsonIgnore
    private Set<Reservation> reservations = new HashSet<>();


    public UE() {
    }

    public UE(String nom, String description, int nbHeures, int credits, Composante composante) {
        this.nom = nom;
        this.description = description;
        this.nbHeures = nbHeures;
        this.credits = credits;
        this.composante = composante;
    }

    // Getters et Setters
    public Long getIdUe() {
        return idUe;
    }

    public void setIdUe(Long idUe) {
        this.idUe = idUe;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getNbHeures() {
        return nbHeures;
    }

    public void setNbHeures(int nbHeures) {
        this.nbHeures = nbHeures;
    }

    public int getCredits() {
        return credits;
    }

    public void setCredits(int credits) {
        this.credits = credits;
    }

    public Composante getComposante() {
        return composante;
    }

    public void setComposante(Composante composante) {
        this.composante = composante;
    }

    public Set<User> getProfesseurs() {
        return professeurs;
    }

    public void setProfesseurs(Set<User> professeurs) {
        this.professeurs = professeurs;
    }

    public Set<User> getEtudiants() {
        return etudiants;
    }

    public void setEtudiants(Set<User> etudiants) {
        this.etudiants = etudiants;
    }

    public Set<Reservation> getReservations() {
        return reservations;
    }

    public void setReservations(Set<Reservation> reservations) {
        this.reservations = reservations;
    }

    // Méthodes utilitaires
    public void addProfesseur(User professeur) {
        this.professeurs.add(professeur);
        professeur.getUes().add(this);
    }

    public void removeProfesseur(User professeur) {
        this.professeurs.remove(professeur);
        professeur.getUes().remove(this);
    }

    public void addEtudiant(User etudiant) {
        this.etudiants.add(etudiant);
        etudiant.getUesInscrites().add(this);
    }

    public void removeEtudiant(User etudiant) {
        this.etudiants.remove(etudiant);
        etudiant.getUesInscrites().remove(this);
    }

    @Override
    public String toString() {
        return "UE{" +
                "idUe=" + idUe +
                ", nom='" + nom + '\'' +
                ", credits=" + credits +
                ", composante=" + (composante != null ? composante.getAcronyme() : "null") +
                '}';
    }
}

