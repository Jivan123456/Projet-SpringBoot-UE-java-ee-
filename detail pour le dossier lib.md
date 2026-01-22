# Documentation Technique - Application Gestion Universitaire

## Introduction

Application de gestion universitaire développée avec Flutter. Le but est de gérer les universités avec leurs campus, bâtiments, composantes et salles. L'app inclut un système d'authentification avec 3 rôles : Admin, Professeur et Étudiant.

## Architecture

L'app utilise un tableau de bord central avec un menu latéral qui change selon le rôle de l'utilisateur.

### Organisation du code

**models/** - Contient toutes les classes de données (Université, Campus, Bâtiment, Salle, User, etc.) avec leurs méthodes `fromJson()` et `toJson()` pour la communication avec l'API.

**pages/** - Toutes les interfaces utilisateur, organisées par rôle (admin/, professeur/, etudiant/). On y trouve les pages de connexion, le dashboard, et les pages de gestion des entités.

**services/** - Gère toute la communication avec le backend :
- `AuthService` : connexion, inscription, gestion du token JWT
- `ApiService` : opérations CRUD sur les entités
- `RechercheService` : recherche avancée de salles
- `ReservationService` : gestion des réservations

## Liste complète des fichiers du dossier lib/

### 📁 Racine (lib/)

**main.dart** - Point d'entrée de l'application. Charge les données d'auth au démarrage et redirige vers le dashboard si connecté, sinon vers la page de connexion.

### 📁 models/

> Tous les modèles ont `fromJson()` et `toJson()` pour la sérialisation. Seules les spécificités sont mentionnées ci-dessous.

**user.dart** - Modèle utilisateur avec id, email, nom, prénom, rôles.
- Getters : `isAdmin`, `isProfesseur`, `isEtudiant`, `roleDisplay`, `displayName`

**auth_response.dart** - Réponse d'authentification du backend.
- `toUser()` : Convertit la réponse en objet User

**universite.dart** - Modèle université avec acronyme (ID), nom, description.

**campus.dart** - Modèle campus avec id, nom, adresse, référence à l'université.

**batiment.dart** - Modèle bâtiment avec id, nom, nombre d'étages, références au campus et université.

**composante.dart** - Modèle composante (faculté/école) avec id, nom, description, référence à l'université.

**salle.dart** - Modèle salle avec numS (numéro), capacité, typeS, acces (accessibilité), référence au bâtiment.
- Enum `TypeSalle` : AMPHI, SC, TD, TP, NUMERIQUE

**reservation.dart** - Modèle réservation avec id, dates début/fin, objet, statut, références salle/utilisateur.
- Enum `StatutReservation` : EN_ATTENTE, APPROUVEE, REFUSEE

**reservation_details.dart** - Version détaillée d'une réservation avec infos complètes.

**ue.dart** - Modèle Unité d'Enseignement avec code, intitulé, crédits ECTS, liste des professeurs.


### 📁 services/

**auth_service.dart** - Gère l'authentification : login, register, logout, création de professeurs, chargement/sauvegarde du token dans SharedPreferences.
- `login(email, password)` : Connexion et sauvegarde du token
- `register(email, password, nom, prenom)` : Inscription
- `logout()` : Déconnexion et nettoyage
- `loadAuthData()` : Charge le token au démarrage
- `createProfesseur(email, password, nom, prenom)` : Crée un compte prof (admin)
- `getAllUsers()` : Liste tous les utilisateurs (admin)
- `isAdmin()` / `isProfesseur()` / `isEtudiant()` : Vérifications de rôle

**api_service.dart** - Gère toutes les opérations CRUD pour les 5 entités. Ajoute automatiquement le token JWT.
- `setToken(token)` : Définit le token JWT
- Pour chaque entité : `fetch()`, `create()`, `update()`, `delete()`
- Navigation hiérarchique : `getCampusByUniversite()`, `getBatimentByCampus()`, `getSalleByBatiment()`

**recherche_service.dart** - Recherche de salles : par ville, capacité, type, campus, université. Récupère aussi les statistiques pour les dashboards.
- `getSallesPourReviser(ville, minCap, maxCap)` : Salles pour étudiants
- `getSallesByCapacite(minCap, maxCap)` : Recherche par capacité
- `getSallesPourCours(type, minCap, campus)` : Salles pour cours (prof)
- `getSallesByUniversite(universite, type)` : Par université et type
- `searchMultiCriteria(ville, type, minCap, maxCap)` : Recherche multi-critères
- `getCampusStatistiques()` / `getBatimentStatistiques()` / `getComposanteStatistiques()` : Stats

**reservation_service.dart** - Gestion des réservations : création (professeurs), approbation/refus (admins), consultation.
- `creerReservation(nums, dateDebut, dateFin, objet)` : Crée une réservation (prof)
- `getMesReservations()` : Réservations de l'utilisateur connecté
- `getReservationsBySalle(nums)` : Réservations d'une salle
- `getReservationsEnAttente()` : Réservations en attente (admin)
- `approuverReservation(id)` : Approuve une réservation (admin)
- `refuserReservation(id)` : Refuse une réservation (admin)
- `annulerReservation(id)` : Annule une réservation

### 📁 pages/

**auth_page.dart** - Page de connexion et inscription. Deux formulaires avec validation des champs.
- `_login()` : Gère la connexion
- `_register()` : Gère l'inscription
- Formulaires séparés avec validation

**dashboard_page.dart** - Page principale avec menu latéral (flutter_side_menu). Menu adapté au rôle de l'utilisateur connecté.
> **Pattern commun** : Les pages `*_list_page.dart` ont toutes `_load()` et `_delete()`. Les pages `*_details_page.dart` affichent les infos et naviguent vers les entités liées.

**auth_page.dart** - Page de connexion et inscription avec validation.
- `_login()` et `_register()`

**dashboard_page.dart** - Page principale avec menu latéral adapté au rôle.
- `_navigateTo(page, title)` : Navigation entre sections

**home_page.dart** - Page d'accueil du dashboard.

**universite_list_page.dart** / **campus_list_page.dart** / **batiment_list_page.dart** / **composante_list_page.dart** / **salle_list_page.dart** - Listes des entités (suivent le pattern commun).

**universite_details_page.dart** - Détails université + navigation vers campus.

**campus_details_page.dart** - Détails campus + navigation vers bâtiments.

**batiment_details_page.dart** - Détails bâtiment + navigation vers salles.

**composante_details_page.dart** / **salle_details_page.dart** - Détails des entités.

**add_universite_page.dart** - Formulaire création/modification université.
- `_saveUniversite()` : Validation et sauvegarde

**professeur_ue_page.dart** / **ue_details_page.dart** - Gestion des UE
- `_showCreateUserDialog()` : Dialogue de création de prof
- `_showEditUserDialog(user)` : Dialogue de modification

**reservations_approval_page.dart** - Liste des réservations en attente avec boutons Approuver/Refuser.
- `_loadReservations()` : Charge les réservations en attente
- `_approuverReservation(id)` : Approuve
- `_refuserReservation(id)` : Refuse

**statistics_page.dart** - Statistiques globales (nombre de campus, bâtiments, salles, etc.).
- `_loadStatistics()` : Charge toutes les stats
- Affichage des compteurs par catégorie

**global_analysis_page.dart** - Analyses et graphiques pour l'admin.
- Graphiques et analyses visuelles

**ue_list_page.dart** - Liste de toutes les UE du système.
- `_loadUEs()` : Charge toutes les UE

### 📁 pages/professeur/

**create_reservation_page.dart** - Formulaire pour créer une demande de réservation de salle.
- `_loadSalles()` : Charge les salles disponibles
- `_createReservation()` : Crée la réservation
- Formulaire avec sélection de salle et dates

**my_reservations_page.dart** - Liste des réservations du professeur connecté avec leurs statuts.
- `_loadReservations()` : Charge les réservations du prof
- `_annulerReservation(id)` : Annule une réservation
- Affichage par statut (EN_ATTENTE/APPROUcomplète des utilisateurs.
- `_loadUsers()`, `_deleteUser()`, `_showCreateUserDialog()`, `_showEditUserDialog()`

**reservations_approval_page.dart** - Approbation des réservations.
- `_loadReservations()`, `_approuverReservation()`, `_refuserReservation()`

**statistics_page.dart** - Stats globales avec compteurs.
- `_loadStatistics()`

**global_analysis_page.dart** - Graphiques et analyses.

**ue_list_page.dart** - Liste de toutes les UE.

### 📁 pages/professeur/

**create_reservation_page.dart** - Création de réservation.
- `_loadSalles()`, `_createReservation()`

**my_reservations_page.dart** - Réservations du prof avec statuts.
- `_loadReservations()`, `_annulerReservation()`

**search_cours_page.dart** - Recherche de salles pour cours.
- `_searchSalles()` avec critères (type, capacité, campus)

### 📁 pages/etudiant/

> **Pattern** : Toutes ont `_searchSalles()` avec critères différents.

**search_revision_page.dart** - Recherche pour révision (ville, capacité).

**search_salles_page.dart** - Recherche multicritères complète.

**etudiant_ue_page.dart** - UE disponibles.
### Navigation hiérarchique

L'app respecte la hiérarchie : Université > Campus > Bâtiment > Salle

Navigation  entre les entités via boutons sur les pages de détail.

Lors de la création, obligation de sélectionner l'entité parente (ex: choix du campus lors de la création d'un bâtiment).

### CRUD et permissions

**ADMIN** : Create, Read, Update, Delete sur toutes les entités
**PROFESSEUR** : Read + gestion de ses réservations
**ÉTUDIANT** : Read uniquement

Les boutons d'action (Créer, Modifier, Supprimer) sont masqués automatiquement selon le rôle. Confirmation avant chaque suppression.

### Recherche de salles

Recherche multicritères :
- Ville
- Type de salle (AMPHI, SC, TD, TP, NUMERIQUE)
- Capacité (minimale et maximale)
- Campus
- Université

Résultats affichés en liste avec toutes les infos pertinentes.

### Réservations

**Professeur** :
- Crée une demande (salle, dates/heures, objet)
- Statut initial : EN_ATTENTE
- Peut voir ses réservations et leur statut

**Admin** :
- Voit toutes les réservations
- Peut approuver (APPROUVEE) ou refuser (REFUSEE)

