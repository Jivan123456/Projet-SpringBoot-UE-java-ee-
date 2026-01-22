package Ex.service;

import Ex.domain.UserRepository;
import Ex.dto.AuthResponse;
import Ex.dto.LoginRequest;
import Ex.dto.RegisterRequest;
import Ex.modele.User;
import Ex.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    public AuthResponse login(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getEmail(),
                        loginRequest.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = tokenProvider.generateToken(authentication);

        User user = userRepository.findByEmail(loginRequest.getEmail())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        return new AuthResponse(token, user.getId(), user.getEmail(), user.getNom(), user.getPrenom(), user.getRoles());
    }

    public AuthResponse register(RegisterRequest registerRequest) {
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new RuntimeException(" email est déjà utilisé");
        }

        User user = new User();
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setNom(registerRequest.getNom());
        user.setPrenom(registerRequest.getPrenom());

        // Attribution du rôle
        Set<String> roles = new HashSet<>();

        // Si un rôle est spécifié (par admin), l'utiliser
        if (registerRequest.getRole() != null && !registerRequest.getRole().isEmpty()) {
            // Vérifier si un utilisateur est authentifié
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            System.out.println(" DEBUG - Authentication: " + authentication);
            System.out.println(" DEBUG - Role reçu: " + registerRequest.getRole());

            if (authentication != null && authentication.isAuthenticated()
                    && !authentication.getPrincipal().equals("anonymousUser")) {
                try {
                    User currentUser = getCurrentUser();
                    System.out.println(" DEBUG - Current user: " + currentUser.getEmail() + ", isAdmin: " + currentUser.isAdmin());

                    if (currentUser.isAdmin()) {
                        // Admin peut spécifier n'importe quel rôle
                        String roleToAdd = registerRequest.getRole().toUpperCase();
                        if (!roleToAdd.startsWith("ROLE_")) {
                            roleToAdd = "ROLE_" + roleToAdd;
                        }
                        roles.add(roleToAdd);
                        System.out.println(" DEBUG - Rôle attribué par admin: " + roleToAdd);
                    } else {
                        // Non-admin essaie de spécifier un rôle -> ignorer et utiliser ETUDIANT
                        roles.add("ROLE_ETUDIANT");
                        System.out.println(" DEBUG - Non-admin tente de créer un utilisateur, rôle ETUDIANT attribué");
                    }
                } catch (Exception e) {
                    // Erreur lors de la récupération de l'utilisateur
                    System.out.println(" DEBUG - Exception: " + e.getMessage());
                    roles.add("ROLE_ETUDIANT");
                }
            } else {
                // Pas d'utilisateur connecté -> inscription publique
                System.out.println(" DEBUG - Pas d'authentification, inscription publique");
                roles.add("ROLE_ETUDIANT");
            }
        } else {
            // Pas de rôle spécifié -> attribution automatique selon l'email
            String email = registerRequest.getEmail().toLowerCase();
            if (email.contains("@admin") || email.endsWith("@admin.com")) {
                roles.add("ROLE_ADMIN");
            } else {
                roles.add("ROLE_ETUDIANT");
            }
        }

        user.setRoles(roles);

        user = userRepository.save(user);

        // Générer un token pour l'utilisateur nouvellement créé
        String token = tokenProvider.generateTokenFromEmail(user.getEmail());

        return new AuthResponse(token, user.getId(), user.getEmail(), user.getNom(), user.getPrenom(), user.getRoles());
    }

    public AuthResponse registerProfesseur(RegisterRequest registerRequest) {
        // Vérifier que l'utilisateur connecté est un ADMIN
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès refusé : seul un administrateur peut créer un compte professeur");
        }

        // Vérifier si l'email existe déjà
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new RuntimeException("Cet email est déjà utilisé");
        }

        // Créer le nouveau professeur
        User professeur = new User();
        professeur.setEmail(registerRequest.getEmail());
        professeur.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        professeur.setNom(registerRequest.getNom());
        professeur.setPrenom(registerRequest.getPrenom());

        // Attribution du rôle PROFESSEUR
        Set<String> roles = new HashSet<>();
        roles.add("ROLE_PROFESSEUR");
        professeur.setRoles(roles);

        professeur = userRepository.save(professeur);

        // Générer un token pour le nouveau professeur
        String token = tokenProvider.generateTokenFromEmail(professeur.getEmail());

        return new AuthResponse(token, professeur.getId(), professeur.getEmail(), professeur.getNom(), professeur.getPrenom(), professeur.getRoles());
    }

    public User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    public java.util.List<User> getAllUsers() {
        // Vérifier que l'utilisateur connecté est un ADMIN
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès refusé : réservé aux administrateurs");
        }
        return userRepository.findAll();
    }

    public void deleteUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé: " + email));
        userRepository.delete(user);
    }

    public User updateUser(String email, RegisterRequest updateRequest) {
        // Vérifier que l'utilisateur connecté est un ADMIN
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin()) {
            throw new RuntimeException("Accès refusé : réservé aux administrateurs");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé: " + email));

        // Mettre à jour les informations
        user.setNom(updateRequest.getNom());
        user.setPrenom(updateRequest.getPrenom());

        // Mettre à jour le mot de passe si fourni
        if (updateRequest.getPassword() != null && !updateRequest.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(updateRequest.getPassword()));
        }

        // Mettre à jour le rôle si fourni
        if (updateRequest.getRole() != null && !updateRequest.getRole().isEmpty()) {
            Set<String> roles = new HashSet<>();
            roles.add("ROLE_" + updateRequest.getRole().toUpperCase());
            user.setRoles(roles);
        }

        return userRepository.save(user);
    }
}

