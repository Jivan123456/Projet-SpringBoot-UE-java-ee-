package Ex.controller;

import Ex.dto.AuthResponse;
import Ex.dto.LoginRequest;
import Ex.dto.RegisterRequest;
import Ex.modele.User;
import Ex.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
@Tag(name = "Authentification", description = "API de gestion de l'authentification")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Se connecter", description = "Authentifie un utilisateur et retourne un token JWT")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
        try {
            AuthResponse response = authService.login(loginRequest);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/register")
    @Operation(
            summary = "S'inscrire ou créer un utilisateur",
            description = "Si appelé sans authentification: crée un compte ÉTUDIANT. Si appelé avec le token ADMIN et un champ 'role': crée un utilisateur avec le rôle spécifié (ADMIN, PROFESSEUR, ETUDIANT)"
    )
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest registerRequest) {
        try {
            AuthResponse response = authService.register(registerRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null);
        }
    }

    @GetMapping("/me")
    @Operation(summary = "Obtenir l'utilisateur connecté", description = "Retourne les informations de l'utilisateur actuellement connecté")
    public ResponseEntity<User> getCurrentUser() {
        try {
            User user = authService.getCurrentUser();
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/create-professeur")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = " Créer un compte professeur",
            description = "Permet à un administrateur de créer un nouveau compte avec le rôle PROFESSEUR. **Réservé aux administrateurs uniquement.** Les professeurs peuvent réserver des salles et accéder aux endpoints de recherche avancée. ⚠️ Les professeurs NE PEUVENT PAS s'inscrire eux-mêmes via /register. Exemple : {\"email\": \"prof@univ-montpellier.fr\", \"password\": \"motdepasse\", \"nom\": \"Dupont\", \"prenom\": \"Marie\"}"
    )
    public ResponseEntity<?> createProfesseur(@RequestBody RegisterRequest registerRequest) {
        try {
            AuthResponse response = authService.registerProfesseur(registerRequest);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }

    @GetMapping("/users")
    @Operation(summary = "Lister tous les utilisateurs", description = "Retourne la liste de tous les utilisateurs (ADMIN uniquement)")
    public ResponseEntity<?> getAllUsers() {
        try {
            java.util.List<User> users = authService.getAllUsers();
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.status(403).body("Accès refusé");
        }
    }

    @DeleteMapping("/users/{email}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Supprimer un utilisateur", description = "Supprime un utilisateur par son email")
    public ResponseEntity<?> deleteUser(@PathVariable String email) {
        try {
            authService.deleteUser(email);
            return ResponseEntity.ok("Utilisateur supprimé: " + email);
        } catch (Exception e) {
            return ResponseEntity.status(404).body("Erreur: " + e.getMessage());
        }
    }

    @PutMapping("/users/{email}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Modifier un utilisateur", description = "Modifie les informations d'un utilisateur (ADMIN uniquement)")
    public ResponseEntity<?> updateUser(@PathVariable String email, @RequestBody RegisterRequest updateRequest) {
        try {
            User updatedUser = authService.updateUser(email, updateRequest);
            return ResponseEntity.ok(updatedUser);
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Erreur: " + e.getMessage());
        }
    }
}

