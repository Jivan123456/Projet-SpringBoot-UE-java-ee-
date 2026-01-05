class Batiment {
  final String? codeB;
  final int? anneeC;
  final String? campusId;

  Batiment({
    this.codeB,
    this.anneeC,
    this.campusId,
  });

  factory Batiment.fromJson(Map<String, dynamic> json) {
    return Batiment(
      codeB: json['codeB'],
      anneeC: json['anneeC'],
      campusId: json['campusId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeB': codeB,
      'anneeC': anneeC,
      'campusId': campusId,
    };
  }
}
