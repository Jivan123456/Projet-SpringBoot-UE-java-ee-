package Ex.config;

import Ex.security.CustomUserDetailsService;
import Ex.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(request -> {
                    org.springframework.web.cors.CorsConfiguration config = new org.springframework.web.cors.CorsConfiguration();
                    config.setAllowedOriginPatterns(java.util.Arrays.asList("http://localhost:*", "http://127.0.0.1:*"));
                    config.setAllowedMethods(java.util.Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
                    config.setAllowedHeaders(java.util.Arrays.asList("*"));
                    config.setAllowCredentials(true);
                    config.setExposedHeaders(java.util.Arrays.asList("Authorization", "Content-Type"));
                    config.setMaxAge(3600L);
                    return config;
                }))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 1. OPTIONS requests (CORS pre-flight) - TOUJOURS EN PREMIER
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                        // 2. Authentification (login/register) - PUBLIC
                        .requestMatchers("/api/auth/login").permitAll()
                        .requestMatchers("/api/auth/register").permitAll()
                        .requestMatchers("/api/auth/me").authenticated()
                        .requestMatchers(HttpMethod.GET, "/api/auth/users").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/auth/users/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/auth/users/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/auth/users/**").hasRole("ADMIN")
                        .requestMatchers("/api/auth/**").hasRole("ADMIN")

                        // 3. Swagger - PUBLIC
                        .requestMatchers(
                                "/v3/api-docs",
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/swagger-resources/**",
                                "/configuration/**",
                                "/webjars/**"
                        ).permitAll()

                        // 4. Endpoints de consultation (ETUDIANT, PROFESSEUR et ADMIN)
                        .requestMatchers(HttpMethod.GET, "/api/universite/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/campus/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/batiment/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/salle/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/composante/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")

                        // 5. Endpoints de modification (ADMIN uniquement)
                        .requestMatchers(HttpMethod.POST, "/api/universite/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/universite/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/universite/**").hasRole("ADMIN")

                        .requestMatchers(HttpMethod.POST, "/api/campus/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/campus/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/campus/**").hasRole("ADMIN")

                        .requestMatchers(HttpMethod.POST, "/api/batiment/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/batiment/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/batiment/**").hasRole("ADMIN")

                        .requestMatchers(HttpMethod.POST, "/api/salle/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/salle/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/salle/**").hasRole("ADMIN")

                        .requestMatchers(HttpMethod.POST, "/api/composante/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/composante/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/composante/**").hasRole("ADMIN")

                        // 6. UE - Consultation pour tous, gestion pour ADMIN et PROFESSEUR
                        .requestMatchers(HttpMethod.GET, "/api/ue/**").hasAnyRole("ETUDIANT", "PROFESSEUR", "ADMIN")
                        // Endpoints spécifiques professeur-UE
                        .requestMatchers(HttpMethod.POST, "/api/ue/*/professeur/*").hasAnyRole("PROFESSEUR", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/ue/*/professeur/*").hasAnyRole("PROFESSEUR", "ADMIN")
                        // Endpoints spécifiques étudiant-UE (inscription/désinscription)
                        .requestMatchers(HttpMethod.POST, "/api/ue/*/etudiant/*").hasAnyRole("ETUDIANT", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/ue/*/etudiant/*").hasAnyRole("ETUDIANT", "ADMIN")
                        // Gestion générale des UE (ADMIN uniquement)
                        .requestMatchers(HttpMethod.POST, "/api/ue").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/ue/**").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/ue/**").hasRole("ADMIN")

                        .anyRequest().authenticated()
                );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}

