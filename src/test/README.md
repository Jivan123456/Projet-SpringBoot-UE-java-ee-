# Tests du Projet TD1

## 📁 Structure des Tests

Les fichiers de test sont maintenant dans le dossier standard Maven/Spring Boot :
```
src/test/java/Ex/
├── TestCreation.java               # Test de création de toutes les entités
├── TestSalleRepository.java        # Test des requêtes JPQL personnalisées
└── TestCampusCapacityService.java  # Test des services TP2 (ACTIF)
```

---

## 🎯 Tests Disponibles

### 1. **TestCampusCapacityService** ✅ ACTIF

**Statut :** `@Component` activé - S'exécute automatiquement au démarrage

**Objectif :** Teste tous les services du TP2 (CampusCapacityService)

**Tests effectués :**
- ✓ Question 1 : Statistiques de tous les campus
- ✓ Question 2 : Salles TD < 40 places, PMR, à Montpellier
- ✓ Question 3 : Amphis >= 80 places sur campus Triolet
- ✓ Question 4 : Capacité totale d'un campus et d'un bâtiment
- ✓ Question 5 : Nombre de groupes pouvant être accueillis
- ✓ Question 6 : Nombre de groupes par type de salle

**Pour l'utiliser :**
1. Lancer l'application (`CL_Appli.java`)
2. Le test s'exécute automatiquement après l'initialisation des données
3. Consulter les résultats dans la console

---

### 2. **TestCreation** ⏸️ DÉSACTIVÉ

**Statut :** `@Component` commenté - Ne s'exécute pas automatiquement

**Objectif :** Teste la création de chaque type d'entité

**Tests effectués :**
- ✓ Création d'une Université
- ✓ Création d'une Composante
- ✓ Création d'un Campus (avec relation université et composante)
- ✓ Création d'un Bâtiment
- ✓ Création de Salles (TD, TP, Amphi)

**Pour l'activer :**
1. Ouvrir `src/test/java/Ex/TestCreation.java`
2. Décommenter `@Component` (ligne 17)
3. Relancer l'application

**Pour le désactiver :**
1. Recommenter `// @Component`

---

### 3. **TestSalleRepository** ⏸️ DÉSACTIVÉ

**Statut :** `@Component` commenté - Ne s'exécute pas automatiquement

**Objectif :** Teste les requêtes JPQL personnalisées du SalleRepository

**Tests effectués :**
- ✓ Récupération de toutes les salles
- ✓ Salles TD du bâtiment 36
- ✓ Salles par code bâtiment
- ✓ Salles par nom de campus
- ✓ Comptage de salles par bâtiment
- ✓ Comptage de salles par type

**Pour l'activer :**
1. Ouvrir `src/test/java/Ex/TestSalleRepository.java`
2. Décommenter `@Component` (ligne 16)
3. Relancer l'application

**Pour le désactiver :**
1. Recommenter `// @Component`

---

## 🚀 Comment Utiliser les Tests

### Exécuter les tests automatiquement

1. **Lancer l'application :**
   ```bash
   # Dans IntelliJ : Run CL_Appli.java
   # Ou en ligne de commande :
   mvn spring-boot:run
   ```

2. **Observer la console :**
   - Les tests actifs (`@Component` décommenté) s'exécutent automatiquement
   - Résultats affichés dans la console Spring Boot

### Activer/Désactiver un test

**Pour activer :**
```java
@Component  // ← Décommenter cette ligne
public class TestCreation implements CommandLineRunner {
    // ...
}
```

**Pour désactiver :**
```java
// @Component  // ← Commenter cette ligne
public class TestCreation implements CommandLineRunner {
    // ...
}
```

### Ordre d'exécution

Si plusieurs tests sont actifs, ils s'exécutent dans cet ordre :
1. `CL_Appli` (initialisation des données) - `@Order(1)` par défaut
2. `TestCampusCapacityService` - `@Order(2)`
3. `TestCreation` - pas d'ordre spécifié (s'exécute après)
4. `TestSalleRepository` - pas d'ordre spécifié

---

## 📊 Tests Actuellement Actifs

| Test | Statut | Ordre | Description |
|------|--------|-------|-------------|
| **TestCampusCapacityService** | ✅ ACTIF | 2 | Tests TP2 - Services de statistiques |
| **TestCreation** | ⏸️ DÉSACTIVÉ | - | Tests de création d'entités |
| **TestSalleRepository** | ⏸️ DÉSACTIVÉ | - | Tests requêtes JPQL |

---

## 🔍 Exemple de Sortie Console

Quand `TestCampusCapacityService` est actif :
```
========================================
TP2 - Test des Services CampusCapacity
========================================

=== Question 1: Statistiques de tous les campus ===
Campus: Campus Triolet (Montpellier)
  - Nombre de bâtiments: 1
  - Nombre de salles: 3
  - Capacité totale: 120 places

Campus: Elearning Center (Montpellier)
  - Nombre de bâtiments: 1
  - Nombre de salles: 4
  - Capacité totale: 110 places

[...]

========================================
Fin des tests TP2
========================================
```

---

## 💡 Bonnes Pratiques

### Ne pas activer tous les tests en même temps
- Activer uniquement le test dont vous avez besoin
- Évite la surcharge de la console
- Facilite le débogage

### Ordre recommandé pour tester

1. **D'abord :** Lancer l'application sans tests additionnels
   - Vérifier que l'initialisation (`CL_Appli`) fonctionne

2. **Ensuite :** Activer `TestCreation`
   - Vérifier la création des entités

3. **Puis :** Activer `TestSalleRepository`
   - Vérifier les requêtes JPQL

4. **Enfin :** Activer `TestCampusCapacityService`
   - Vérifier les services métier

### Tests Unitaires vs Tests d'Intégration

Les tests dans `src/test/java/` sont des **tests d'intégration** :
- Nécessitent le contexte Spring complet
- Utilisent la vraie base de données
- S'exécutent au démarrage de l'application

Pour des tests unitaires classiques (JUnit), créez des classes séparées dans `src/test/java/` avec `@Test`.

---

## 🛠️ Dépannage

### "Le test ne s'exécute pas"
- Vérifiez que `@Component` est décommenté
- Vérifiez qu'il n'y a pas d'erreur de compilation
- Relancez l'application

### "Erreurs lors de l'exécution"
- Vérifiez que la base de données est accessible
- Vérifiez que `CL_Appli` a bien initialisé les données
- Consultez les logs d'erreur dans la console

### "Les résultats sont vides"
- Les tests s'exécutent **après** `CL_Appli`
- Vérifiez que les données sont bien créées dans `CL_Appli`
- Utilisez `@Order(2)` pour forcer l'ordre d'exécution

---

## 📚 Ressources

- **Spring Boot Testing :** https://spring.io/guides/gs/testing-web/
- **JUnit 5 :** https://junit.org/junit5/docs/current/user-guide/
- **CommandLineRunner :** https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/CommandLineRunner.html

---

**✅ Les tests sont maintenant organisés dans `src/test/java/Ex/` selon les conventions Maven/Spring Boot !**

