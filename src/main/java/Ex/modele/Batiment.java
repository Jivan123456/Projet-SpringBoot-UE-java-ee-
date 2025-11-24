package Ex.modele;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Batiment {
	
	@Id
	private String codeB;
	
	private int anneeC;
	
	@ManyToOne(optional = false)  //  Batiment doit appartenir à un Campus
	@JoinColumn(name="campus", nullable = false)  // (not null)
	@JsonIgnoreProperties({"batiments"})
	private Campus campus;
	
	// Relation OneToMany avec Salle
	// Supprimer les salles si le bâtiment est supprimé
	@OneToMany(fetch = FetchType.LAZY, mappedBy="batiment", cascade = CascadeType.REMOVE)
	@JsonIgnoreProperties({"batiment"})
	private List<Salle> salles = new ArrayList<>();


	public Batiment() {
		this.salles = new ArrayList<>();
	}

	public Batiment(String codeB, int anneeC, Campus campus) {
		super();
		this.codeB = codeB;
		this.anneeC = anneeC;
		this.campus = campus;
		this.salles = new ArrayList<>();
	}

	public String getCodeB() {
		return codeB;
	}

	public void setCodeB(String codeB) {
		this.codeB = codeB;
	}

	public int getAnneeC() {
		return anneeC;
	}

	public void setAnneeC(int anneeC) {
		this.anneeC = anneeC;
	}

	public Campus getCampus() {
		return campus;
	}

	public void setCampus(Campus campus) {
		this.campus = campus;
	}
	
	public List<Salle> getSalles() {
		return salles;
	}

	public void setSalles(List<Salle> salles) {
		this.salles = salles;
	}

	@Override
	public String toString() {
		return "Batiment [codeB=" + codeB  + ", anneeC=" + anneeC + "]";
	}
	
}
