package Ex.modele;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.*;

@Entity
@Table(name = "Salle")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Salle {

    @Id
    @Column(name = "nums")
    private String nums;       // clé primaire

    private int capacite;

    @Column(name = "types")
    private String types;

    private String acces;
    private String etage;

    @ManyToOne(optional = false)  // Relation obligatoire
    @JoinColumn(name = "batiment", nullable = false)  // FK NOT NULL
    @JsonIgnoreProperties({"salles"})
    private Batiment batiment;   // relation ManyToOne obligé avec Batiment


    public Salle() {}

    // Constructeur avec arguments (batiment de type Batiment, pas String)
    public Salle(String nums, int capacite, String types, String acces, String etage, Batiment batiment) {
        this.nums = nums;
        this.capacite = capacite;
        this.types = types;
        this.acces = acces;
        this.etage = etage;
        this.batiment = batiment;
    }

    // Getters et Setters
    public String getNums() { return nums; }
    public void setNums(String nums) { this.nums = nums; }

    public int getCapacite() { return capacite; }
    public void setCapacite(int capacite) { this.capacite = capacite; }

    public String getTypes() { return types; }
    public void setTypes(String types) { this.types = types; }

    public String getAcces() { return acces; }
    public void setAcces(String acces) { this.acces = acces; }

    public String getEtage() { return etage; }
    public void setEtage(String etage) { this.etage = etage; }

    public Batiment getBatiment() { return batiment; }
    public void setBatiment(Batiment batiment) { this.batiment = batiment; }

    @Override
    public String toString() {
        return "Salle{" +
                "nums='" + nums + '\'' +
                ", capacite=" + capacite +
                ", types='" + types + '\'' +
                ", acces='" + acces + '\'' +
                ", etage='" + etage + '\'' +
                ", batiment=" + (batiment != null ? batiment.toString() : "null") +
                '}';
    }
}
