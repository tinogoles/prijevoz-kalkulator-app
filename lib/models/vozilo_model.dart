class VoziloModel {
  final String id;
  final String naziv;
  final int kapacitet;
  final String kategorijaCestarine; // npr. 'Kombi 8+1', 'Mini bus <20', 'Midi bus 35', 'Veliki autobus 50'
  final bool imaKlimu;
  final bool imaWc;
  final bool imaWifi;
  final bool ima220V;
  final bool imaPunjac;

  VoziloModel({
    required this.id,
    required this.naziv,
    required this.kapacitet,
    required this.kategorijaCestarine,
    required this.imaKlimu,
    required this.imaWc,
    required this.imaWifi,
    required this.ima220V,
    required this.imaPunjac,
  });

  // Pretvaranje u JSON (za spremanje u Firestore ili lokalnu bazu)
  Map<String, dynamic> toJson() => {
        'id': id,
        'naziv': naziv,
        'kapacitet': kapacitet,
        'kategorijaCestarine': kategorijaCestarine,
        'imaKlimu': imaKlimu,
        'imaWc': imaWc,
        'imaWifi': imaWifi,
        'ima220V': ima220V,
        'imaPunjac': imaPunjac,
      };

  // Kreiranje modela iz JSON-a (prilikom čitanja iz baze)
  factory VoziloModel.fromJson(Map<String, dynamic> json) => VoziloModel(
        id: json['id'] ?? '',
        naziv: json['naziv'] ?? '',
        kapacitet: json['kapacitet'] ?? 0,
        kategorijaCestarine: json['kategorijaCestarine'] ?? 'Kombi 8+1',
        imaKlimu: json['imaKlimu'] ?? false,
        imaWc: json['imaWc'] ?? false,
        imaWifi: json['imaWifi'] ?? false,
        ima220V: json['ima220V'] ?? false,
        imaPunjac: json['imaPunjac'] ?? false,
      );

  // Pomoćna metoda za kopiranje i lakše uređivanje
  VoziloModel copyWith({
    String? id,
    String? naziv,
    int? kapacitet,
    String? kategorijaCestarine,
    bool? imaKlimu,
    bool? imaWc,
    bool? imaWifi,
    bool? ima220V,
    bool? imaPunjac,
  }) {
    return VoziloModel(
      id: id ?? this.id,
      naziv: naziv ?? this.naziv,
      kapacitet: kapacitet ?? this.kapacitet,
      kategorijaCestarine: kategorijaCestarine ?? this.kategorijaCestarine,
      imaKlimu: imaKlimu ?? this.imaKlimu,
      imaWc: imaWc ?? this.imaWc,
      imaWifi: imaWifi ?? this.imaWifi,
      ima220V: ima220V ?? this.ima220V,
      imaPunjac: imaPunjac ?? this.imaPunjac,
    );
  }
}
