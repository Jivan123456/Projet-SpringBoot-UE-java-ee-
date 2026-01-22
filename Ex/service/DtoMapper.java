package Ex.service;

import Ex.dto.*;
import Ex.modele.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Classe utilitaire pour convertir entre les entités JPA et les DTOs
 * Facilite la séparation entre la couche de présentation (API) et la couche métier (JPA)
 */
@Component
public class DtoMapper {

    @Autowired
    private Ex.domain.UniversiteRepository universiteRepository;

    // ============================================
    // UNIVERSITE - Entity <-> DTO
    // ============================================

    /**
     * Convertit UniversiteDTO vers Universite (pour création/modification)
     */
    public Universite toEntity(UniversiteDTO dto) {
        if (dto == null) return null;

        Universite universite = new Universite();
        universite.setAcronyme(dto.getAcronyme());
        universite.setNom(dto.getNom());
        universite.setCreation(dto.getCreation());
        universite.setPresidence(dto.getPresidence());

        return universite;
    }

    /**
     * Convertit Universite vers UniversiteDTO (pour lecture)
     */
    public UniversiteDTO toDto(Universite universite) {
        if (universite == null) return null;

        return new UniversiteDTO(
            universite.getAcronyme(),
            universite.getNom(),
            universite.getCreation(),
            universite.getPresidence()
        );
    }

    /**
     * Met à jour une entité Universite existante avec les données du DTO
     */
    public void updateEntity(Universite universite, UniversiteDTO dto) {
        if (universite == null || dto == null) return;

        universite.setNom(dto.getNom());
        universite.setCreation(dto.getCreation());
        universite.setPresidence(dto.getPresidence());
        // Note: On ne modifie pas l'acronyme (clé primaire)
    }

    // ============================================
    // CAMPUS - Entity <-> DTO
    // ============================================

    /**
     * Convertit CampusDTO vers Campus (sans charger l'université)
     * L'université sera résolue par le service
     */
    public Campus toEntity(CampusDTO dto) {
        if (dto == null) return null;

        Campus campus = new Campus();
        campus.setNomC(dto.getNomC());
        campus.setVille(dto.getVille());
        // Note: universite sera set par le service si universiteId est fourni

        return campus;
    }

    /**
     * Convertit Campus vers CampusDTO (pour lecture)
     */
    public CampusDTO toDto(Campus campus) {
        if (campus == null) return null;

        return new CampusDTO(
            campus.getNomC(),
            campus.getVille(),
            campus.getUniversite() != null ? campus.getUniversite().getAcronyme() : null
        );
    }

    /**
     * Met à jour une entité Campus existante avec les données du DTO
     */
    public void updateEntity(Campus campus, CampusDTO dto) {
        if (campus == null || dto == null) return;

        campus.setVille(dto.getVille());
        // Note: universite sera mise à jour par le service si nécessaire
        // Note: On ne modifie pas nomC (clé primaire)
    }

    // ============================================
    // BATIMENT - Entity <-> DTO
    // ============================================

    /**
     * Convertit BatimentDTO vers Batiment (sans charger le campus)
     * Le campus sera résolu par le service
     */
    public Batiment toEntity(BatimentDTO dto) {
        if (dto == null) return null;

        Batiment batiment = new Batiment();
        batiment.setCodeB(dto.getCodeB());
        batiment.setAnneeC(dto.getAnneeC());
        // Note: campus sera set par le service

        return batiment;
    }

    /**
     * Convertit Batiment vers BatimentDTO (pour lecture)
     */
    public BatimentDTO toDto(Batiment batiment) {
        if (batiment == null) return null;

        return new BatimentDTO(
            batiment.getCodeB(),
            batiment.getAnneeC(),
            batiment.getCampus() != null ? batiment.getCampus().getNomC() : null
        );
    }

    /**
     * Met à jour une entité Batiment existante avec les données du DTO
     */
    public void updateEntity(Batiment batiment, BatimentDTO dto) {
        if (batiment == null || dto == null) return;

        batiment.setAnneeC(dto.getAnneeC());
        // Note: campus sera mis à jour par le service si nécessaire
        // Note: On ne modifie pas codeB (clé primaire)
    }

    // ============================================
    // SALLE - Entity <-> DTO
    // ============================================

    /**
     * Convertit SalleDTO vers Salle (sans charger le bâtiment)
     * Le bâtiment sera résolu par le service
     */
    public Salle toEntity(SalleDTO dto) {
        if (dto == null) return null;

        Salle salle = new Salle();
        salle.setNums(dto.getNums());
        salle.setCapacite(dto.getCapacite());
        salle.setTypes(dto.getTypes());
        salle.setAcces(dto.getAcces());
        salle.setEtage(dto.getEtage());
        // Note: batiment sera set par le service

        return salle;
    }

    /**
     * Convertit Salle vers SalleDTO (pour lecture)
     */
    public SalleDTO toDto(Salle salle) {
        if (salle == null) return null;

        return new SalleDTO(
            salle.getNums(),
            salle.getCapacite(),
            salle.getTypes(),
            salle.getAcces(),
            salle.getEtage(),
            salle.getBatiment() != null ? salle.getBatiment().getCodeB() : null
        );
    }

    /**
     * Met à jour une entité Salle existante avec les données du DTO
     */
    public void updateEntity(Salle salle, SalleDTO dto) {
        if (salle == null || dto == null) return;

        salle.setCapacite(dto.getCapacite());
        salle.setTypes(dto.getTypes());
        salle.setAcces(dto.getAcces());
        salle.setEtage(dto.getEtage());
        // Note: batiment sera mis à jour par le service si nécessaire
        // Note: On ne modifie pas nums (clé primaire)
    }

    // ============================================
    // COMPOSANTE - Entity <-> DTO
    // ============================================

    /**
     * Convertit ComposanteDTO vers Composante (pour création/modification)
     */
    public Composante toEntity(ComposanteDTO dto) {
        if (dto == null) return null;

        Composante composante = new Composante();
        composante.setAcronyme(dto.getAcronyme());
        composante.setNom(dto.getNom());
        composante.setResponsable(dto.getResponsable());

        // Gérer la relation avec Université si spécifiée
        if (dto.getUniversiteId() != null && !dto.getUniversiteId().isEmpty()) {
            universiteRepository.findById(dto.getUniversiteId())
                    .ifPresent(composante::setUniversite);
        }

        return composante;
    }

    /**
     * Convertit Composante vers ComposanteDTO (pour lecture)
     */
    public ComposanteDTO toDto(Composante composante) {
        if (composante == null) return null;

        String universiteId = composante.getUniversite() != null
            ? composante.getUniversite().getAcronyme()
            : null;

        return new ComposanteDTO(
            composante.getAcronyme(),
            composante.getNom(),
            composante.getResponsable(),
            universiteId
        );
    }

    /**
     * Met à jour une entité Composante existante avec les données du DTO
     */
    public void updateEntity(Composante composante, ComposanteDTO dto) {
        if (composante == null || dto == null) return;

        composante.setNom(dto.getNom());
        composante.setResponsable(dto.getResponsable());
        // Note: On ne modifie pas acronyme (clé primaire)
    }
}

