package Ex.service;

import Ex.domain.BatimentRepository;
import Ex.domain.SalleRepository;
import Ex.dto.SalleDTO;
import Ex.modele.Batiment;
import Ex.modele.Salle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service de gestion des salles
 */
@Service
@Transactional
public class SalleService {

    @Autowired
    private SalleRepository salleRepository;

    @Autowired
    private BatimentRepository batimentRepository;

    @Autowired
    private DtoMapper dtoMapper;

    /**
     * Obtenir toutes les salles (DTOs)
     */
    public List<SalleDTO> getAll() {
        return salleRepository.findAll()
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir une salle par son numéro (DTO)
     */
    public Optional<SalleDTO> getById(String numS) {
        return salleRepository.findById(numS)
                .map(dtoMapper::toDto);
    }

    /**
     * Créer une nouvelle salle à partir d'un DTO
     */
    public SalleDTO create(SalleDTO dto) {
        Salle salle = dtoMapper.toEntity(dto);

        // Résoudre le bâtiment
        Batiment batiment = batimentRepository.findById(dto.getBatimentId())
                .orElseThrow(() -> new RuntimeException("Bâtiment non trouvé: " + dto.getBatimentId()));
        salle.setBatiment(batiment);

        Salle saved = salleRepository.save(salle);
        return dtoMapper.toDto(saved);
    }

    /**
     * Mettre à jour une salle existante à partir d'un DTO
     */
    public SalleDTO update(String numS, SalleDTO dto) {
        Salle salle = salleRepository.findById(numS)
                .orElseThrow(() -> new RuntimeException("Salle non trouvée: " + numS));

        dtoMapper.updateEntity(salle, dto);

        // Mettre à jour le bâtiment si changé
        if (dto.getBatimentId() != null && !dto.getBatimentId().equals(salle.getBatiment().getCodeB())) {
            Batiment batiment = batimentRepository.findById(dto.getBatimentId())
                    .orElseThrow(() -> new RuntimeException("Bâtiment non trouvé: " + dto.getBatimentId()));
            salle.setBatiment(batiment);
        }

        Salle updated = salleRepository.save(salle);
        return dtoMapper.toDto(updated);
    }

    /**
     * Supprimer une salle
     */
    public void delete(String numS) {
        salleRepository.deleteById(numS);
    }

    /**
     * Vérifier si une salle existe
     */
    public boolean exists(String numS) {
        return salleRepository.existsById(numS);
    }

    /**
     * Obtenir les salles d'un bâtiment (DTOs)
     */
    public List<SalleDTO> getByBatiment(String codeBatiment) {
        return salleRepository.findSallesByBatimentCode(codeBatiment)
                .stream()
                .map(dtoMapper::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtenir les salles par type (td, tp, amphi, sc, numerique) (DTOs)
     */
    public List<SalleDTO> getByType(String typeS) {
        return salleRepository.findAll().stream()
            .filter(s -> typeS.equals(s.getTypeS()))
            .map(dtoMapper::toDto)
            .collect(Collectors.toList());
    }

    /**
     * Obtenir les salles accessibles PMR (DTOs)
     */
    public List<SalleDTO> getAccessibles() {
        return salleRepository.findAll().stream()
            .filter(s -> "oui".equals(s.getAcces()))
            .map(dtoMapper::toDto)
            .collect(Collectors.toList());
    }

    /**
     * Obtenir les salles par capacité (min et max) (DTOs)
     */
    public List<SalleDTO> getByCapacite(int min, int max) {
        return salleRepository.findAll().stream()
            .filter(s -> s.getCapacite() >= min && s.getCapacite() <= max)
            .map(dtoMapper::toDto)
            .collect(Collectors.toList());
    }
}

