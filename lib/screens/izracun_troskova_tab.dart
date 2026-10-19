import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import '../data/baza_cestarina_data.dart';
import '../widgets/unos_rute_widget.dart';
import '../widgets/nocenje_sekcija_widget.dart';
import '../widgets/autocesta_sekcija_widget.dart';
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
  final List<Map<String, dynamic>> _bazaRelacijaCestarina = BazaCestarinaData.dioniceCestarina;
  final KlijentiService _klijentiService = KlijentiService();
  
  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta');
  final TextEditingController _polazisteController = TextEditingController(text: 'Split');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Zagreb');
  late TextEditingController _datumPolaskaController;
  late TextEditingController _datumPovratkaController;
  
  int _izracunatiBrojDana = 1;
  double _bazaKmJednosmjerno = 390.0;
  bool _povratnoPutovanje = true;
  final TextEditingController _kmController = TextEditingController(text: '780');
  final TextEditingController _cestarinaController = TextEditingController(text: '167.40');
  
  bool _koristiAutocestu = true;
  String _odabranaAutocesta = 'HAC (Hrvatske autoceste)';
  final List<String> _opcijeAutocesta = [
    'HAC (Hrvatske autoceste)',
    'AZM (Zagreb - Macelj)',
    'DARS (Slovenske autoceste)',
    'Autoceste FBiH / RS',
    'Bez autoceste / Lokalna cesta'
  ];

  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.96');
  final TextEditingController _dnevnicaController = TextEditingController(text: '100');

  String _tkoPlacaNocenje = 'Bez noćenja';
  final List<String> _opcijeNocenja = [
    'Prijevoznik plaća',
    'Klijent/Agencija plaća (0€ za nas)',
    'Bez noćenja'
  ];
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '20');

  final Map<String, double> _potrosnjaVozila = {
    'Kombi 8+1': 9.0,
    'Mini bus <20': 15.0,
    'Midi bus 35': 30.0,
    'Veliki autobus 50': 35.0,
  };
  late String _odabranoVozilo;
  String? _trenutniIdUredjivanja;

  final Map<String, String> _mapiranjeGradovaNaCestarinu = {
    'split': 'dugopolje',
    'zagreb': 'lučko',
    'zadar': 'zadar',
    'šibenik': 'šibenik',
    'karlovac': 'karlovac',
    'rijeka': 'rijeka',
    'slavonski brod': 'slavonski brod',
    'osijek': 'osijek',
    'varaždin': 'varaždin',
  };

  String _formatirajDatum(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.last;
    String danas = _formatirajDatum(DateTime.now());
    _datumPolaskaController = TextEditingController(text: danas);
    _datumPovratkaController = TextEditingController(text: danas);
    
    if (widget.kalkulacijaZaUredivanje != null) {
      _popuniPodatkeZaUredivanje(widget.kalkulacijaZaUredivanje!);
    } else {
      _preracunajBrojDana();
    }
  }

  @override
  void didUpdateWidget(covariant IzracunTroskovaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kalkulacijaZaUredivanje != oldWidget.kalkulacijaZaUredivanje) {
      if (widget.kalkulacijaZaUredivanje != null) {
        _popuniPodatkeZaUredivanje(widget.kalkulacijaZaUredivanje!);
      }
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
        if (match != null) {
          kmVal = match.group(1) ?? '780';
        } else {
          kmVal = '780';
        }
      }
      _kmController.text = kmVal;

      _cestarinaController.text = (k.cestarina.isNotEmpty && k.cestarina != '0') ? k.cestarina : '167.40';
      _povratnoPutovanje = k.povratno;
      _koristiAutocestu = k.koristiAutocestu;
      _odabranaAutocesta = k.odabranaAutocesta.isNotEmpty ? k.odabranaAutocesta : _opcijeAutocesta.first;
      _tkoPlacaNocenje = k.tkoPlacaNocenje.isNotEmpty ? k.tkoPlacaNocenje : 'Bez noćenja';
      _cijenaNocenjaController.text = k.cijenaNocenja.isNotEmpty ? k.cijenaNocenja : '60';
      _marzaController.text = k.marza.isNotEmpty ? k.marza : '20';
      _cijenaGorivaController.text = k.cijenaGoriva.isNotEmpty ? k.cijenaGoriva : '1.96';
      _dnevnicaController.text = k.dnevnica.isNotEmpty ? k.dnevnica : '100';
      
      if (_potrosnjaVozila.containsKey(k.vozilo)) {
        _odabranoVozilo = k.vozilo;
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
        pocetniDatum = DateTime(int.parse(d1Str.substring(4, 8)), int.parse(d1Str.substring(2, 4)), int.parse(d1Str.substring(0, 2)));
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
        DateTime d1 = DateTime(int.parse(d1Str.substring(4, 8)), int.parse(d1Str.substring(2, 4)), int.parse(d1Str.substring(0, 2)));
        DateTime d2 = DateTime(int.parse(d2Str.substring(4, 8)), int.parse(d2Str.substring(2, 4)), int.parse(d2Str.substring(0, 2)));
        int razlika = d2.difference(d1).inDays + 1;
        setState(() => _izracunatiBrojDana = razlika > 0 ? razlika : 1);
      }
    } catch (_) {}
  }

  void _automatskiDetektirajCestarinuPoGradovima(String polaziste, String odrediste) {
    String p = polaziste.trim().toLowerCase();
    String o = odrediste.trim().toLowerCase();

    String? cestarinaUlaz = _mapiranjeGradovaNaCestarinu[p];
    String? cestarinaIzlaz = _mapiranjeGradovaNaCestarinu[o];

    if (cestarinaUlaz != null && cestarinaIzlaz != null) {
      for (var relacija in _bazaRelacijaCestarina) {
        String ulazBaza = (relacija['ulaz'] ?? '').toString().toLowerCase();
        String izlazBaza = (relacija['izlaz'] ?? '').toString().toLowerCase();

        bool poklapanje = (ulazBaza.contains(cestarinaUlaz) && izlazBaza.contains(cestarinaIzlaz)) ||
                          (ulazBaza.contains(cestarinaIzlaz) && izlazBaza.contains(cestarinaUlaz));

        if (poklapanje) {
          setState(() {
            _koristiAutocestu = true;
            Map<String, dynamic> cestarineMap = relacija['cijene'] ?? {};
            if (cestarineMap.containsKey(_odabranoVozilo)) {
              double jednosmjerna = cestarineMap[_odabranoVozilo];
              _cestarinaController.text = (jednosmjerna * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(2);
            }
          });
          break;
        }
      }
    }
  }

  Future<void> _izracunajRutuMultiPoint() async {
    List<String> tocke = [];
    if (_polazisteController.text.trim().isNotEmpty) tocke.add(_polazisteController.text.trim());
    if (_odrediste1Controller.text.trim().isNotEmpty) tocke.add(_odrediste1Controller.text.trim());
    if (_odrediste2Controller.text.trim().isNotEmpty) tocke.add(_odrediste2Controller.text.trim());
    if (_konacnoOdredisteController.text.trim().isNotEmpty) tocke.add(_konacnoOdredisteController.text.trim());

    if (tocke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unesite polazište i odredište.')));
      return;
    }
    setState(() => _isLoadingRoute = true);
    try {
      Future<Map<String, double>?> getCoords(String q) async {
        final res = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=1'), headers: {'User-Agent': 'PrijevozKalkulatorApp'});
        if (res.statusCode == 200) {
          List data = json.decode(res.body);
          if (data.isNotEmpty) return {'lat': double.parse(data[0]['lat']), 'lon': double.parse(data[0]['lon'])};
        }
        return null;
      }
      List<Map<String, double>> koordinate = [];
      for (String t in tocke) {
        var c = await getCoords(t);
        if (c != null) koordinate.add(c); else throw Exception('Lokacija "$t" nije nađena.');
      }
      double ukupnoMetara = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        final res = await http.get(Uri.parse('https://router.project-osrm.org/route/v1/driving/${koordinate[i]['lon']},${koordinate[i]['lat']};${koordinate[i + 1]['lon']},${koordinate[i + 1]['lat']}?overview=false'));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          if (data['code'] == 'Ok') ukupnoMetara += data['routes'][0]['distance'];
        }
      }
      double kmJedan = ukupnoMetara / 1000.0;
      setState(() {
        _bazaKmJednosmjerno = kmJedan;
        _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
      });
      
      _automatskiDetektirajCestarinuPoGradovima(_polazisteController.text, _konacnoOdredisteController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izračunato: ${kmJedan.toStringAsFixed(1)} km'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _spremi() {
    _preracunajBrojDana();
    double km = double.tryParse(_kmController.text) ?? 0;
    double cestarinaBruto = double.tryParse(_cestarinaController.text) ?? 0;
    double gorivoBruto = double.tryParse(_cijenaGorivaController.text) ?? 1.96;
    double dnevnica = double.tryParse(_dnevnicaController.text) ?? 100;
    double nocenjeBruto = double.tryParse(_cijenaNocenjaController.text) ?? 60;
    double marza = double.tryParse(_marzaController.text) ?? 20;

    double potrosnja = _potrosnjaVozila[_odabranoVozilo] ?? 35.0;
    int brojNocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double cestarinaNeto = (_koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnica * _izracunatiBrojDana;
    double nocenjeNeto = (_tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marza / 100);
    double osnovicaSMarzom = cistiTrosak + zarada;
    double ukupnaCijena = osnovicaSMarzom * 1.25;

    KalkulacijaModel kalk = KalkulacijaModel(
      id: _trenutniIdUredjivanja ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: _nazivKalkulacijeController.text,
      klijentNaziv: widget.aktivniKlijent?.naziv ?? 'Klijent',
      datumPolaska: _datumPolaskaController.text,
      datumPovratka: _datumPovratkaController.text,
      vozilo: _odabranoVozilo,
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
      odabranaAutocesta: _odabranaAutocesta,
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_trenutniIdUredjivanja == null ? 'Izračun Troškova Prijevoza' : 'Uređivanje Kalkulacije', style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<KlijentModel>(
              value: widget.aktivniKlijent,
              decoration: const InputDecoration(labelText: 'Klijent', border: OutlineInputBorder()),
              items: listaKlijenata.map((kMap) {
                KlijentModel kM = KlijentModel(
                  id: kMap['id'] ?? '',
                  naziv: kMap['naziv'] ?? '',
                  adresa: kMap['adresa'] ?? '',
                  grad: kMap['grad'] ?? '',
                  oib: kMap['oib'] ?? '',
                  email: kMap['email'] ?? '',
                  telefon: kMap['telefon'] ?? '',
                  banka: kMap['banka'] ?? '',
                  iban: kMap['iban'] ?? '',
                  uSustavuPdvA: kMap['uSustavuPdvA'] ?? true,
                );
                return DropdownMenuItem<KlijentModel>(
                  value: kM,
                  child: Text(kM.naziv),
                );
              }).toList(),
              onChanged: (val) {
                widget.onKlijentChanged(val);
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            UnosRuteWidget(
              polazisteController: _polazisteController,
              odrediste1Controller: _odrediste1Controller,
              odrediste2Controller: _odrediste2Controller,
              konacnoOdredisteController: _konacnoOdredisteController,
              kmController: _kmController,
              datumPolaskaController: _datumPolaskaController,
              datumPovratkaController: _datumPovratkaController,
              povratnoPutovanje: _povratnoPutovanje,
              onPovratnoChanged: (val) {
                setState(() {
                  _povratnoPutovanje = val ?? true;
                  _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
                });
              },
              izracunatiBrojDana: _izracunatiBrojDana,
              onOdaberiDatumPolaska: () => _odaberiDatumPolaska(context),
              onOdaberiDatumPovratka: () => _odaberiDatumPovratka(context),
              onIzracunajRutu: _izracunajRutuMultiPoint,
              isLoadingRoute: _isLoadingRoute,
            ),
            const SizedBox(height: 12),
            TextField(controller: _nazivKalkulacijeController, decoration: const InputDecoration(labelText: 'Naziv kalkulacije', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _odabranoVozilo,
              decoration: const InputDecoration(labelText: 'Vozilo', border: OutlineInputBorder()),
              items: _potrosnjaVozila.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (val) => setState(() => _odabranoVozilo = val!),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _cijenaGorivaController, decoration: const InputDecoration(labelText: 'Gorivo (€/L)', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _dnevnicaController, decoration: const InputDecoration(labelText: 'Dnevnica/dan (€)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            NocenjeSekcijaWidget(
              tkoPlacaNocenje: _tkoPlacaNocenje,
              onTkoPlacaChanged: (val) { if (val != null) setState(() => _tkoPlacaNocenje = val); },
              cijenaNocenjaController: _cijenaNocenjaController,
              opcijeNocenja: _opcijeNocenja,
            ),
            const SizedBox(height: 12),
            TextField(controller: _marzaController, decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            AutocestaSekcijaWidget(
              koristiAutocestu: _koristiAutocestu,
              onAutocestaChanged: (value) {
                setState(() {
                  _koristiAutocestu = value;
                  if (!_koristiAutocestu) _cestarinaController.text = '0.00';
                });
              },
              odabranaAutocesta: _odabranaAutocesta,
              onAutocestaSelected: (val) { if (val != null) setState(() => _odabranaAutocesta = val); },
              cestarinaController: _cestarinaController,
              opcijeAutocesta: _opcijeAutocesta,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
              icon: const Icon(Icons.route),
              label: Text(_isLoadingRoute ? 'Računam...' : 'Izračunaj kilometre po točkama (OSRM)'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _spremi,
              icon: const Icon(Icons.calculate),
              label: Text(_trenutniIdUredjivanja == null ? 'Izradi i spremi kalkulaciju' : 'Ažuriraj kalkulaciju'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
