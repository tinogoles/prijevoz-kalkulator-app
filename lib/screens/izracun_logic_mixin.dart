import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kalkulacija_model.dart';
import '../models/klijent_model.dart';
import '../services/cestarine_service.dart';
import '../services/klijenti_service.dart';

mixin IzracunLogicMixin<T extends StatefulWidget> on State<T> {
  bool isLoadingRoute = false;
  final KlijentiService klijentiService = KlijentiService();
  final CestarineService cestarineService = CestarineService();

  List<Map<String, dynamic>> dostupnaVozila = [];
  Map<String, dynamic>? odabranoVoziloMap;

  Map<String, double>? polazisteCoords;
  Map<String, double>? konacnoOdredisteCoords;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  final TextEditingController nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta');
  late TextEditingController datumPolaskaController;
  late TextEditingController datumPovratkaController;

  final TextEditingController polazisteController = TextEditingController(text: 'Split');
  final TextEditingController odrediste1Controller = TextEditingController();
  final TextEditingController odrediste2Controller = TextEditingController();
  final TextEditingController konacnoOdredisteController = TextEditingController(text: 'Krapina');

  final TextEditingController kmController = TextEditingController(text: '780');
  final TextEditingController cestarinaController = TextEditingController(text: '0.00');

  final TextEditingController cijenaGorivaController = TextEditingController(text: '1.96');
  final TextEditingController dnevnicaController = TextEditingController(text: '100');
  final TextEditingController cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController marzaController = TextEditingController(text: '20');

  bool koristiAutocestu = true;
  List<String> gradoviNaRuti = [];
  List<Map<String, dynamic>> dioniceAutocesta = [];

  int izracunatiBrojDana = 1;
  double bazaKmJednosmjerno = 390.0;
  bool povratnoPutovanje = true;

  String tkoPlacaNocenje = 'Bez noćenja';
  final List<String> opcijeNocenja = [
    'Bez noćenja',
    'Prijevoznik plaća',
    'Klijent/Agencija plaća (0€ za nas)',
  ];

  String? trenutniIdUredjivanja;

  String formatirajDatum(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  void inicijalizirajLogiku({KalkulacijaModel? kalkulacijaZaUredivanje}) {
    klijentiService.addListener(onKlijentiPromijenjeni);
    klijentiService.ucitajKlijente();
    dohvatiVozilaIzBaze(kalkulacijaZaUredivanje);

    String danas = formatirajDatum(DateTime.now());
    datumPolaskaController = TextEditingController(text: danas);
    datumPovratkaController = TextEditingController(text: danas);

    if (kalkulacijaZaUredivanje != null) {
      popuniPodatkeZaUredivanje(kalkulacijaZaUredivanje);
    } else {
      preracunajBrojDana();
    }
  }

  void disposeLogika() {
    klijentiService.removeListener(onKlijentiPromijenjeni);
    nazivKalkulacijeController.dispose();
    polazisteController.dispose();
    odrediste1Controller.dispose();
    odrediste2Controller.dispose();
    konacnoOdredisteController.dispose();
    datumPolaskaController.dispose();
    datumPovratkaController.dispose();
    kmController.dispose();
    cestarinaController.dispose();
    cijenaGorivaController.dispose();
    dnevnicaController.dispose();
    cijenaNocenjaController.dispose();
    marzaController.dispose();
  }

  void onKlijentiPromijenjeni() {
    if (mounted) setState(() {});
  }

  void dohvatiVozilaIzBaze(KalkulacijaModel? kalkulacijaZaUredivanje) {
    if (userId.isEmpty) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('vozni_park')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          dostupnaVozila = snapshot.docs.map((d) {
            var data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();

          if (kalkulacijaZaUredivanje != null && kalkulacijaZaUredivanje.vozilo.isNotEmpty) {
            final sklVozilo = kalkulacijaZaUredivanje.vozilo.toLowerCase();
            odabranoVoziloMap = dostupnaVozila.firstWhere(
              (v) => sklVozilo.contains(v['naziv'].toString().toLowerCase()),
              orElse: () => dostupnaVozila.isNotEmpty ? dostupnaVozila.first : {},
            );
            if (odabranoVoziloMap != null && odabranoVoziloMap!.isEmpty) {
              odabranoVoziloMap = null;
            }
          }

          if (odabranoVoziloMap == null && dostupnaVozila.isNotEmpty) {
            odabranoVoziloMap = dostupnaVozila.first;
          }
        });
      }
    });
  }

  void popuniPodatkeZaUredivanje(KalkulacijaModel k) {
    setState(() {
      trenutniIdUredjivanja = k.id;
      nazivKalkulacijeController.text = k.nazivKalkulacije;
      polazisteController.text = k.polaziste.isNotEmpty ? k.polaziste : 'Split';
      odrediste1Controller.text = k.odrediste1;
      odrediste2Controller.text = k.odrediste2;
      konacnoOdredisteController.text = k.konacnoOdrediste.isNotEmpty ? k.konacnoOdrediste : 'Krapina';
      datumPolaskaController.text = k.datumPolaska;
      datumPovratkaController.text = k.datumPovratka;

      polazisteCoords = null;
      konacnoOdredisteCoords = null;

      String kmVal = k.km;
      if (kmVal == '0' || kmVal.isEmpty) {
        RegExp reg = RegExp(r'\((\d+)\s*km\)');
        var match = reg.firstMatch(k.ruta);
        kmVal = match?.group(1) ?? '780';
      }
      kmController.text = kmVal;
      cestarinaController.text = k.cestarina.isNotEmpty ? k.cestarina : '0.00';

      povratnoPutovanje = k.povratno;
      koristiAutocestu = k.koristiAutocestu;
      tkoPlacaNocenje = k.tkoPlacaNocenje.isNotEmpty ? k.tkoPlacaNocenje : 'Bez noćenja';
      cijenaNocenjaController.text = k.cijenaNocenja.isNotEmpty ? k.cijenaNocenja : '60';
      marzaController.text = k.marza.isNotEmpty ? k.marza : '20';
      cijenaGorivaController.text = k.cijenaGoriva.isNotEmpty ? k.cijenaGoriva : '1.96';
      dnevnicaController.text = k.dnevnica.isNotEmpty ? k.dnevnica : '100';

      if (dostupnaVozila.isNotEmpty && k.vozilo.isNotEmpty) {
        final sklVozilo = k.vozilo.toLowerCase();
        odabranoVoziloMap = dostupnaVozila.firstWhere(
          (v) => sklVozilo.contains(v['naziv'].toString().toLowerCase()),
          orElse: () => dostupnaVozila.first,
        );
      }
    });
    preracunajBrojDana();
  }

  void preracunajBrojDana() {
    try {
      String d1Str = datumPolaskaController.text.replaceAll('.', '').trim();
      String d2Str = datumPovratkaController.text.replaceAll('.', '').trim();
      if (d1Str.length >= 8 && d2Str.length >= 8) {
        DateTime d1 = DateTime(
          int.parse(d1Str.substring(4, 8)),
          int.parse(d1Str.substring(2, 4)),
          int.parse(d1Str.substring(0, 2)),
        );
        DateTime d2 = DateTime(
          int.parse(d2Str.substring(4, 8)),
          int.parse(d2Str.substring(2, 4)),
          int.parse(d2Str.substring(0, 2)),
        );
        int razlika = d2.difference(d1).inDays + 1;
        setState(() => izracunatiBrojDana = razlika > 0 ? razlika : 1);
      }
    } catch (_) {}
  }

  String skratiNazivLokacije(String puniNaziv) {
    List<String> dijelovi = puniNaziv.split(',');
    if (dijelovi.isEmpty) return puniNaziv;
    if (dijelovi.length == 1) return dijelovi[0].trim();
    String prvo = dijelovi[0].trim();
    String drugo = dijelovi[1].replaceAll('Grad ', '').trim();
    return '$prvo, $drugo';
  }

  Future<List<Map<String, dynamic>>> dohvatiPrijedlogeLokacija(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'PrijevozKalkulatorApp'});
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          return {
            'display_name': skratiNazivLokacije(item['display_name'] ?? ''),
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          };
        }).toList();
      }
    } catch (e) {
      print('Greška pri dohvatu prijedloga: $e');
    }
    return [];
  }

  Future<void> izracunajRutuIKilometre(BuildContext context) async {
    List<String> tocke = [];
    if (polazisteController.text.trim().isNotEmpty) tocke.add(polazisteController.text.trim());
    if (odrediste1Controller.text.trim().isNotEmpty) tocke.add(odrediste1Controller.text.trim());
    if (odrediste2Controller.text.trim().isNotEmpty) tocke.add(odrediste2Controller.text.trim());
    if (konacnoOdredisteController.text.trim().isNotEmpty) tocke.add(konacnoOdredisteController.text.trim());

    if (tocke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite barem polazište i konačno odredište.')),
      );
      return;
    }

    setState(() => isLoadingRoute = true);

    try {
      Future<Map<String, double>?> getCoords(String q, {Map<String, double>? predefinisaneKoordinate}) async {
        if (predefinisaneKoordinate != null) return predefinisaneKoordinate;
        String upit = q.trim();
        if (!upit.toLowerCase().contains('hrvatska')) {
          upit = '$upit, Hrvatska';
        }
        final res = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(upit)}&format=json&limit=1'),
          headers: {'User-Agent': 'PrijevozKalkulatorApp'},
        );
        if (res.statusCode == 200) {
          List data = json.decode(res.body);
          if (data.isNotEmpty) {
            return {'lat': double.parse(data[0]['lat']), 'lon': double.parse(data[0]['lon'])};
          }
        }
        return null;
      }

      List<Map<String, double>> koordinate = [];
      var cPolaziste = await getCoords(polazisteController.text, predefinisaneKoordinate: polazisteCoords);
      if (cPolaziste != null) koordinate.add(cPolaziste);
      else throw Exception('Lokacija "${polazisteController.text}" nije pronađena.');

      if (odrediste1Controller.text.trim().isNotEmpty) {
        var c1 = await getCoords(odrediste1Controller.text);
        if (c1 != null) koordinate.add(c1);
      }
      if (odrediste2Controller.text.trim().isNotEmpty) {
        var c2 = await getCoords(odrediste2Controller.text);
        if (c2 != null) koordinate.add(c2);
      }

      var cKonacno = await getCoords(konacnoOdredisteController.text, predefinisaneKoordinate: konacnoOdredisteCoords);
      if (cKonacno != null) koordinate.add(cKonacno);
      else throw Exception('Lokacija "${konacnoOdredisteController.text}" nije pronađena.');

      double ukupnoMetara = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        String urlRute = 'https://router.project-osrm.org/route/v1/driving/${koordinate[i]['lon']},${koordinate[i]['lat']};${koordinate[i + 1]['lon']},${koordinate[i + 1]['lat']}?overview=false';
        final res = await http.get(Uri.parse(urlRute));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          if (data['code'] == 'Ok') {
            ukupnoMetara += data['routes'][0]['distance'];
          }
        }
      }

      double kmJedan = ukupnoMetara / 1000.0;
      setState(() {
        bazaKmJednosmjerno = kmJedan;
        kmController.text = (bazaKmJednosmjerno * (povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
        gradoviNaRuti = tocke;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Izračunato: ${kmJedan.toStringAsFixed(1)} km'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri izračunu rute: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoadingRoute = false);
    }
  }

  void preracunajCestarinuSOmogucenimDionicama() {
    double suma = 0.0;
    for (var d in dioniceAutocesta) {
      if (d['ukljuceno'] == true) {
        suma += (d['cijena'] as num).toDouble();
      }
    }
    double cestarinaUkupno = suma * (povratnoPutovanje ? 2.0 : 1.0);
    setState(() {
      cestarinaController.text = cestarinaUkupno.toStringAsFixed(2);
    });
  }

  KalkulacijaModel generirajModelKalkulacije(KlijentModel? aktivniKlijent) {
    preracunajBrojDana();
    double km = double.tryParse(kmController.text) ?? 0;
    double cestarinaBruto = double.tryParse(cestarinaController.text) ?? 0;
    double gorivoBruto = double.tryParse(cijenaGorivaController.text) ?? 1.96;
    double dnevnica = double.tryParse(dnevnicaController.text) ?? 100;
    double nocenjeBruto = double.tryParse(cijenaNocenjaController.text) ?? 60;
    double marza = double.tryParse(marzaController.text) ?? 20;

    double potrosnja = 35.0;
    if (odabranoVoziloMap != null && odabranoVoziloMap!['potrosnja'] != null) {
      potrosnja = double.tryParse(odabranoVoziloMap!['potrosnja'].toString()) ?? 35.0;
    }

    int brojNocenja = (izracunatiBrojDana > 1) ? (izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double cestarinaNeto = (koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnica * izracunatiBrojDana;
    double nocenjeNeto = (tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marza / 100);
    double osnovicaSMarzom = cistiTrosak + zarada;
    double ukupnaCijena = osnovicaSMarzom * 1.25;

    String nazivVozilaPrikaz = odabranoVoziloMap != null
        ? '${odabranoVoziloMap!['naziv']} (${odabranoVoziloMap!['kapacitet']})'
        : 'Vozilo';

    return KalkulacijaModel(
      id: trenutniIdUredjivanja ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: nazivKalkulacijeController.text,
      klijentNaziv: aktivniKlijent?.naziv ?? 'Klijent',
      klijentUSustavuPdv: aktivniKlijent?.uSustavuPdv ?? false,
      datumPolaska: datumPolaskaController.text,
      datumPovratka: datumPovratkaController.text,
      vozilo: nazivVozilaPrikaz,
      ruta: '${polazisteController.text} -> ${konacnoOdredisteController.text} (${kmController.text} km)',
      ukupnaCijena: ukupnaCijena,
      polaziste: polazisteController.text,
      odrediste1: odrediste1Controller.text,
      odrediste2: odrediste2Controller.text,
      konacnoOdrediste: konacnoOdredisteController.text,
      cestarina: cestarinaController.text,
      km: kmController.text,
      povratno: povratnoPutovanje,
      koristiAutocestu: koristiAutocestu,
      odabranaAutocesta: 'HAC / AZM Automatski izračun',
      tkoPlacaNocenje: tkoPlacaNocenje,
      cijenaNocenja: cijenaNocenjaController.text,
      marza: marzaController.text,
      cijenaGoriva: cijenaGorivaController.text,
      dnevnica: dnevnicaController.text,
    );
  }
}
