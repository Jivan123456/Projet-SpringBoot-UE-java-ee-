package Ex.modele;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<String> roles = new HashSet<>();

    @Column(nullable = false)
    private boolean enabled = true;

    // UE que le professeur peut enseigner (pour les professeurs)
    @ManyToMany
    @JoinTable(
        name = "professeur_ue",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "ue_id")
    )
    private Set<UE> ues = new HashSet<>();

    // UE auxquelles l'étudiant est inscrit (pour les étudiants)
    @ManyToMany
    @JoinTable(
        name = "etudiant_ue",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "ue_id")
    )
    private Set<UE> uesInscrites = new HashSet<>();


    public User() {}

    public User(String email, String password, String nom, String prenom) {
        this.email = email;
        this.password = password;
        this.nom = nom;
        this.prenom = prenom;
    }


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public Set<String> getRoles() {
        return roles;
    }

    public void setRoles(Set<String> roles) {
        this.roles = roles;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }


    public void addRole(String role) {
        this.roles.add(role);
    }

    public boolean hasRole(String role) {
        return this.roles.contains(role);
    }

    public boolean isAdmin() {
        return this.roles.contains("ROLE_ADMIN");
    }

    public boolean isEtudiant() {
        return this.roles.contains("ROLE_ETUDIANT");
    }

    public boolean isProfesseur() {
        return this.roles.contains("ROLE_PROFESSEUR");
    }

    public Set<UE> getUes() {
        return ues;
    }

    public void setUes(Set<UE> ues) {
        this.ues = ues;
    }

    public Set<UE> getUesInscrites() {
        return uesInscrites;
    }

    public void setUesInscrites(Set<UE> uesInscrites) {
        this.uesInscrites = uesInscrites;
    }

    // Méthodes utilitaires pour gérer les UE
    public void addUe(UE ue) {
        this.ues.add(ue);
        ue.getProfesseurs().add(this);
    }

    public void removeUe(UE ue) {
        this.ues.remove(ue);
        ue.getProfesseurs().remove(this);
    }

    public void inscrireUe(UE ue) {
        this.uesInscrites.add(ue);
        ue.getEtudiants().add(this);
    }

    public void desinscrireUe(UE ue) {
        this.uesInscrites.remove(ue);
        ue.getEtudiants().remove(this);
    }
}

