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
    required this.polaziste,
    required this.odrediste1,
    required this.odrediste2,
    required this.konacnoOdrediste,
    required this.cestarina,
    required this.km,
    required this.povratno,
    required this.koristiAutocestu,
    required this.odabranaAutocesta,
    required this.tkoPlacaNocenje,
    required this.cijenaNocenja,
    required this.marza,
    required this.cijenaGoriva,
    required this.dnevnica,
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

  factory KalkulacijaModel.fromJson(Map<String, dynamic> json) => KalkulacijaModel(
    id: json['id'] ?? '',
    nazivKalkulacije: json['nazivKalkulacije'] ?? '',
    klijentNaziv: json['klijentNaziv'] ?? '',
    datumPolaska: json['datumPolaska'] ?? '',
    datumPovratka: json['datumPovratka'] ?? '',
    vozilo: json['vozilo'] ?? '',
    ruta: json['ruta'] ?? '',
    ukupnaCijena: (json['ukupnaCijena'] as num?)?.toDouble() ?? 0.0,
    polaziste: json['polaziste'] ?? '',
    odrediste1: json['odrediste1'] ?? '',
    odrediste2: json['odrediste2'] ?? '',
    konacnoOdrediste: json['konacnoOdrediste'] ?? '',
    cestarina: json['cestarina']?.toString() ?? '0',
    km: json['km']?.toString() ?? '0',
    povratno: json['povratno'] ?? true,
    koristiAutocestu: json['koristiAutocestu'] ?? true,
    odabranaAutocesta: json['odabranaAutocesta'] ?? '',
    tkoPlacaNocenje: json['tkoPlacaNocenje'] ?? '',
    cijenaNocenja: json['cijenaNocenja']?.toString() ?? '0',
    marza: json['marza']?.toString() ?? '20',
    cijenaGoriva: json['cijenaGoriva']?.toString() ?? '1.96',
    dnevnica: json['dnevnica']?.toString() ?? '100',
  );
}
