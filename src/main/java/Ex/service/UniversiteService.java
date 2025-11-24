package Ex.service;

import Ex.domain.UniversiteRepository;
import Ex.dto.UniversiteDTO;
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
}

