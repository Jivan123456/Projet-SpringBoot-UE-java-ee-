package Ex.service;

import Ex.domain.CampusRepository;
import Ex.domain.UniversiteRepository;
import Ex.dto.CampusDTO;
import Ex.modele.Campus;
import Ex.modele.Universite;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service de gestion des campus
 */
@Service
@Transactional
public class CampusService {

    @Autowired
    private CampusRepository campusRepository;

    @Autowired
    private UniversiteRepository universiteRepository;

    @Autowired
    private DtoMapper dtoMapper;

    /**
     * Obtenir tous les campus (DTOs)
     */
    public List<CampusDTO> getAll() {
        return campusRepository.findAll()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir un campus par son nom (DTO)
     */
    public Optional<CampusDTO> getById(String nomC) {
        return campusRepository.findById(nomC)
                .map(dtoMapper::toDto);
    }

    /**
     * Créer un nouveau campus à partir d'un DTO
     */
    public CampusDTO create(CampusDTO dto) {
        Campus campus = dtoMapper.toEntity(dto);

        // Résoudre l'université si fournie (optionnel)
        if (dto.getUniversiteId() != null && !dto.getUniversiteId().isEmpty()) {
            Universite universite = universiteRepository.findById(dto.getUniversiteId())
                    .orElseThrow(() -> new RuntimeException("Université non trouvée: " + dto.getUniversiteId()));
            campus.setUniversite(universite);
        }

        Campus saved = campusRepository.save(campus);
        return dtoMapper.toDto(saved);
    }

    /**
     * Mettre à jour un campus existant à partir d'un DTO
     */
    public CampusDTO update(String nomC, CampusDTO dto) {
        Campus campus = campusRepository.findById(nomC)
                .orElseThrow(() -> new RuntimeException("Campus non trouvé: " + nomC));

        dtoMapper.updateEntity(campus, dto);

        // Mettre à jour l'université si changée
        if (dto.getUniversiteId() != null) {
            if (!dto.getUniversiteId().isEmpty()) {
                Universite universite = universiteRepository.findById(dto.getUniversiteId())
                        .orElseThrow(() -> new RuntimeException("Université non trouvée: " + dto.getUniversiteId()));
                campus.setUniversite(universite);
            } else {
                campus.setUniversite(null);  // Retirer l'université
            }
        }

        Campus updated = campusRepository.save(campus);
        return dtoMapper.toDto(updated);
    }

    /**
     * Supprimer un campus
     */
    public void delete(String nomC) {
        campusRepository.deleteById(nomC);
    }

    /**
     * Vérifier si un campus existe
     */
    public boolean exists(String nomC) {
        return campusRepository.existsById(nomC);
    }

    /**
     * Obtenir les campus d'une ville (DTOs)
     */
    public List<CampusDTO> getByVille(String ville) {
        return campusRepository.findByVille(ville)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir les campus d'une université (DTOs)
     */
    public List<CampusDTO> getByUniversite(String acronyme) {
        return campusRepository.findAll().stream()
            .filter(c -> c.getUniversite() != null && acronyme.equals(c.getUniversite().getAcronyme()))
            .map(dtoMapper::toDto)
            .collect(Collectors.toList());
    }
}

