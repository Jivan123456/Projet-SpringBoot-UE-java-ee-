#  Système de Gestion Universitaire

<div align="center">

![Java](https://img.shields.io/badge/Java-17-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

**Plateforme complète de gestion des infrastructures universitaires**

[Caractéristiques](#-caractéristiques) • [Architecture](#-architecture) • [Installation](#-installation) • [API](#-documentation-api) • [Frontend](#-frontend-flutter)

</div>

---



##  À propos du projet

Ce projet est une **application full-stack actuellement en cours de développement**, réalisée dans le cadre de l'UE Java EE. L'objectif principal est de créer un système complet de gestion des infrastructures universitaires (universités, campus, bâtiments et salles) avec une architecture moderne et modulaire.

### Stack technique

L'application repose sur une architecture full-stack  qui sépare le backend et le frontend :

- **Backend** : Le serveur est développé avec **Spring Boot 3.3.4**, utilisant Java 17 et exploitant Spring Data JPA avec Hibernate pour la persistance des données. L'ensemble de l'API REST est documenté via Swagger/OpenAPI pour faciliter son utilisation.

- **Base de données** : La persistance des données est assurée par une base de données **MySQL 8.0**, déployée dans un conteneur **Docker** pour faciliter la configuration et garantir la portabilité de l'environnement de développement.

- **Frontend** : L'interface utilisateur mobile est développée avec **Flutter**, permettant de créer une application cross-platform (Android, iOS, Web) avec une interface moderne et réactive.

###  État actuel du développement 

Le projet est dans une **phase active de développement**. À ce stade, le backend Spring Boot est entièrement fonctionnel avec tous les endpoints REST opérationnels pour l'ensemble des entités (Universités, Campus, Bâtiments, Salles, Composantes). La base de données MySQL est conteneurisée avec Docker et le schéma relationnel complet est implémenté.

Concernant le frontend Flutter, j'ai  développé les **premières fonctionnalités essentielles** qui permettent d'interagir avec le système. Actuellement, l'application mobile offre deux fonctionnalités principales :

1. **Visualisation de la liste des universités** : Les utilisateurs peuvent consulter l'ensemble des universités enregistrées dans le système, avec l'affichage de leurs informations principales (nom, acronyme, présidence, année de création).

2. **Création de nouvelles universités** : Un formulaire complet permet d'ajouter de nouvelles universités au système, avec validation des champs et communication en temps réel avec l'API backend.

Le dossier **`lib/`** du projet contient l'intégralité du code source Flutter, organisé de manière structurée avec les modèles de données, les services d'API, et les pages de l'interface utilisateur.

###  Fonctionnalités à venir

Les prochaines étapes du développement incluront l'ajout des interfaces Flutter pour la gestion complète des campus, bâtiments et salles, ainsi que l'implémentation des fonctionnalités d'édition et de suppression. Nous prévoyons également d'intégrer l'affichage des statistiques et des recherches avancées directement dans l'application mobile.

---

##  Caractéristiques

### Backend (Spring Boot)

- **Architecture en couches** : Controllers → Services → Repositories → Entities
- **API RESTful complète** avec CRUD pour toutes les entités
- **DTOs et Mappers** pour la sécurité et l'optimisation
- **Requêtes personnalisées** JPQL et Spring Data JPA
- **Gestion des relations** bidirectionnelles et cascade
- **Validation des données** avec Jakarta Validation
- **Documentation Swagger/OpenAPI** intégrée
- **CORS configuré** pour le développement cross-origin

### Frontend (Flutter)

- **Interface utilisateur moderne** et responsive
- **Gestion d'état** avec Provider/setState
- **Consommation API REST** avec http package
- **Navigation fluide** entre les différentes vues
- **Formulaires de création/édition** pour les universités
- **Affichage en liste** avec détails et actions
- **Support multiplateforme** : Android, iOS, Web

---

##  Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                       │
│                   (Frontend Mobile/Web)                      │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/REST
                         │ Port 8889
┌────────────────────────▼────────────────────────────────────┐
│              Spring Boot Application                         │
│                     (Backend API)                            │
├──────────────────────────────────────────────────────────────┤
│  Controllers (REST Endpoints)                                │
│    ↓                                                          │
│  Services (Business Logic)                                   │
│    ↓                                                          │
│  Repositories (Data Access Layer)                            │
│    ↓                                                          │
│  JPA/Hibernate (ORM)                                         │
└────────────────────────┬────────────────────────────────────┘
                         │ JDBC
                         │ Port 3306
┌────────────────────────▼────────────────────────────────────┐
│                  MySQL Database                              │
│              (Database1 - via Docker)                        │
└──────────────────────────────────────────────────────────────┘
```

### Modèle en couches

```
┌──────────────────────┐
│   Presentation       │  Controllers REST (@RestController)
├──────────────────────┤
│   Business Logic     │  Services (@Service)
├──────────────────────┤
│   Data Access        │  Repositories (JpaRepository)
├──────────────────────┤
│   Domain Model       │  Entities (@Entity)
└──────────────────────┘
```

---

##  Technologies utilisées

### Backend

| Technologie | Version | Usage |
|------------|---------|-------|
| **Java** | 17+ | Langage de programmation |
| **Spring Boot** | 3.3.4 | Framework backend |
| **Spring Data JPA** | 3.3.4 | Couche de persistance |
| **Hibernate** | 6.5.3 | ORM (Object-Relational Mapping) |
| **MySQL** | 8.0.31 | Base de données |
| **Maven** | 3.x | Gestion des dépendances |
| **Swagger/OpenAPI** | 3.x | Documentation API |
| **Lombok** | (optionnel) | Réduction du code boilerplate |

### Frontend

| Technologie | Usage |
|------------|-------|
| **Flutter** | Framework UI cross-platform |
| **Dart** | Langage de programmation |
| **http** | Client REST pour les appels API |
| **Material Design** | Composants UI |

### Infrastructure

| Outil | Usage |
|-------|-------|
| **Docker** | Conteneurisation MySQL |
| **Docker Compose** | Orchestration des services |
| **Git** | Gestion de version |

---
### Exemples de requêtes API

#### 1. Récupérer toutes les universités

```bash
curl -X GET http://localhost:8889/api/universite
```

#### 2. Créer une nouvelle université

```bash
curl -X POST http://localhost:8889/api/universite \
  -H "Content-Type: application/json" \
  -d '{
    "acronyme": "UM",
    "nom": "Université de Montpellier",
    "presidence": "Dr. Martin Dupont",
    "creation": 1289
  }'
```

#### 3. Récupérer les statistiques d'un campus

```bash
curl -X GET http://localhost:8889/api/campus/Triolet/statistics
```

#### 4. Rechercher des salles

```bash
# Salles TD de moins de 40 places avec accès PMR à Montpellier
curl -X GET "http://localhost:8889/api/salle/search?type=td&capacity=40&pmr=true&ville=Montpellier"
```

#### 5. Créer un bâtiment

```bash
curl -X POST http://localhost:8889/api/batiment \
  -H "Content-Type: application/json" \
  -d '{
    "codeb": "BAT9",
    "anneec": 2020,
    "campusNom": "Triolet"
  }'
```

### Frontend - Navigation

1. **Page d'accueil** : Vue d'ensemble avec navigation
2. **Liste des universités** : Affichage de toutes les universités
3**Formulaire de création** : Ajout d'une nouvelle université


---

##  Documentation API

### Endpoints principaux

####  Universités

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/universite` | Liste toutes les universités |
| GET | `/api/universite/{acronyme}` | Détails d'une université |
| POST | `/api/universite` | Créer une université |
| PUT | `/api/universite/{acronyme}` | Modifier une université |
| DELETE | `/api/universite/{acronyme}` | Supprimer une université |
| GET | `/api/universite/{acronyme}/statistics` | Statistiques |

####  Campus

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/campus` | Liste tous les campus |
| GET | `/api/campus/{nomc}` | Détails d'un campus |
| POST | `/api/campus` | Créer un campus |
| PUT | `/api/campus/{nomc}` | Modifier un campus |
| DELETE | `/api/campus/{nomc}` | Supprimer un campus |
| GET | `/api/campus/ville/{ville}` | Campus par ville |
| GET | `/api/campus/{nomc}/statistics` | Statistiques du campus |
| GET | `/api/campus/all/statistics` | Statistiques de tous les campus |

####  Bâtiments

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/batiment` | Liste tous les bâtiments |
| GET | `/api/batiment/{codeb}` | Détails d'un bâtiment |
| POST | `/api/batiment` | Créer un bâtiment |
| PUT | `/api/batiment/{codeb}` | Modifier un bâtiment |
| DELETE | `/api/batiment/{codeb}` | Supprimer un bâtiment |
| GET | `/api/batiment/{codeb}/statistics` | Statistiques du bâtiment |

####  Salles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/salle` | Liste toutes les salles |
| GET | `/api/salle/{nums}` | Détails d'une salle |
| POST | `/api/salle` | Créer une salle |
| PUT | `/api/salle/{nums}` | Modifier une salle |
| DELETE | `/api/salle/{nums}` | Supprimer une salle |
| GET | `/api/salle/search` | Rechercher des salles (avec filtres) |

####  Composantes

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/composante` | Liste toutes les composantes |
| GET | `/api/composante/{acronyme}` | Détails d'une composante |
| POST | `/api/composante` | Créer une composante |
| PUT | `/api/composante/{acronyme}` | Modifier une composante |
| DELETE | `/api/composante/{acronyme}` | Supprimer une composante |

### Exemples de réponses JSON

#### Université avec statistiques

```json
{
  "acronyme": "UM",
  "nom": "Université de Montpellier",
  "presidence": "Dr. Martin Dupont",
  "creation": 1289,
  "nombreCampus": 2,
  "nombreComposantes": 1,
  "capaciteTotale": 190
}
```

#### Statistiques de campus

```json
{
  "nomCampus": "Triolet",
  "ville": "Montpellier",
  "universite": "UM",
  "nombreBatiments": 1,
  "nombreSalles": 3,
  "capaciteTotale": 120
}
```

---

##  Frontend Flutter

### Structure de l'application

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── models/
│   └── universite.dart               # Modèle de données Université
├── services/
│   └── api_service.dart              # Service d'appels API REST
└── pages/
    ├── home_page.dart                # Page d'accueil
    ├── universite_list_page.dart     # Liste des universités
    └── add_universite_page.dart      # Formulaire d'ajout
```

### Modèles de données

#### Classe Université

```dart
class Universite {
  final String acronyme;
  final String nom;
  final String presidence;
  final int creation;

  Universite({
    required this.acronyme,
    required this.nom,
    required this.presidence,
    required this.creation,
  });

  factory Universite.fromJson(Map<String, dynamic> json) {
    return Universite(
      acronyme: json['acronyme'],
      nom: json['nom'],
      presidence: json['presidence'],
      creation: json['creation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acronyme': acronyme,
      'nom': nom,
      'presidence': presidence,
      'creation': creation,
    };
  }
}
```

### Service API

Le service `ApiService` gère toutes les communications avec le backend :

- `fetchUniversites()` : Récupérer la liste
- `createUniversite()` : Créer une nouvelle entrée
- `updateUniversite()` : Mettre à jour
- `deleteUniversite()` : Supprimer

### Pages principales

#### 1. HomePage

Page d'accueil avec navigation vers les différentes fonctionnalités.

#### 2. UniversiteListPage

Affiche la liste complète des universités avec options de :
- Affichage détaillé
- Modification
- Suppression

#### 3. AddUniversitePage

Formulaire de création/édition avec validation des champs :
- Acronyme (requis, unique)
- Nom complet
- Présidence
- Année de création

---

## 🗄 Modèle de données

### Schéma de la base de données

```
┌─────────────────┐
│   UNIVERSITE    │
│─────────────────│
│ acronyme (PK)   │
│ nom             │
│ presidence      │
│ creation        │
└────────┬────────┘
         │ 1
         │
         │ n
┌────────▼────────┐
│     CAMPUS      │
│─────────────────│
│ nomc (PK)       │
│ ville           │
│ universite_id   │◄─────┐
└────────┬────────┘      │
         │ 1             │
         │               │ n
         │ n             │
┌────────▼────────┐      │
│   BATIMENT      │      │
│─────────────────│      │
│ codeb (PK)      │      │
│ anneec          │      │
│ campus          │      │
└────────┬────────┘      │
         │ 1             │
         │               │
         │ n        ┌────┴────────┐
┌────────▼────────┐ │  COMPOSANTE │
│     SALLE       │ │─────────────│
│─────────────────│ │ acronyme(PK)│
│ nums (PK)       │ │ nom         │
│ capacite        │ │ responsable │
│ types           │ └─────────────┘
│ acces           │       ▲
│ etage           │       │
│ batiment        │       │ n
└─────────────────┘       │
                          │
            ┌─────────────┴──────────────┐
            │  CAMPUS_COMPOSANTE (join)  │
            │────────────────────────────│
            │ campus_id                  │
            │ composante_id              │
            └────────────────────────────┘
```

### Relations

- **Universite** 1───n **Campus** (OneToMany)
- **Universite** 1───n **Composante** (OneToMany)
- **Campus** n───n **Composante** (ManyToMany)
- **Campus** 1───n **Batiment** (OneToMany)
- **Batiment** 1───n **Salle** (OneToMany)

### Cascade et suppressions

 **Cascade activé** (Parent → Enfant) :
- Universite → Campus
- Universite → Composante
- Campus → Batiment
- Batiment → Salle

 **Pas de cascade** (Enfant → Parent) :
- Pour éviter les suppressions accidentelles en cascade inverse

---




## 📂 Structure du projet

```
Td1/
├── 📁 src/
│   ├── 📁 main/
│   │   ├── 📁 java/Ex/
│   │   │   ├── 📄 CL_Appli.java           # Classe principale Spring Boot
│   │   │   ├── 📁 config/                 # Configurations (CORS, Swagger)
│   │   │   │   ├── WebConfig.java
│   │   │   │   └── OpenAPIConfig.java
│   │   │   ├── 📁 controller/             # REST Controllers
│   │   │   │   ├── UniversiteController.java
│   │   │   │   ├── CampusController.java
│   │   │   │   ├── BatimentController.java
│   │   │   │   ├── SalleController.java
│   │   │   │   └── ComposanteController.java
│   │   │   ├── 📁 service/                # Business Logic
│   │   │   │   ├── UniversiteService.java
│   │   │   │   ├── CampusService.java
│   │   │   │   ├── BatimentService.java
│   │   │   │   ├── SalleService.java
│   │   │   │   ├── ComposanteService.java
│   │   │   │   └── DtoMapper.java
│   │   │   ├── 📁 domain/                 # Repositories (Data Access)
│   │   │   │   ├── UniversiteRepository.java
│   │   │   │   ├── CampusRepository.java
│   │   │   │   ├── BatimentRepository.java
│   │   │   │   ├── SalleRepository.java
│   │   │   │   └── ComposanteRepository.java
│   │   │   ├── 📁 modele/                 # Entities (JPA)
│   │   │   │   ├── Universite.java
│   │   │   │   ├── Campus.java
│   │   │   │   ├── Batiment.java
│   │   │   │   ├── Salle.java
│   │   │   │   ├── Composante.java
│   │   │   │   └── TypeSalle.java
│   │   │   └── 📁 dto/                    # Data Transfer Objects
│   │   │       ├── UniversiteDTO.java
│   │   │       ├── UniversiteStatisticsDTO.java
│   │   │       ├── CampusDTO.java
│   │   │       ├── CampusStatisticsDTO.java
│   │   │       ├── BatimentDTO.java
│   │   │       ├── BatimentStatisticsDTO.java
│   │   │       ├── SalleDTO.java
│   │   │       └── ComposanteDTO.java
│   │   └── 📁 resources/
│   │       ├── application.properties      # Configuration Spring
│   │       └── 📁 static/                  # Ressources statiques
│   └── 📁 test/java/Ex/                   # Tests unitaires
│       ├── TestCreation.java
│       └── TestSalleRepository.java
│
├── 📁 lib/                                 # Frontend Flutter
│   ├── 📄 main.dart                       # Point d'entrée Flutter
│   ├── 📁 models/
│   │   └── universite.dart
│   ├── 📁 services/
│   │   └── api_service.dart
│   └── 📁 pages/
│       ├── home_page.dart
│       ├── universite_list_page.dart
│       └── add_universite_page.dart
│
├── 📁 scripts/                            # Scripts utilitaires
├── 📁 target/                             # Fichiers compilés (généré)
├── 📄 docker-compose.yml                  # Configuration Docker
├── 📄 pom.xml                             # Configuration Maven
├── 📄 README.md                           # Ce fichier
└── 📄 .gitignore                          # Fichiers ignorés par Git
```






## 

Ce projet est développé dans un cadre éducatif pour le cours de Java EE.

---

