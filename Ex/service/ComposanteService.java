package Ex.service;

import Ex.domain.ComposanteRepository;
import Ex.dto.CampusDTO;
import Ex.dto.ComposanteDTO;
import Ex.modele.Composante;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service de gestion des composantes
 */
@Service
@Transactional
public class ComposanteService {

    @Autowired
    private ComposanteRepository composanteRepository;

    @Autowired
    private Ex.domain.UniversiteRepository universiteRepository;

    @Autowired
    private DtoMapper dtoMapper;

    /**
     * Obtenir toutes les composantes (DTOs)
     */
    public List<ComposanteDTO> getAll() {
        return composanteRepository.findAll()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir une composante par son acronyme (DTO)
     */
    public Optional<ComposanteDTO> getById(String acronyme) {
        return composanteRepository.findById(acronyme)
                .map(dtoMapper::toDto);
    }

    /**
     * Créer une nouvelle composante à partir d'un DTO
     */
    public ComposanteDTO create(ComposanteDTO dto) {
        Composante composante = dtoMapper.toEntity(dto);
        Composante saved = composanteRepository.save(composante);
        return dtoMapper.toDto(saved);
    }

    /**
     * Mettre à jour une composante existante à partir d'un DTO
     */
    public ComposanteDTO update(String acronyme, ComposanteDTO dto) {
        Composante composante = composanteRepository.findById(acronyme)
                .orElseThrow(() -> new RuntimeException("Composante non trouvée: " + acronyme));

        dtoMapper.updateEntity(composante, dto);
        Composante updated = composanteRepository.save(composante);
        return dtoMapper.toDto(updated);
    }

    /**
     * Supprimer une composante
     */
    public void delete(String acronyme) {
        composanteRepository.deleteById(acronyme);
    }

    /**
     * Vérifier si une composante existe
     */
    public boolean exists(String acronyme) {
        return composanteRepository.existsById(acronyme);
    }

    /**
     * Obtenir les campus d'une composante
     */
    public List<CampusDTO> getCampusByComposante(String acronyme) {
        Composante composante = composanteRepository.findById(acronyme)
                .orElseThrow(() -> new RuntimeException("Composante non trouvée: " + acronyme));

        return composante.getCampus().stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }
}

