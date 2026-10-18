class KalkulacijaModel {
  String id, nazivKalkulacije, klijentNaziv, datumPolaska, datumPovratka, vozilo, ruta;
  double ukupnaCijena;
  String polaziste, odrediste1, odrediste2, konacnoOdrediste, cestarina, km;
  bool povratno, koristiAutocestu;
  String odabranaAutocesta, tkoPlacaNocenje, cijenaNocenja, marza, cijenaGoriva, dnevnica;

  KalkulacijaModel({
    required this.id, required this.nazivKalkulacije, required this.klijentNaziv, required this.datumPolaska,
    required this.datumPovratka, required this.vozilo, required this.ruta, required this.ukupnaCijena,
    this.polaziste = 'Zagreb', this.odrediste1 = '', this.odrediste2 = '', this.konacnoOdrediste = 'Split',
    this.cestarina = '35.00', this.km = '780', this.povratno = true, this.koristiAutocestu = true,
    this.odabranaAutocesta = 'HAC (Hrvatske autoceste)', this.tkoPlacaNocenje = 'Prijevoznik plaća',
    this.cijenaNocenja = '60', this.marza = '20', this.cijenaGoriva = '1.45', this.dnevnica = '80',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nazivKalkulacije': nazivKalkulacije, 'klijentNaziv': klijentNaziv, 'datumPolaska': datumPolaska,
    'datumPovratka': datumPovratka, 'vozilo': vozilo, 'ruta': ruta, 'ukupnaCijena': ukupnaCijena,
    'polaziste': polaziste, 'odrediste1': odrediste1, 'odrediste2': odrediste2, 'konacnoOdrediste': konacnoOdrediste,
    'cestarina': cestarina, 'km': km, 'povratno': povratno, 'koristiAutocestu': koristiAutocestu,
    'odabranaAutocesta': odabranaAutocesta, 'tkoPlacaNocenje': tkoPlacaNocenje, 'cijenaNocenja': cijenaNocenja,
    'marza': marza, 'cijenaGoriva': cijenaGoriva, 'dnevnica': dnevnica,
  };

  factory KalkulacijaModel.fromJson(Map<String, dynamic> json) => KalkulacijaModel(
    id: json['id'] ?? '', nazivKalkulacije: json['nazivKalkulacije'] ?? '', klijentNaziv: json['klijentNaziv'] ?? '',
    datumPolaska: json['datumPolaska'] ?? '', datumPovratka: json['datumPovratka'] ?? '', vozilo: json['vozilo'] ?? '',
    ruta: json['ruta'] ?? '', ukupnaCijena: json['ukupnaCijena'] ?? 0.0, polaziste: json['polaziste'] ?? 'Zagreb',
    odrediste1: json['odrediste1'] ?? '', odrediste2: json['odrediste2'] ?? '', konacnoOdrediste: json['konacnoOdrediste'] ?? 'Split',
    cestarina: json['cestarina'] ?? '35.00', km: json['km'] ?? '780', povratno: json['povratno'] ?? true,
    koristiAutocestu: json['koristiAutocestu'] ?? true, odabranaAutocesta: json['odabranaAutocesta'] ?? 'HAC (Hrvatske autoceste)',
    tkoPlacaNocenje: json['tkoPlacaNocenje'] ?? 'Prijevoznik plaća', cijenaNocenja: json['cijenaNocenja'] ?? '60',
    marza: json['marza'] ?? '20', cijenaGoriva: json['cijenaGoriva'] ?? '1.45', dnevnica: json['dnevnica'] ?? '80',
  );
}
