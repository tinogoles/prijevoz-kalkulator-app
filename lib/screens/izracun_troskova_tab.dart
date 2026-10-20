// lib/screens/izracun_troskova_tab.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import '../services/cestarine_service.dart';
import '../services/klijenti_service.dart';

class IzracunTroskovaTab extends StatefulWidget {
  final PrijevoznikModel prijevoznik;
  final KlijentModel? aktivniKlijent;
  final KalkulacijaModel? kalkulacijaZaUredivanje;
  final ValueChanged<KlijentModel?> onKlijentChanged;
  final ValueChanged<KalkulacijaModel> onSpremiKalkulaciju;

  const IzracunTroskovaTab({
    super.key,
    required this.prijevoznik,
    required this.aktivniKlijent,
    required this.kalkulacijaZaUredivanje,
    required this.onKlijentChanged,
    required this.onSpremiKalkulaciju,
  });

  @override
  State<IzracunTroskovaTab> createState() => _IzracunTroskovaTabState();
}

class _IzracunTroskovaTabState extends State<IzracunTroskovaTab> {
  bool _isLoadingRoute = false;
  final KlijentiService _klijentiService = KlijentiService();
  final CestarineService _cestarineService = CestarineService();

  List<Map<String, dynamic>> _dostupnaVozila = [];
  Map<String, dynamic>? _odabranoVoziloMap;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Controllers
  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta');
  late TextEditingController _datumPolaskaController;
  late TextEditingController _datumPovratkaController;

  final TextEditingController _polazisteController = TextEditingController(text: 'Split');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Zagreb');

  final TextEditingController _kmController = TextEditingController(text: '780');
  final TextEditingController _cestarinaController = TextEditingController(text: '0.00');

  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.96');
  final TextEditingController _dnevnicaController = TextEditingController(text: '100');
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '20');

  // Autocesta status
  bool _koristiAutocestu = true;
  bool _koristiAutoput1 = true;
  bool _koristiAutoput2 = true;
  bool _koristiAutoput3 = true;

  // Dinamički podaci izračuna rute
  List<String> _gradoviNaRuti = [];
  List<Map<String, dynamic>> _dioniceAutocesta = []; // [{naziv: 'A1 Lucko - Dugopolje', cijena: 24.0, ukljuceno: true}]

  int _izracunatiBrojDana = 1;
  double _bazaKmJednosmjerno = 390.0;
  bool _povratnoPutovanje = true;

  String _tkoPlacaNocenje = 'Bez noćenja';
  final List<String> _opcijeNocenja = [
    'Bez noćenja',
    'Prijevoznik plaća',
    'Klijent/Agencija plaća (0€ za nas)',
  ];

  String? _trenutniIdUredjivanja;

  String _formatirajDatum(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  @override
  void initState() {
    super.initState();
    _klijentiService.addListener(_onKlijentiPromijenjeni);
    _klijentiService.ucitajKlijente();

    _dohvatiVozilaIzBaze();
    String danas = _formatirajDatum(DateTime.now());
    _datumPolaskaController = TextEditingController(text: danas);
    _datumPovratkaController = TextEditingController(text: danas);

    if (widget.kalkulacijaZaUredivanje != null) {
      _popuniPodatkeZaUredivanje(widget.kalkulacijaZaUredivanje!);
    } else {
      _preracunajBrojDana();
    }
  }

  void _onKlijentiPromijenjeni() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _klijentiService.removeListener(_onKlijentiPromijenjeni);
    _nazivKalkulacijeController.dispose();
    _polazisteController.dispose();
    _odrediste1Controller.dispose();
    _odrediste2Controller.dispose();
    _konacnoOdredisteController.dispose();
    _datumPolaskaController.dispose();
    _datumPovratkaController.dispose();
    _kmController.dispose();
    _cestarinaController.dispose();
    _cijenaGorivaController.dispose();
    _dnevnicaController.dispose();
    _cijenaNocenjaController.dispose();
    _marzaController.dispose();
    super.dispose();
  }

  void _dohvatiVozilaIzBaze() {
    if (_userId.isEmpty) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('vozni_park')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _dostupnaVozila = snapshot.docs.map((d) {
            var data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();

          if (widget.kalkulacijaZaUredivanje != null && widget.kalkulacijaZaUredivanje!.vozilo.isNotEmpty) {
            final sklVozilo = widget.kalkulacijaZaUredivanje!.vozilo.toLowerCase();
            _odabranoVoziloMap = _dostupnaVozila.firstWhere(
              (v) => sklVozilo.contains(v['naziv'].toString().toLowerCase()),
              orElse: () => _dostupnaVozila.isNotEmpty ? _dostupnaVozila.first : {},
            );
            if (_odabranoVoziloMap != null && _odabranoVoziloMap!.isEmpty) {
              _odabranoVoziloMap = null;
            }
          }

          if (_odabranoVoziloMap == null && _dostupnaVozila.isNotEmpty) {
            _odabranoVoziloMap = _dostupnaVozila.first;
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant IzracunTroskovaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kalkulacijaZaUredivanje != oldWidget.kalkulacijaZaUredivanje &&
        widget.kalkulacijaZaUredivanje != null) {
      _popuniPodatkeZaUredivanje(widget.kalkulacijaZaUredivanje!);
    }
  }

  void _popuniPodatkeZaUredivanje(KalkulacijaModel k) {
    setState(() {
      _trenutniIdUredjivanja = k.id;
      _nazivKalkulacijeController.text = k.nazivKalkulacije;
      _polazisteController.text = k.polaziste.isNotEmpty ? k.polaziste : 'Split';
      _odrediste1Controller.text = k.odrediste1;
      _odrediste2Controller.text = k.odrediste2;
      _konacnoOdredisteController.text = k.konacnoOdrediste.isNotEmpty ? k.konacnoOdrediste : 'Zagreb';
      _datumPolaskaController.text = k.datumPolaska;
      _datumPovratkaController.text = k.datumPovratka;

      String kmVal = k.km;
      if (kmVal == '0' || kmVal.isEmpty) {
        RegExp reg = RegExp(r'\((\d+)\s*km\)');
        var match = reg.firstMatch(k.ruta);
        kmVal = match?.group(1) ?? '780';
      }
      _kmController.text = kmVal;
      _cestarinaController.text = k.cestarina.isNotEmpty ? k.cestarina : '0.00';

      _povratnoPutovanje = k.povratno;
      _koristiAutocestu = k.koristiAutocestu;
      _tkoPlacaNocenje = k.tkoPlacaNocenje.isNotEmpty ? k.tkoPlacaNocenje : 'Bez noćenja';
      _cijenaNocenjaController.text = k.cijenaNocenja.isNotEmpty ? k.cijenaNocenja : '60';
      _marzaController.text = k.marza.isNotEmpty ? k.marza : '20';
      _cijenaGorivaController.text = k.cijenaGoriva.isNotEmpty ? k.cijenaGoriva : '1.96';
      _dnevnicaController.text = k.dnevnica.isNotEmpty ? k.dnevnica : '100';

      if (_dostupnaVozila.isNotEmpty && k.vozilo.isNotEmpty) {
        final sklVozilo = k.vozilo.toLowerCase();
        _odabranoVoziloMap = _dostupnaVozila.firstWhere(
          (v) => sklVozilo.contains(v['naziv'].toString().toLowerCase()),
          orElse: () => _dostupnaVozila.first,
        );
      }
    });
    _preracunajBrojDana();
  }

  Future<void> _odaberiDatumPolaska(BuildContext context) async {
    final DateTime? odabir = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (odabir != null) {
      setState(() {
        String noviDatum = _formatirajDatum(odabir);
        _datumPolaskaController.text = noviDatum;
        _datumPovratkaController.text = noviDatum;
        _preracunajBrojDana();
      });
    }
  }

  Future<void> _odaberiDatumPovratka(BuildContext context) async {
    DateTime pocetniDatum = DateTime.now();
    try {
      String d1Str = _datumPolaskaController.text.replaceAll('.', '').trim();
      if (d1Str.length >= 8) {
        pocetniDatum = DateTime(
          int.parse(d1Str.substring(4, 8)),
          int.parse(d1Str.substring(2, 4)),
          int.parse(d1Str.substring(0, 2)),
        );
      }
    } catch (_) {}

    final DateTime? odabir = await showDatePicker(
      context: context,
      initialDate: pocetniDatum,
      firstDate: pocetniDatum,
      lastDate: DateTime(2035),
    );
    if (odabir != null) {
      setState(() {
        _datumPovratkaController.text = _formatirajDatum(odabir);
        _preracunajBrojDana();
      });
    }
  }

  void _preracunajBrojDana() {
    try {
      String d1Str = _datumPolaskaController.text.replaceAll('.', '').trim();
      String d2Str = _datumPovratkaController.text.replaceAll('.', '').trim();
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
        setState(() => _izracunatiBrojDana = razlika > 0 ? razlika : 1);
      }
    } catch (_) {}
  }

  Future<void> _izracunajRutuIKilometre() async {
    List<String> tocke = [];
    if (_polazisteController.text.trim().isNotEmpty) tocke.add(_polazisteController.text.trim());
    if (_odrediste1Controller.text.trim().isNotEmpty) tocke.add(_odrediste1Controller.text.trim());
    if (_odrediste2Controller.text.trim().isNotEmpty) tocke.add(_odrediste2Controller.text.trim());
    if (_konacnoOdredisteController.text.trim().isNotEmpty) tocke.add(_konacnoOdredisteController.text.trim());

    if (tocke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite barem polazište i konačno odredište.')),
      );
      return;
    }

    setState(() => _isLoadingRoute = true);

    try {
      Future<Map<String, double>?> getCoords(String q) async {
        final res = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=1'),
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
      for (String t in tocke) {
        var c = await getCoords(t);
        if (c != null) {
          koordinate.add(c);
        } else {
          throw Exception('Lokacija "$t" nije pronađena.');
        }
      }

      double ukupnoMetara = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        final res = await http.get(Uri.parse(
            'https://router.project-osrm.org/route/v1/driving/${koordinate[i]['lon']},${koordinate[i]['lat']};${koordinate[i + 1]['lon']},${koordinate[i + 1]['lat']}?overview=false'));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          if (data['code'] == 'Ok') {
            ukupnoMetara += data['routes'][0]['distance'];
          }
        }
      }

      double kmJedan = ukupnoMetara / 1000.0;

      // Generiranje dinamičkih gradova na ruti (Točka 8)
      List<String> dinamickiGradovi = List.from(tocke);

      // Dinamički obračun dionica autocesta (Točke 10, 11, 12)
      List<Map<String, dynamic>> dionice = [];
      double ukupnaCestarinaSveDionice = 0.0;

      if (_koristiAutocestu) {
        String katVozila = _odabranoVoziloMap?['kategorija'] ??
            _odabranoVoziloMap?['kategorijaCestarine'] ??
            'Veliki autobus 50';

        double izracunataCestarina = await _cestarineService.izracunajUkupnuCestarinu(
          polaziste: _polazisteController.text,
          odrediste: _konacnoOdredisteController.text,
          medustajaliste: _odrediste1Controller.text.isNotEmpty ? _odrediste1Controller.text : null,
          kategorijaVozila: katVozila,
        );

        // Dinamička raspodjela po dionicama ako postoje višekoncesijski putevi
        dionice.add({
          'naziv': 'Autoput 1 (HAC / Primarna dionica)',
          'opis': '${_polazisteController.text} -> ${_konacnoOdredisteController.text}',
          'cijena': izracunataCestarina,
          'ukljuceno': _koristiAutoput1,
        });

        if (_koristiAutoput1) ukupnaCestarinaSveDionice += izracunataCestarina;
      }

      setState(() {
        _bazaKmJednosmjerno = kmJedan;
        _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
        _gradoviNaRuti = dinamickiGradovi;
        _dioniceAutocesta = dionice;

        double cestarinaUkupno = ukupnaCestarinaSveDionice * (_povratnoPutovanje ? 2.0 : 1.0);
        _cestarinaController.text = cestarinaUkupno.toStringAsFixed(2);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Izračunato: ${kmJedan.toStringAsFixed(1)} km, Cestarina: ${_cestarinaController.text} €'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri izračunu rute: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _preracunajCestarinuSOmogucenimDionicama() {
    double suma = 0.0;
    for (var d in _dioniceAutocesta) {
      if (d['ukljuceno'] == true) {
        suma += (d['cijena'] as num).toDouble();
      }
    }
    double cestarinaUkupno = suma * (_povratnoPutovanje ? 2.0 : 1.0);
    setState(() {
      _cestarinaController.text = cestarinaUkupno.toStringAsFixed(2);
    });
  }

  void _spremi() {
    _preracunajBrojDana();
    double km = double.tryParse(_kmController.text) ?? 0;
    double cestarinaBruto = double.tryParse(_cestarinaController.text) ?? 0;
    double gorivoBruto = double.tryParse(_cijenaGorivaController.text) ?? 1.96;
    double dnevnica = double.tryParse(_dnevnicaController.text) ?? 100;
    double nocenjeBruto = double.tryParse(_cijenaNocenjaController.text) ?? 60;
    double marza = double.tryParse(_marzaController.text) ?? 20;

    double potrosnja = 35.0;
    if (_odabranoVoziloMap != null && _odabranoVoziloMap!['potrosnja'] != null) {
      potrosnja = double.tryParse(_odabranoVoziloMap!['potrosnja'].toString()) ?? 35.0;
    }

    int brojNocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double cestarinaNeto = (_koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnica * _izracunatiBrojDana;
    double nocenjeNeto = (_tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marza / 100);
    double osnovicaSMarzom = cistiTrosak + zarada;
    double ukupnaCijena = osnovicaSMarzom * 1.25;

    String nazivVozilaPrikaz = _odabranoVoziloMap != null
        ? '${_odabranoVoziloMap!['naziv']} (${_odabranoVoziloMap!['kapacitet']})'
        : 'Vozilo';

    bool klijentPdvStatus = widget.aktivniKlijent?.uSustavuPdv ?? false;

    KalkulacijaModel kalk = KalkulacijaModel(
      id: _trenutniIdUredjivanja ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: _nazivKalkulacijeController.text,
      klijentNaziv: widget.aktivniKlijent?.naziv ?? 'Klijent',
      klijentUSustavuPdv: klijentPdvStatus,
      datumPolaska: _datumPolaskaController.text,
      datumPovratka: _datumPovratkaController.text,
      vozilo: nazivVozilaPrikaz,
      ruta: '${_polazisteController.text} -> ${_konacnoOdredisteController.text} (${_kmController.text} km)',
      ukupnaCijena: ukupnaCijena,
      polaziste: _polazisteController.text,
      odrediste1: _odrediste1Controller.text,
      odrediste2: _odrediste2Controller.text,
      konacnoOdrediste: _konacnoOdredisteController.text,
      cestarina: _cestarinaController.text,
      km: _kmController.text,
      povratno: _povratnoPutovanje,
      koristiAutocestu: _koristiAutocestu,
      odabranaAutocesta: 'HAC / Automatski izračun',
      tkoPlacaNocenje: _tkoPlacaNocenje,
      cijenaNocenja: _cijenaNocenjaController.text,
      marza: _marzaController.text,
      cijenaGoriva: _cijenaGorivaController.text,
      dnevnica: _dnevnicaController.text,
    );
    widget.onSpremiKalkulaciju(kalk);
    setState(() => _trenutniIdUredjivanja = null);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> listaKlijenata = _klijentiService.klijenti;

    String? aktivniKlijentId;
    if (widget.aktivniKlijent != null) {
      for (var kMap in listaKlijenata) {
        if ((kMap['id'] ?? '').toString() == widget.aktivniKlijent!.id ||
            (kMap['naziv'] ?? '').toString().trim().toLowerCase() == widget.aktivniKlijent!.naziv.trim().toLowerCase()) {
          aktivniKlijentId = kMap['id']?.toString() ?? '';
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _trenutniIdUredjivanja == null ? 'Izračun Troškova Prijevoza' : 'Uređivanje Kalkulacije',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) KLIJENT
            DropdownButtonFormField<String>(
              value: aktivniKlijentId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '1) Klijent', border: OutlineInputBorder()),
              items: listaKlijenata.map((kMap) {
                return DropdownMenuItem<String>(
                  value: kMap['id']?.toString() ?? '',
                  child: Text(kMap['naziv']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (idKlijenta) {
                if (idKlijenta != null && idKlijenta.isNotEmpty) {
                  var kMap = listaKlijenata.firstWhere((k) => (k['id'] ?? '').toString() == idKlijenta);
                  KlijentModel odabrani = KlijentModel(
                    id: kMap['id']?.toString() ?? '',
                    naziv: kMap['naziv']?.toString() ?? '',
                    adresa: kMap['adresa']?.toString() ?? '',
                    grad: kMap['grad']?.toString() ?? '',
                    oib: kMap['oib']?.toString() ?? '',
                    email: kMap['email']?.toString() ?? '',
                    telefon: kMap['telefon']?.toString() ?? '',
                    banka: kMap['banka']?.toString() ?? '',
                    iban: kMap['iban']?.toString() ?? '',
                    uSustavuPdv: kMap['uSustavuPdvA'] ?? kMap['uSustavuPdv'] ?? false,
                  );
                  widget.onKlijentChanged(odabrani);
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 12),

            // 2) NAZIV KALKULACIJE
            TextField(
              controller: _nazivKalkulacijeController,
              decoration: const InputDecoration(labelText: '2) Naziv kalkulacije', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // 3) POLAZAK / POVRATAK (DATUMI)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _datumPolaskaController,
                  readOnly: true,
                  onTap: () => _odaberiDatumPolaska(context),
                  decoration: const InputDecoration(labelText: '3a) Datum Polaska', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _datumPovratkaController,
                  readOnly: true,
                  onTap: () => _odaberiDatumPovratka(context),
                  decoration: const InputDecoration(labelText: '3b) Datum Povratka', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // 4) POLAZIŠTE
            TextField(
              controller: _polazisteController,
              decoration: const InputDecoration(labelText: '4) Polazište', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // 5) MEĐUODREDIŠTE A
            TextField(
              controller: _odrediste1Controller,
              decoration: const InputDecoration(labelText: '5) Međuodredište A (opcionalno)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // 6) MEĐUODREDIŠTE B
            TextField(
              controller: _odrediste2Controller,
              decoration: const InputDecoration(labelText: '6) Međuodredište B (opcionalno)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            // 7) KONAČNO ODREDIŠTE
            TextField(
              controller: _konacnoOdredisteController,
              decoration: const InputDecoration(labelText: '7) Konačno odredište', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            CheckboxListTile(
              title: const Text('Povratno putovanje'),
              value: _povratnoPutovanje,
              onChanged: (val) {
                setState(() {
                  _povratnoPutovanje = val ?? true;
                  _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
                  _preracunajCestarinuSOmogucenimDionicama();
                });
              },
            ),

            // 8) GRADOVI NA RUTI (DINAMIČKI PRIKAZ NAKON IZRAČUNA)
            if (_gradoviNaRuti.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('8) Gradovi na ruti (dinamički):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(_gradoviNaRuti.join(' -> '), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 9) DA LI ĆE SE KORISTITI AUTOPUT
            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('9) Da li će se koristiti autoput?', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _koristiAutocestu,
                      activeColor: const Color(0xFFEA580C),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _koristiAutocestu = val;
                          if (!_koristiAutocestu) {
                            _cestarinaController.text = '0.00';
                          } else {
                            _preracunajCestarinuSOmogucenimDionicama();
                          }
                        });
                      },
                    ),

                    // 10, 11, 12) AUTOPUT DIONICE (DINAMIČKI PRIKAZ AKO JE ODABRAN AUTOPUT)
                    if (_koristiAutocestu && _dioniceAutocesta.isNotEmpty) ...[
                      const Divider(),
                      const Text('Autoput dionice na ruti:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      ..._dioniceAutocesta.asMap().entries.map((entry) {
                        int index = entry.key;
                        var dionica = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${10 + index}) ${dionica['naziv']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${dionica['opis']} - ${(dionica['cijena'] as double).toStringAsFixed(2)} €', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: dionica['ukljuceno'],
                                activeColor: const Color(0xFFEA580C),
                                onChanged: (val) {
                                  setState(() {
                                    dionica['ukljuceno'] = val;
                                    _preracunajCestarinuSOmogucenimDionicama();
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 8),
                    TextField(
                      controller: _cestarinaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ukupan iznos cestarine (€, bruto)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.toll),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 13) IZRAČUNATO TRAJANJE DANA (DINAMIČKI)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('13) Izračunato trajanje:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '$_izracunatiBrojDana dana (${_izracunatiBrojDana > 1 ? _izracunatiBrojDana - 1 : 0} noćenja)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 14) VOZILO IZ VOZNOG PARKA
            DropdownButtonFormField<String>(
              value: _odabranoVoziloMap?['id'],
              isExpanded: true,
              decoration: const InputDecoration(labelText: '14) Vozilo iz voznog parka', border: OutlineInputBorder()),
              items: _dostupnaVozila.map((vozilo) {
                String nazivPrikaz = '${vozilo['naziv']} (${vozilo['kapacitet']} sjedala) - ${vozilo['potrosnja']} L/100km';
                return DropdownMenuItem<String>(
                  value: vozilo['id'],
                  child: Text(nazivPrikaz, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? idVozila) {
                if (idVozila != null) {
                  setState(() {
                    _odabranoVoziloMap = _dostupnaVozila.firstWhere((v) => v['id'] == idVozila);
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // 15, 16) GORIVO I DNEVNICA
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _cijenaGorivaController,
                  decoration: const InputDecoration(labelText: '15) Gorivo (€/L)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dnevnicaController,
                  decoration: const InputDecoration(labelText: '16) Dnevnica/dan (€)', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // 17) PARAMETRI NOĆENJA VOZAČA (DROPDOWN MENI)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _tkoPlacaNocenje,
                  decoration: const InputDecoration(
                    labelText: '17) Parametri noćenja vozača; Plaćanje noćenja',
                    border: OutlineInputBorder(),
                  ),
                  items: _opcijeNocenja.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tkoPlacaNocenje = val);
                  },
                ),
                if (_tkoPlacaNocenje == 'Prijevoznik plaća') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cijenaNocenjaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cijena noćenja po noći (€, bruto)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.hotel),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // 18) MARŽA (%)
            TextField(
              controller: _marzaController,
              decoration: const InputDecoration(labelText: '18) Marža (%)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // 19) GUMB: IZRAČUNAJ KILOMETRE / CESTARINU
            ElevatedButton.icon(
              onPressed: _isLoadingRoute ? null : _izracunajRutuIKilometre,
              icon: const Icon(Icons.route),
              label: Text(_isLoadingRoute ? 'Računam...' : '19) Izračunaj kilometre / cestarinu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // 20) GUMB: IZRADI I SPREMI KALKULACIJU
            ElevatedButton.icon(
              onPressed: _spremi,
              icon: const Icon(Icons.calculate),
              label: Text(_trenutniIdUredjivanja == null ? '20) Izradi i spremi kalkulaciju' : '20) Ažuriraj kalkulaciju'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
