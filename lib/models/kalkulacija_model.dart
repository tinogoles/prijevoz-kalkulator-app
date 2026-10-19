// lib/models/kalkulacija_model.dart
class KalkulacijaModel {
  final String id;
  final String nazivKalkulacije;
  final String klijentNaziv;
  final String datumPolaska;
  final String datumPovratka;
  final String vozilo;
  final String ruta;
  final double ukupnaCijena;
  final String polaziste;
  final String odrediste1;
  final String odrediste2;
  final String konacnoOdrediste;
  final String cestarina;
  final String km;
  final bool povratno;
  final bool koristiAutocestu;
  final String odabranaAutocesta;
  final String tkoPlacaNocenje;
  final String cijenaNocenja;
  final String marza;
  final String cijenaGoriva;
  final String dnevnica;

  KalkulacijaModel({
    required this.id,
    required this.nazivKalkulacije,
    required this.klijentNaziv,
    required this.datumPolaska,
    required this.datumPovratka,
    required this.vozilo,
    required this.ruta,
    required this.ukupnaCijena,
    this.polaziste = '',
    this.odrediste1 = '',
    this.odrediste2 = '',
    this.konacnoOdrediste = '',
    this.cestarina = '0',
    this.km = '0',
    this.povratno = true,
    this.koristiAutocestu = true,
    this.odabranaAutocesta = '',
    this.tkoPlacaNocenje = '',
    this.cijenaNocenja = '60',
    this.marza = '20',
    this.cijenaGoriva = '1.96',
    this.dnevnica = '100',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nazivKalkulacije': nazivKalkulacije,
    'klijentNaziv': klijentNaziv,
    'datumPolaska': datumPolaska,
    'datumPovratka': datumPovratka,
    'vozilo': vozilo,
    'ruta': ruta,
    'ukupnaCijena': ukupnaCijena,
    'polaziste': polaziste,
    'odrediste1': odrediste1,
    'odrediste2': odrediste2,
    'konacnoOdrediste': konacnoOdrediste,
    'cestarina': cestarina,
    'km': km,
    'povratno': povratno,
    'koristiAutocestu': koristiAutocestu,
    'odabranaAutocesta': odabranaAutocesta,
    'tkoPlacaNocenje': tkoPlacaNocenje,
    'cijenaNocenja': cijenaNocenja,
    'marza': marza,
    'cijenaGoriva': cijenaGoriva,
    'dnevnica': dnevnica,
  };

  factory KalkulacijaModel.fromJson(Map<String, dynamic> json) {
    // Fleksibilno čitanje polja kilometara bez obzira na naziv u bazi
    String procitaniKm = (json['km'] ?? json['kilometri'] ?? json['brojKm'] ?? '0').toString();
    if (procitaniKm == '0' || procitaniKm.isEmpty) {
      // Ako nedostaje km, pokušaj ga ekstrahirati iz rute e.g. "Split -> Zagreb (780 km)"
      String r = json['ruta']?.toString() ?? '';
      RegExp reg = RegExp(r'\((\d+)\s*km\)');
      var match = reg.firstMatch(r);
      if (match != null) procitaniKm = match.group(1) ?? '0';
    }

    return KalkulacijaModel(
      id: json['id']?.toString() ?? '',
      nazivKalkulacije: json['nazivKalkulacije']?.toString() ?? json['naziv']?.toString() ?? '',
      klijentNaziv: json['klijentNaziv']?.toString() ?? json['klijent']?.toString() ?? '',
      datumPolaska: json['datumPolaska']?.toString() ?? '',
      datumPovratka: json['datumPovratka']?.toString() ?? '',
      vozilo: json['vozilo']?.toString() ?? '',
      ruta: json['ruta']?.toString() ?? '',
      ukupnaCijena: (json['ukupnaCijena'] as num?)?.toDouble() ?? (json['cijena'] as num?)?.toDouble() ?? 0.0,
      polaziste: json['polaziste']?.toString() ?? '',
      odrediste1: json['odrediste1']?.toString() ?? '',
      odrediste2: json['odrediste2']?.toString() ?? '',
      konacnoOdrediste: json['konacnoOdrediste']?.toString() ?? '',
      cestarina: (json['cestarina'] ?? json['iznosCestarine'] ?? '0').toString(),
      km: procitaniKm,
      povratno: json['povratno'] ?? true,
      koristiAutocestu: json['koristiAutocestu'] ?? true,
      odabranaAutocesta: json['odabranaAutocesta']?.toString() ?? '',
      tkoPlacaNocenje: json['tkoPlacaNocenje']?.toString() ?? '',
      cijenaNocenja: (json['cijenaNocenja'] ?? '60').toString(),
      marza: (json['marza'] ?? '20').toString(),
      cijenaGoriva: (json['cijenaGoriva'] ?? '1.96').toString(),
      dnevnica: (json['dnevnica'] ?? '100').toString(),
    );
  }
}
