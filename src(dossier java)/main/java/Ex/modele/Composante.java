package Ex.modele;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Composante {

    @Id
    private String acronyme;     // clé primaire

    private String nom;
    private String responsable;

    // Relation avec Université (hiérarchie administrative)
    // Une composante appartient à UNE université
    @ManyToOne
    @JoinColumn(name="universite_id")
    @JsonIgnoreProperties({"composantes"})
    private Universite universite;

    // Relation ManyToMany inverse avec Campus (localisation géographique)
    // Une composante peut être localisée sur plusieurs campus
    @ManyToMany(fetch = FetchType.LAZY, mappedBy = "composantes")
    @JsonIgnoreProperties({"composantes"})
    private List<Campus> campus = new ArrayList<>();

    public Composante() {}

    public Composante(String acronyme, String nom, String responsable) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
        this.campus = new ArrayList<>();
    }

    public Composante(String acronyme, String nom, String responsable, Universite universite) {
        this.acronyme = acronyme;
        this.nom = nom;
        this.responsable = responsable;
        this.universite = universite;
        this.campus = new ArrayList<>();
    }


    public String getAcronyme() { return acronyme; }
    public void setAcronyme(String acronyme) { this.acronyme = acronyme; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getResponsable() { return responsable; }
    public void setResponsable(String responsable) { this.responsable = responsable; }

    public Universite getUniversite() { return universite; }
    public void setUniversite(Universite universite) { this.universite = universite; }

    public List<Campus> getCampus() { return campus; }
    public void setCampus(List<Campus> campus) { this.campus = campus; }

    public void addCampus(Campus c) {
        if (!this.campus.contains(c)) {
            this.campus.add(c);
            c.addComposante(this);
        }
    }

    @Override
    public String toString() {
        return "Composante{" +
                "acronyme='" + acronyme + '\'' +
                ", nom='" + nom + '\'' +
                ", responsable='" + responsable + '\'' +
                '}';
    }
}
