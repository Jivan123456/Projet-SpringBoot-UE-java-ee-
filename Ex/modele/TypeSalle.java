package Ex.modele;

public enum TypeSalle {
    AMPHI("Amphithéâtre"),
    SC("Salle de cours"),
    TD("Travaux dirigés"),
    TP("Travaux pratiques"),
    NUMERIQUE("Salle numérique");

    private final String description;


    TypeSalle(String description) {
        this.description = description;
    }


    public String getDescription() {
        return description;
    }

    @Override
    public String toString() {
        return description;
    }
}
