package Ex.service;

import Ex.domain.BatimentRepository;
import Ex.domain.CampusRepository;
import Ex.dto.BatimentDTO;
import Ex.modele.Batiment;
import Ex.modele.Campus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service de gestion des bâtiments
 */
@Service
@Transactional
public class BatimentService {

    @Autowired
    private BatimentRepository batimentRepository;

    @Autowired
    private CampusRepository campusRepository;

    @Autowired
    private DtoMapper dtoMapper;

    /**
     * Obtenir tous les bâtiments (DTOs)
     */
    public List<BatimentDTO> getAll() {
        return batimentRepository.findAll()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir un bâtiment par son code (DTO)
     */
    public Optional<BatimentDTO> getById(String codeB) {
        return batimentRepository.findById(codeB)
                .map(dtoMapper::toDto);
    }

    /**
     * Créer un nouveau bâtiment à partir d'un DTO
     */
    public BatimentDTO create(BatimentDTO dto) {
        Batiment batiment = dtoMapper.toEntity(dto);

        // Résoudre le campus
        Campus campus = campusRepository.findById(dto.getCampusId())
                .orElseThrow(() -> new RuntimeException("Campus non trouvé: " + dto.getCampusId()));
        batiment.setCampus(campus);

        Batiment saved = batimentRepository.save(batiment);
        return dtoMapper.toDto(saved);
    }

    /**
     * Mettre à jour un bâtiment existant à partir d'un DTO
     */
    public BatimentDTO update(String codeB, BatimentDTO dto) {
        Batiment batiment = batimentRepository.findById(codeB)
                .orElseThrow(() -> new RuntimeException("Bâtiment non trouvé: " + codeB));

        dtoMapper.updateEntity(batiment, dto);

        // Mettre à jour le campus si changé
        if (dto.getCampusId() != null && !dto.getCampusId().equals(batiment.getCampus().getNomC())) {
            Campus campus = campusRepository.findById(dto.getCampusId())
                    .orElseThrow(() -> new RuntimeException("Campus non trouvé: " + dto.getCampusId()));
            batiment.setCampus(campus);
        }

        Batiment updated = batimentRepository.save(batiment);
        return dtoMapper.toDto(updated);
    }

    /**
     * Supprimer un bâtiment
     */
    public void delete(String codeB) {
        batimentRepository.deleteById(codeB);
    }

    /**
     * Vérifier si un bâtiment existe
     */
    public boolean exists(String codeB) {
        return batimentRepository.existsById(codeB);
    }

    /**
     * Obtenir les bâtiments d'un campus (DTOs)
     */
    public List<BatimentDTO> getByCampus(String nomCampus) {
        return batimentRepository.findAll().stream()
            .filter(b -> b.getCampus() != null && nomCampus.equals(b.getCampus().getNomC()))
            .map(dtoMapper::toDto)
            .collect(Collectors.toList());
    }
}

