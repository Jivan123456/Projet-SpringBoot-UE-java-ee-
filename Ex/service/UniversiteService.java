package Ex.service;

import Ex.domain.CampusRepository;
import Ex.domain.UniversiteRepository;
import Ex.dto.CampusDTO;
import Ex.dto.ComposanteDTO;
import Ex.dto.UniversiteDTO;
import Ex.modele.Campus;
import Ex.modele.Universite;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service de gestion des universités
 */
@Service
@Transactional
public class UniversiteService {

    @Autowired
    private UniversiteRepository universiteRepository;

    @Autowired
    private CampusRepository campusRepository;

    @Autowired
    private DtoMapper dtoMapper;

    /**
     * Obtenir toutes les universités (DTOs)
     */
    public List<UniversiteDTO> getAll() {
        return universiteRepository.findAll()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir une université par son acronyme (DTO)
     */
    public Optional<UniversiteDTO> getById(String acronyme) {
        return universiteRepository.findById(acronyme)
                .map(dtoMapper::toDto);
    }

    /**
     * Créer une nouvelle université à partir d'un DTO
     */
    public UniversiteDTO create(UniversiteDTO dto) {
        Universite universite = dtoMapper.toEntity(dto);
        Universite saved = universiteRepository.save(universite);
        return dtoMapper.toDto(saved);
    }

    /**
     * Mettre à jour une université existante à partir d'un DTO
     */
    public UniversiteDTO update(String acronyme, UniversiteDTO dto) {
        Universite universite = universiteRepository.findById(acronyme)
                .orElseThrow(() -> new RuntimeException("Université non trouvée: " + acronyme));

        dtoMapper.updateEntity(universite, dto);
        Universite updated = universiteRepository.save(universite);
        return dtoMapper.toDto(updated);
    }

    /**
     * Supprimer une université
     */
    public void delete(String acronyme) {
        universiteRepository.deleteById(acronyme);
    }

    /**
     * Vérifier si une université existe
     */
    public boolean exists(String acronyme) {
        return universiteRepository.existsById(acronyme);
    }

    /**
     * Obtenir toutes les composantes d'une université (hiérarchie administrative)
     */
    public List<ComposanteDTO> getComposantesByUniversite(String acronyme) {
        Universite universite = universiteRepository.findById(acronyme)
                .orElseThrow(() -> new RuntimeException("Université non trouvée: " + acronyme));

        return universite.getComposantes()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Créer un campus directement depuis une université (création en cascade)
     * @param acronyme L'acronyme de l'université parente
     * @param dto Le DTO du campus à créer (sans universiteId)
     * @return Le CampusDTO créé avec la relation université pré-remplie
     */
    public CampusDTO createCampusFromUniversite(String acronyme, CampusDTO dto) {
        // Vérifier que l'université existe
        Universite universite = universiteRepository.findById(acronyme)
                .orElseThrow(() -> new RuntimeException("Université non trouvée: " + acronyme));

        // Créer l'entité Campus
        Campus campus = new Campus();
        campus.setNomC(dto.getNomC());
        campus.setVille(dto.getVille());
        campus.setUniversite(universite); // Lien automatique avec l'université

        // Sauvegarder
        Campus saved = campusRepository.save(campus);
        return dtoMapper.toDto(saved);
    }
}

