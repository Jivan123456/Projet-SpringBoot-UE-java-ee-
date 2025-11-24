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
    private String numS;       // clé primaire

    private int capacite;
    private String typeS;
    private String acces;
    private String etage;

    @ManyToOne(optional = false)  // Relation obligatoire
    @JoinColumn(name = "batiment", nullable = false)  // FK NOT NULL
    @JsonIgnoreProperties({"salles"})
    private Batiment batiment;   // relation ManyToOne OBLIGATOIRE avec Batiment


    public Salle() {}

    // Constructeur avec arguments (batiment de type Batiment, pas String)
    public Salle(String numS, int capacite, String typeS, String acces, String etage, Batiment batiment) {
        this.numS = numS;
        this.capacite = capacite;
        this.typeS = typeS;
        this.acces = acces;
        this.etage = etage;
        this.batiment = batiment;
    }

    // Getters et Setters
    public String getNumS() { return numS; }
    public void setNumS(String numS) { this.numS = numS; }

    public int getCapacite() { return capacite; }
    public void setCapacite(int capacite) { this.capacite = capacite; }

    public String getTypeS() { return typeS; }
    public void setTypeS(String typeS) { this.typeS = typeS; }

    public String getAcces() { return acces; }
    public void setAcces(String acces) { this.acces = acces; }

    public String getEtage() { return etage; }
    public void setEtage(String etage) { this.etage = etage; }

    public Batiment getBatiment() { return batiment; }
    public void setBatiment(Batiment batiment) { this.batiment = batiment; }

    @Override
    public String toString() {
        return "Salle{" +
                "numS='" + numS + '\'' +
                ", capacite=" + capacite +
                ", typeS='" + typeS + '\'' +
                ", acces='" + acces + '\'' +
                ", etage='" + etage + '\'' +
                ", batiment=" + (batiment != null ? batiment.toString() : "null") +
                '}';
    }
}
