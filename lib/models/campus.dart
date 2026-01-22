class Campus {
  final String? nomC;
  final String? ville;
  final String? universiteId;

  Campus({
    this.nomC,
    this.ville,
    this.universiteId,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      nomC: json['nomC'],
      ville: json['ville'],
      universiteId: json['universiteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomC': nomC,
      'ville': ville,
      'universiteId': universiteId,
    };
  }
}
