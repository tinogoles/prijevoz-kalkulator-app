// lib/screens/izracun_troskova_tab.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import '../services/cestarine_service.dart';
import '../services/klijenti_service.dart';
import 'mapa_rute_screen.dart';

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

  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta');
  late TextEditingController _datumPolaskaController;
  late TextEditingController _datumPovratkaController;

  final TextEditingController _polazisteController = TextEditingController(text: 'Split');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Krapina');

  final TextEditingController _kmController = TextEditingController(text: '780');
  final TextEditingController _cestarinaController = TextEditingController(text: '0.00');

  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.96');
  final TextEditingController _dnevnicaController = TextEditingController(text: '100');
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '20');

  bool _koristiAutocestu = true;

  List<String> _gradoviNaRuti = [];
  List<Map<String, dynamic>> _dioniceAutocesta = [];

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
      _konacnoOdredisteController.text = k.konacnoOdrediste.isNotEmpty ? k.konacnoOdrediste : 'Krapina';
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

      // Privremeni izračun zračne udaljenosti za provjeru kratkih/lokalnih ruta (npr. Split - Omiš)
      double zracnaProbaKm = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        const double r = 6371.0;
        double dLat = (koordinate[i+1]['lat']! - koordinate[i]['lat']!) * pi / 180.0;
        double dLon = (koordinate[i+1]['lon']! - koordinate[i]['lon']!) * pi / 180.0;
        double a = sin(dLat / 2) * sin(dLat / 2) +
            cos(koordinate[i]['lat']! * pi / 180.0) * cos(koordinate[i+1]['lat']! * pi / 180.0) *
                sin(dLon / 2) * sin(dLon / 2);
        double c = 2 * atan2(sqrt(a), sqrt(1 - a));
        zracnaProbaKm += r * c;
      }

      // Ako je udaljenost manja od 50 km, automatski isključujemo autocestu
      if (zracnaProbaKm < 50.0) {
        setState(() {
          _koristiAutocestu = false;
        });
      }

      double ukupnoMetara = 0;
      String osrmModifier = _koristiAutocestu ? '' : '&exclude=motorway';

      for (int i = 0; i < koordinate.length - 1; i++) {
        final res = await http.get(Uri.parse(
            'https://router.project-osrm.org/route/v1/driving/${koordinate[i]['lon']},${koordinate[i]['lat']};${koordinate[i + 1]['lon']},${koordinate[i + 1]['lat']}?overview=false$osrmModifier'));
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          if (data['code'] == 'Ok') {
            ukupnoMetara += data['routes'][0]['distance'];
          }
        }
      }

      double kmJedan = ukupnoMetara / 1000.0;

      String pLower = _polazisteController.text.trim().toLowerCase();
      String kLower = _konacnoOdredisteController.text.trim().toLowerCase();

      List<String> dinamickiGradovi = List.from(tocke);
      List<Map<String, dynamic>> dionice = [];

      String katVozila = _odabranoVoziloMap?['kategorija'] ??
                          'II. Skupina (Vozila do 3.5t / kombi)';

      // Dionice autoceste računamo SAMO ako je prekidač uključen i ako ruta nije kratka/lokalna (< 50 km)
      if (_koristiAutocestu && kmJedan >= 50.0) {
        bool zahtijevaSkladisteniSplitaKrapina = 
            (pLower.contains('split') || pLower.contains('sibenik') || pLower.contains('zadar')) && 
            (kLower.contains('krapina') || kLower.contains('macelj') || kLower.contains('zabok'));

        bool zahtijevaObrnutuRutu = 
            (kLower.contains('split') || kLower.contains('sibenik') || kLower.contains('zadar')) && 
            (pLower.contains('krapina') || pLower.contains('macelj') || pLower.contains('zabok'));

        if (zahtijevaSkladisteniSplitaKrapina || zahtijevaObrnutuRutu) {
          String juzniGrad = zahtijevaSkladisteniSplitaKrapina ? _polazisteController.text : _konacnoOdredisteController.text;
          String sjeverniGrad = zahtijevaSkladisteniSplitaKrapina ? _konacnoOdredisteController.text : _polazisteController.text;

          dinamickiGradovi = [
            _polazisteController.text,
            if (_odrediste1Controller.text.isNotEmpty) _odrediste1Controller.text,
            'Zagreb',
            if (_odrediste2Controller.text.isNotEmpty) _odrediste2Controller.text,
            _konacnoOdredisteController.text,
          ];

          double cijenaA1 = await _cestarineService.izracunajUkupnuCestarinu(
            polaziste: juzniGrad,
            odrediste: 'Zagreb',
            kategorijaVozila: katVozila,
          );

          double cijenaA2 = await _cestarineService.izracunajUkupnuCestarinu(
            polaziste: 'Zaprešić',
            odrediste: sjeverniGrad,
            kategorijaVozila: katVozila,
          );

          dionice.add({
            'naziv': 'HAC A1 ($juzniGrad -> Zagreb)',
            'opis': '$juzniGrad -> Zagreb',
            'cijena': cijenaA1,
            'ukljuceno': true,
          });

          dionice.add({
            'naziv': 'AZM A2 (Zagreb/Zaprešić -> $sjeverniGrad)',
            'opis': 'Zaprešić -> $sjeverniGrad',
            'cijena': cijenaA2,
            'ukljuceno': true,
          });
        } else {
          var postajaP = await _cestarineService.dohvatiPostajuZaGrad(_polazisteController.text.trim());
          String koncesionar = postajaP?['koncesionar'] ?? 'HAC';
          String nazivDionice = '$koncesionar Autocesta (${_polazisteController.text.trim()} -> ${_konacnoOdredisteController.text.trim()})';

          double izracunataCestarina = await _cestarineService.izracunajUkupnuCestarinu(
            polaziste: _polazisteController.text.trim(),
            odrediste: _konacnoOdredisteController.text.trim(),
            medustajaliste: _odrediste1Controller.text.trim().isNotEmpty ? _odrediste1Controller.text.trim() : null,
            kategorijaVozila: katVozila,
          );

          dionice.add({
            'naziv': nazivDionice,
            'opis': '${_polazisteController.text.trim()} -> ${_konacnoOdredisteController.text.trim()}',
            'cijena': izracunataCestarina,
            'ukljuceno': true,
          });
        }
      }

      double sumaDionica = 0.0;
      for (var d in dionice) {
        if (d['ukljuceno'] == true) {
          sumaDionica += (d['cijena'] as num).toDouble();
        }
      }

      setState(() {
        _bazaKmJednosmjerno = kmJedan;
        _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
        _gradoviNaRuti = dinamickiGradovi;
        _dioniceAutocesta = dionice;

        double cestarinaUkupno = _koristiAutocestu ? (sumaDionica * (_povratnoPutovanje ? 2.0 : 1.0)) : 0.0;
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
      odabranaAutocesta: 'HAC / AZM Automatski izračun',
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

            TextField(
              controller: _nazivKalkulacijeController,
              decoration: const InputDecoration(labelText: '2) Naziv kalkulacije', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

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

            TextField(
              controller: _polazisteController,
              decoration: const InputDecoration(labelText: '4) Polazište', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _odrediste1Controller,
              decoration: const InputDecoration(labelText: '5) Međuodredište A (opcionalno)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _odrediste2Controller,
              decoration: const InputDecoration(labelText: '6) Međuodredište B (opcionalno)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),

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
            const SizedBox(height: 12),

            TextField(
              controller: _cijenaNocenjaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cijena noćenja po noći (€, bruto)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hotel),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _marzaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '18) Marža (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isLoadingRoute ? null : _izracunajRutuIKilometre,
              icon: _isLoadingRoute ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.route),
              label: Text(_isLoadingRoute ? 'Izračunavam rutu i cestarinu...' : 'Izračunaj rutu, km i cestarinu'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 12),

            // GUMB ZA PRIKAZ RUTE NA MAPI (prosljeđuje i uvjet _koristiAutocestu)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapaRuteScreen(
                      polaziste: _polazisteController.text.trim(),
                      odrediste: _konacnoOdredisteController.text.trim(),
                      koristiAutocestu: _koristiAutocestu,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Prikaži rutu na mapi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _spremi,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              child: const Text('Spremi kalkulaciju', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
