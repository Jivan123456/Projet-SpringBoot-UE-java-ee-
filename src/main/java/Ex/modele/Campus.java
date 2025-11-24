package Ex.modele;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

/**
 * Entité Campus
 * Représente un campus universitaire avec ses bâtiments et composantes
 */
@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "batiments"})
public class Campus {

	@Id
	private String nomC;

	private String ville;

	// Relation avec Universite (0..1 - un campus appartient à une université)
	@ManyToOne
	@JoinColumn(name="universite_id")
	@JsonIgnoreProperties({"campus"})
	private Universite universite;

	// Relation ManyToMany avec Composante (relation "exploite")
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(
		name = "campus_composante",
		joinColumns = @JoinColumn(name = "campus_id"),
		inverseJoinColumns = @JoinColumn(name = "composante_id")
	)
	@JsonIgnoreProperties({"campus"})
	private List<Composante> composantes = new ArrayList<>();

	// Relation OneToMany avec Batiment
	// Supprimer les bâtiments si le campus est supprimé
	@OneToMany(fetch = FetchType.LAZY, mappedBy="campus", cascade = CascadeType.REMOVE)
	@JsonIgnoreProperties({"campus"})
	private List<Batiment> batiments = new ArrayList<>();

	// Constructeurs
	public Campus() {
	}

	public Campus(String nomC, String ville) {
		super();
		this.nomC = nomC;
		this.ville = ville;
		this.batiments = new ArrayList<>();
		this.composantes = new ArrayList<>();
	}

	public Campus(String nomC, String ville, Universite universite) {
		super();
		this.nomC = nomC;
		this.ville = ville;
		this.universite = universite;
		this.batiments = new ArrayList<>();
		this.composantes = new ArrayList<>();
	}

	// Getters et Setters
	public String getNomC() {
		return nomC;
	}

	public void setNomC(String nomC) {
		this.nomC = nomC;
	}

	public String getVille() {
		return ville;
	}

	public void setVille(String ville) {
		this.ville = ville;
	}

	public List<Batiment> getBatiments() {
		return batiments;
	}

	public void setBatiments(List<Batiment> batiments) {
		this.batiments = batiments;
	}

	public Universite getUniversite() {
		return universite;
	}

	public void setUniversite(Universite universite) {
		this.universite = universite;
	}

	public List<Composante> getComposantes() {
		return composantes;
	}

	public void setComposantes(List<Composante> composantes) {
		this.composantes = composantes;
	}

	// Méthode utilitaire pour ajouter une composante
	public void addComposante(Composante composante) {
		if (!this.composantes.contains(composante)) {
			this.composantes.add(composante);
		}
	}

	@Override
	public String toString() {
		return "Campus [nomC=" + nomC + ", ville=" + ville + ", universite=" +
			(universite != null ? universite.getAcronyme() : "none") + "]";
	}
}

