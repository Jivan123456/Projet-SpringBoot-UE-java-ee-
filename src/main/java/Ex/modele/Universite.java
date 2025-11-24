package Ex.modele;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Entité Universite
 * Représente une université avec ses campus
 */
@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Universite {

    @Id
    private String acronyme;     // clé primaire ("UM"par exmeple)

    private String nom;
    private int creation;        // année  création
    private String presidence;   // nom président

    // Relation OneToMany avec Campus
    // Supprimer les campus si l'université est supprimée
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "universite", cascade = CascadeType.REMOVE)
    @JsonIgnoreProperties({"universite"})
    private List<Campus> campus = new ArrayList<>();


    public Universite() {
    }

    public Universite(String acronyme, String nom, int creation, String presidence) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.creation = creation;
        this.presidence = presidence;
        this.campus = new ArrayList<>();
    }

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

    public int getCreation() {
        return creation;
    }

    public void setCreation(int creation) {
        this.creation = creation;
    }

    public String getPresidence() {
        return presidence;
    }

    public void setPresidence(String presidence) {
        this.presidence = presidence;
    }

    public List<Campus> getCampus() {
        return campus;
    }

    public void setCampus(List<Campus> campus) {
        this.campus = campus;
    }

    @Override
    public String toString() {
        return "Universite{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", creation=" + creation +
                ", presidence='" + presidence + '\'' +
                '}';
    }
}

