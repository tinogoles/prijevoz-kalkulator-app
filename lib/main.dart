import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PrijevozKalkulatorApp());
}

class PrijevozKalkulatorApp extends StatelessWidget {
  const PrijevozKalkulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Prijevoza HR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFEA580C),
        ),
        useMaterial3: true,
      ),
      home: const GlavniNavigatorScreen(),
    );
  }
}

// Modeli podataka
class PrijevoznikModel {
  String naziv, vlasnik, adresa, grad, oib, telefon, email;
  bool uSustavuPdv;

  PrijevoznikModel({
    this.naziv = 'Moj Prijevoz d.o.o.',
    this.vlasnik = 'Ivan Horvat',
    this.adresa = 'Zagrebačka cesta 10',
    this.grad = 'Zagreb',
    this.oib = '12345678901',
    this.telefon = '+385 91 123 4567',
    this.email = 'info@mojprijevoz.hr',
    this.uSustavuPdv = true,
  });

  Map<String, dynamic> toJson() => {
    'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad,
    'oib': oib, 'telefon': telefon, 'email': email, 'uSustavuPdv': uSustavuPdv,
  };

  factory PrijevoznikModel.fromJson(Map<String, dynamic> json) => PrijevoznikModel(
    naziv: json['naziv'] ?? '', vlasnik: json['vlasnik'] ?? '', adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '', oib: json['oib'] ?? '', telefon: json['telefon'] ?? '',
    email: json['email'] ?? '', uSustavuPdv: json['uSustavuPdv'] ?? true,
  );
}

class KlijentModel {
  String id, naziv, vlasnik, adresa, grad, oib, telefon, email;
  bool uSustavuPdv;

  KlijentModel({
    required this.id,
    this.naziv = '',
    this.vlasnik = '',
    this.adresa = '',
    this.grad = '',
    this.oib = '',
    this.telefon = '',
    this.email = '',
    this.uSustavuPdv = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad,
    'oib': oib, 'telefon': telefon, 'email': email, 'uSustavuPdv': uSustavuPdv,
  };

  factory KlijentModel.fromJson(Map<String, dynamic> json) => KlijentModel(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    naziv: json['naziv'] ?? '', vlasnik: json['vlasnik'] ?? '', adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '', oib: json['oib'] ?? '', telefon: json['telefon'] ?? '',
    email: json['email'] ?? '', uSustavuPdv: json['uSustavuPdv'] ?? true,
  );
}

class KalkulacijaModel {
  String id, nazivKalkulacije, klijentNaziv, datumPolaska, datumPovratka, vozilo, ruta;
  double ukupnaCijena;

  KalkulacijaModel({
    required this.id,
    required this.nazivKalkulacije,
    required this.klijentNaziv,
    required this.datumPolaska,
    required this.datumPovratka,
    required this.vozilo,
    required this.ruta,
    required this.ukupnaCijena,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nazivKalkulacije': nazivKalkulacije, 'klijentNaziv': klijentNaziv,
    'datumPolaska': datumPolaska, 'datumPovratka': datumPovratka,
    'vozilo': vozilo, 'ruta': ruta, 'ukupnaCijena': ukupnaCijena,
  };

  factory KalkulacijaModel.fromJson(Map<String, dynamic> json) => KalkulacijaModel(
    id: json['id'] ?? '',
    nazivKalkulacije: json['nazivKalkulacije'] ?? '',
    klijentNaziv: json['klijentNaziv'] ?? '',
    datumPolaska: json['datumPolaska'] ?? '',
    datumPovratka: json['datumPovratka'] ?? '',
    vozilo: json['vozilo'] ?? '',
    ruta: json['ruta'] ?? '',
    ukupnaCijena: json['ukupnaCijena'] ?? 0.0,
  );
}

class GlavniNavigatorScreen extends StatefulWidget {
  const GlavniNavigatorScreen({super.key});

  @override
  State<GlavniNavigatorScreen> createState() => _GlavniNavigatorScreenState();
}

class _GlavniNavigatorScreenState extends State<GlavniNavigatorScreen> {
  int _currentIndex = 0;

  PrijevoznikModel _prijevoznik = PrijevoznikModel();
  List<KlijentModel> _klijenti = [];
  List<KalkulacijaModel> _spremljeneKalkulacije = [];

  // Trenutni odabrani klijent za kalkulaciju
  KlijentModel? _aktivniKlijent;

  @override
  void initState() {
    super.initState();
    _ucitajPodatkeIzMemorije();
  }

  Future<void> _ucitajPodatkeIzMemorije() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Prijevoznik
    String? pJson = prefs.getString('prijevoznik');
    if (pJson != null) {
      setState(() {
        _prijevoznik = PrijevoznikModel.fromJson(json.decode(pJson));
      });
    }

    // Klijenti
    String? kListJson = prefs.getString('klijenti');
    if (kListJson != null) {
      List decoded = json.decode(kListJson);
      setState(() {
        _klijenti = decoded.map((e) => KlijentModel.fromJson(e)).toList();
        if (_klijenti.isNotEmpty) _aktivniKlijent = _klijenti.first;
      });
    } else {
      // Inicijalni klijent ako nema niceg
      setState(() {
        _klijenti.add(KlijentModel(id: '1', naziv: 'Turistička Agencija Split', vlasnik: 'Marko Marić', grad: 'Split', oib: '98765432109', uSustavuPdv: true));
        _aktivniKlijent = _klijenti.first;
      });
    }

    // Kalkulacije
    String? kalkJson = prefs.getString('kalkulacije');
    if (kalkJson != null) {
      List decoded = json.decode(kalkJson);
      setState(() {
        _spremljeneKalkulacije = decoded.map((e) => KalkulacijaModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> _spremiPodatkeUMemoriju() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prijevoznik', json.encode(_prijevoznik.toJson()));
    await prefs.setString('klijenti', json.encode(_klijenti.map((e) => e.toJson()).toList()));
    await prefs.setString('kalkulacije', json.encode(_spremljeneKalkulacije.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> ekrani = [
      IzracunTroskovaTab(
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        aktivniKlijent: _aktivniKlijent,
        onKlijentChanged: (k) => setState(() => _aktivniKlijent = k),
        onSpremiKalkulaciju: (kalk) {
          setState(() {
            int index = _spremljeneKalkulacije.indexWhere((element) => element.id == kalk.id);
            if (index >= 0) {
              _spremljeneKalkulacije[index] = kalk;
            } else {
              _spremljeneKalkulacije.add(kalk);
            }
          });
          _spremiPodatkeUMemoriju();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalkulacija uspješno spremljena u arhivu!'), backgroundColor: Colors.green));
        },
      ),
      KalkulacijeTab(
        kalkulacije: _spremljeneKalkulacije,
        onObrisi: (id) {
          setState(() {
            _spremljeneKalkulacije.removeWhere((element) => element.id == id);
          });
          _spremiPodatkeUMemoriju();
        },
      ),
      PostavkeTab(
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        onUpdate: () {
          setState(() {});
          _spremiPodatkeUMemoriju();
        },
      ),
    ];

    return Scaffold(
      body: ekrani[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0284C7),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '1) Izračun troškova'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: '2) Kalkulacije'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '3) Postavke'),
        ],
      ),
    );
  }
}
class IzracunTroskovaTab extends StatefulWidget {
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final KlijentModel? aktivniKlijent;
  final ValueChanged<KlijentModel?> onKlijentChanged;
  final ValueChanged<KalkulacijaModel> onSpremiKalkulaciju;

  const IzracunTroskovaTab({
    super.key,
    required this.prijevoznik,
    required this.klijenti,
    required this.aktivniKlijent,
    required this.onKlijentChanged,
    required this.onSpremiKalkulaciju,
  });

  @override
  State<IzracunTroskovaTab> createState() => _IzracunajTroskovaTabState();
}

class _IzracunajTroskovaTabState extends State<IzracunTroskovaTab> {
  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta po točkama');
  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Split');

  // Format DD.MM.YYYY
  final TextEditingController _datumPolaskaController = TextEditingController(text: '01.06.2026.');
  final TextEditingController _datumPovratkaController = TextEditingController(text: '03.06.2026.');
  int _izracunatiBrojDana = 3;

  double _bazaKmJednosmjerno = 390.0;
  bool _povratnoPutovanje = true;
  final TextEditingController _kmController = TextEditingController(text: '780');
  final TextEditingController _cestarinaController = TextEditingController(text: '35.00');

  bool _koristiAutocestu = true;
  String _odabranaAutocesta = 'HAC (Hrvatske autoceste)';
  final List<String> _opcijeAutocesta = [
    'HAC (Hrvatske autoceste)',
    'AZM (Zagreb - Macelj)',
    'DARS (Slovenske autoceste)',
    'Autoceste FBiH / RS',
    'Bez autoceste / Lokalna cesta'
  ];

  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.45');
  final TextEditingController _dnevnicaController = TextEditingController(text: '80');

  String _tkoPlacaNocenje = 'Prijevoznik plaća';
  final List<String> _opcijeNocenja = [
    'Prijevoznik plaća',
    'Klijent/Agencija plaća (0€ za nas)',
    'Bez noćenja'
  ];
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '20');

  final Map<String, double> _potrosnjaVozila = {
    'Kombi 8+1 (9L / 100km)': 9.0,
    'Mini bus <20 (15L / 100km)': 15.0,
    'Midi bus 35 (30L / 100km)': 30.0,
    'Veliki autobus 50 (35L / 100km)': 35.0,
  };
  late String _odabranoVozilo;

  double _trosakGorivaBruto = 0;
  double _trosakGorivaPdv = 0;
  double _trosakCestarineBruto = 0;
  double _trosakCestarinePdv = 0;
  double _trosakVozaca = 0;
  double _trosakNocenjaBruto = 0;
  double _trosakNocenjaPdv = 0;
  double _ukupniUlazniPdv = 0;
  double _ukupniCistiTrosak = 0;
  double _zarada = 0;
  double _osnovicaNeto = 0;
  double _iznosIzlaznogPdv = 0;
  double _ukupnaCijenaPonude = 0;

  bool _kalkulacijaIzradena = false;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;
    _preracunajBrojDana();
    _izracunajTroskove();
  }

  void _preracunajBrojDana() {
    try {
      // Parsiranje DD.MM.YYYY.
      String d1Str = _datumPolaskaController.text.replaceAll('.', '').trim();
      String d2Str = _datumPovratkaController.text.replaceAll('.', '').trim();
      if (d1Str.length == 8 && d2Str.length == 8) {
        DateTime d1 = DateTime(int.parse(d1Str.substring(4, 8)), int.parse(d1Str.substring(2, 4)), int.parse(d1Str.substring(0, 2)));
        DateTime d2 = DateTime(int.parse(d2Str.substring(4, 8)), int.parse(d2Str.substring(2, 4)), int.parse(d2Str.substring(0, 2)));
        int razlika = d2.difference(d1).inDays + 1;
        setState(() {
          _izracunatiBrojDana = razlika > 0 ? razlika : 1;
        });
      }
    } catch (_) {}
  }

  void _izracunajTroskove() {
    _preracunajBrojDana();

    setState(() {
      double km = double.tryParse(_kmController.text) ?? 0;
      double cestarinaBruto = double.tryParse(_cestarinaController.text) ?? 0;
      double cijenaGorivaBruto = double.tryParse(_cijenaGorivaController.text) ?? 0;
      double dnevnicaPoDanu = double.tryParse(_dnevnicaController.text) ?? 0;
      double cijenaNocenjaBruto = double.tryParse(_cijenaNocenjaController.text) ?? 0;
      double marzaPostotak = double.tryParse(_marzaController.text) ?? 0;

      double potrosnjaNa100km = _potrosnjaVozila[_odabranoVozilo] ?? 9.0;
      int brojNocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

      _trosakGorivaBruto = (km / 100) * potrosnjaNa100km * cijenaGorivaBruto;
      double gorivoNeto = _trosakGorivaBruto / 1.25;
      _trosakGorivaPdv = _trosakGorivaBruto - gorivoNeto;

      _trosakCestarineBruto = _koristiAutocestu ? cestarinaBruto : 0;
      double cestarinaNeto = _trosakCestarineBruto / 1.25;
      _trosakCestarinePdv = _trosakCestarineBruto - cestarinaNeto;

      _trosakVozaca = dnevnicaPoDanu * _izracunatiBrojDana;

      if (_tkoPlacaNocenje == 'Prijevoznik plaća') {
        _trosakNocenjaBruto = cijenaNocenjaBruto * brojNocenja;
      } else {
        _trosakNocenjaBruto = 0;
      }
      double nocenjeNeto = _trosakNocenjaBruto / 1.25;
      _trosakNocenjaPdv = _trosakNocenjaBruto - nocenjeNeto;

      _ukupniUlazniPdv = _trosakGorivaPdv + _trosakCestarinePdv + _trosakNocenjaPdv;
      _ukupniCistiTrosak = gorivoNeto + cestarinaNeto + _trosakVozaca + nocenjeNeto;
      _zarada = _ukupniCistiTrosak * (marzaPostotak / 100);
      _osnovicaNeto = _ukupniCistiTrosak + _zarada;

      bool klijentPdv = widget.aktivniKlijent?.uSustavuPdv ?? true;
      if (klijentPdv) {
        _iznosIzlaznogPdv = _osnovicaNeto * 0.25;
        _ukupnaCijenaPonude = _osnovicaNeto + _iznosIzlaznogPdv;
      } else {
        _iznosIzlaznogPdv = 0;
        _ukupnaCijenaPonude = _osnovicaNeto;
      }
    });
  }

  Future<void> _izracunajRutuMultiPoint() async {
    List<String> tocke = [];
    if (_polazisteController.text.trim().isNotEmpty) tocke.add(_polazisteController.text.trim());
    if (_odrediste1Controller.text.trim().isNotEmpty) tocke.add(_odrediste1Controller.text.trim());
    if (_odrediste2Controller.text.trim().isNotEmpty) tocke.add(_odrediste2Controller.text.trim());
    if (_konacnoOdredisteController.text.trim().isNotEmpty) tocke.add(_konacnoOdredisteController.text.trim());

    if (tocke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unesite barem Polazište i Konačno odredište.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoadingRoute = true);
    try {
      Future<Map<String, double>?> getCoords(String query) async {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
        final response = await http.get(url, headers: {'User-Agent': 'PrijevozKalkulatorApp'});
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          if (data.isNotEmpty) return {'lat': double.parse(data[0]['lat']), 'lon': double.parse(data[0]['lon'])};
        }
        return null;
      }

      List<Map<String, double>> koordinate = [];
      for (String tocka in tocke) {
        var c = await getCoords(tocka);
        if (c != null) koordinate.add(c);
        else throw Exception('Lokacija "$tocka" nije pronađena.');
      }

      double ukupnoMetara = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        final osrmUrl = Uri.parse('https://router.project-osrm.org/route/v1/driving/${koordinate[i]['lon']},${koordinate[i]['lat']};${koordinate[i + 1]['lon']},${koordinate[i + 1]['lat']}?overview=false');
        final res = await http.get(osrmUrl);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['code'] == 'Ok') ukupnoMetara += data['routes'][0]['distance'];
        }
      }

      double kmJedanSmjer = ukupnoMetara / 1000.0;
      setState(() {
        _bazaKmJednosmjerno = kmJedanSmjer;
        double faktor = _povratnoPutovanje ? 2.0 : 1.0;
        _kmController.text = (_bazaKmJednosmjerno * faktor).toStringAsFixed(0);
      });
      _izracunajTroskove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uspješno izračunato: ${kmJedanSmjer.toStringAsFixed(1)} km (1 smjer)'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Greška: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _spremi() {
    _izracunajTroskove();
    setState(() => _kalkulacijaIzradena = true);

    String relacija = '${_polazisteController.text} -> ${_konacnoOdredisteController.text}';
    KalkulacijaModel kalk = KalkulacijaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: _nazivKalkulacijeController.text,
      klijentNaziv: widget.aktivniKlijent?.naziv ?? 'Nepoznat klijent',
      datumPolaska: _datumPolaskaController.text,
      datumPovratka: _datumPovratkaController.text,
      vozilo: _odabranoVozilo,
      ruta: relacija,
      ukupnaCijena: _ukupnaCijenaPonude,
    );
    widget.onSpremiKalkulaciju(kalk);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izračun Troškova Prijevoza', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Odabir Klijenta iz izbornika
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Odaberite Klijenta usluge:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0284C7))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<KlijentModel>(
                      value: widget.aktivniKlijent,
                      decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                      items: widget.klijenti.map((k) => DropdownMenuItem(value: k, child: Text(k.naziv.isEmpty ? 'Nepoznat klijent' : k.naziv))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          widget.onKlijentChanged(val);
                          _izracunajTroskove();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rute
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ruta i Kilometraža (OSRM)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 12),
                    TextField(controller: _polazisteController, decoration: const InputDecoration(labelText: '1) Polazište', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _odrediste1Controller, decoration: const InputDecoration(labelText: '2) Međuodredište A (opcionalno)', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _odrediste2Controller, decoration: const InputDecoration(labelText: '3) Međuodredište B (opcionalno)', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _konacnoOdredisteController, decoration: const InputDecoration(labelText: '4) Konačno odredište', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
                      icon: const Icon(Icons.route, color: Colors.white),
                      label: Text(_isLoadingRoute ? 'Izračunavam...' : 'Izračunaj kilometre (OSRM)'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                    ),
                    CheckboxListTile(
                      title: const Text('Povratno putovanje (množi s 2)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: _povratnoPutovanje,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _povratnoPutovanje = val ?? true;
                          double faktor = _povratnoPutovanje ? 2.0 : 1.0;
                          _kmController.text = (_bazaKmJednosmjerno * faktor).toStringAsFixed(0);
                          _izracunajTroskove();
                        });
                      },
                    ),
                    TextField(controller: _kmController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ukupno Kilometara (km)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Datumi u formatu DD.MM.YYYY
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Termin Putovanja (DD.MM.YYYY.)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _datumPolaskaController, decoration: const InputDecoration(labelText: 'Polazak', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _datumPovratkaController, decoration: const InputDecoration(labelText: 'Povratak', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Trajanje: $_izracunatiBrojDana dana (${_izracunatiBrojDana > 1 ? _izracunatiBrojDana - 1 : 0} noćenja)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Naziv kalkulacije
            TextField(controller: _nazivKalkulacijeController, decoration: const InputDecoration(labelText: 'Naziv kalkulacije / izleta', border: OutlineInputBorder())),
            const SizedBox(height: 16),

            // Cestarine, vozila i troškovi
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parametri Vozila i Troškova', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _odabranoVozilo,
                      decoration: const InputDecoration(labelText: 'Vozilo', border: OutlineInputBorder()),
                      items: _potrosnjaVozila.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() { _odabranoVozilo = val; _izracunajTroskove(); });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaGorivaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gorivo (€/L)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _dnevnicaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dnevnica/dan (€)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _cestarinaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cestarina bruto (€)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove()),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tkoPlacaNocenje,
                      decoration: const InputDecoration(labelText: 'Noćenje vozača', border: OutlineInputBorder()),
                      items: _opcijeNocenja.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() { _tkoPlacaNocenje = val; _izracunajTroskove(); });
                      },
                    ),
                    if (_tkoPlacaNocenje == 'Prijevoznik plaća') ...[
                      const SizedBox(height: 12),
                      TextField(controller: _cijenaNocenjaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cijena noćenja po noći (€)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove()),
                    ],
                    const SizedBox(height: 12),
                    TextField(controller: _marzaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _spremi,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('IZRADI I SPREMI KALKULACIJU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
class KalkulacijeTab extends StatelessWidget {
  final List<KalkulacijaModel> kalkulacije;
  final ValueChanged<String> onObrisi;

  const KalkulacijeTab({super.key, required this.kalkulacije, required this.onObrisi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spremljene Kalkulacije i Ponude', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: kalkulacije.isEmpty
          ? const Center(child: Text('Nema spremljenih kalkulacija.', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kalkulacije.length,
              itemBuilder: (context, index) {
                var k = kalkulacije[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(k.nazivKalkulacije, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        const SizedBox(height: 4),
                        Text('Klijent: ${k.klijentNaziv}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Ruta: ${k.ruta}'),
                        Text('Termin: ${k.datumPolaska} - ${k.datumPovratka}'),
                        Text('Ukupno: ${k.ukupnaCijena.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA580C), fontSize: 15)),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                showDialog(context: context, builder: (_) => AlertDialog(
                                  title: const Text('Brisanje kalkulacije'),
                                  content: const Text('Da li stvarno želite obrisati ovu kalkulaciju?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
                                    TextButton(onPressed: () { onObrisi(k.id); Navigator.pop(context); }, child: const Text('Obriši', style: TextStyle(color: Colors.red))),
                                  ],
                                ));
                              },
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              label: const Text('Obriši', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PostavkeTab extends StatefulWidget {
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final VoidCallback onUpdate;

  const PostavkeTab({super.key, required this.prijevoznik, required this.klijenti, required this.onUpdate});

  @override
  State<PostavkeTab> createState() => _PostavkeTabState();
}

class _PostavkeTabState extends State<PostavkeTab> {
  // Kontroleri prijevoznika
  late TextEditingController _pNaziv = TextEditingController(text: widget.prijevoznik.naziv);
  late TextEditingController _pVlasnik = TextEditingController(text: widget.prijevoznik.vlasnik);
  late TextEditingController _pAdresa = TextEditingController(text: widget.prijevoznik.adresa);
  late TextEditingController _pGrad = TextEditingController(text: widget.prijevoznik.grad);
  late TextEditingController _pOib = TextEditingController(text: widget.prijevoznik.oib);
  late TextEditingController _pTel = TextEditingController(text: widget.prijevoznik.telefon);
  late TextEditingController _pEmail = TextEditingController(text: widget.prijevoznik.email);
  late bool _pPdv = widget.prijevoznik.uSustavuPdv;

  void _spremiPrijevoznika() {
    widget.prijevoznik.naziv = _pNaziv.text;
    widget.prijevoznik.vlasnik = _pVlasnik.text;
    widget.prijevoznik.adresa = _pAdresa.text;
    widget.prijevoznik.grad = _pGrad.text;
    widget.prijevoznik.oib = _pOib.text;
    widget.prijevoznik.telefon = _pTel.text;
    widget.prijevoznik.email = _pEmail.text;
    widget.prijevoznik.uSustavuPdv = _pPdv;
    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Podaci o prijevozniku spremljeni!'), backgroundColor: Colors.green));
  }

  void _urediIliDodajKlijenta({KlijentModel? klijent}) {
    final TextEditingController kNaziv = TextEditingController(text: klijent?.naziv ?? '');
    final TextEditingController kVlasnik = TextEditingController(text: klijent?.vlasnik ?? '');
    final TextEditingController kAdresa = TextEditingController(text: klijent?.adresa ?? '');
    final TextEditingController kGrad = TextEditingController(text: klijent?.grad ?? '');
    final TextEditingController kOib = TextEditingController(text: klijent?.oib ?? '');
    final TextEditingController kTel = TextEditingController(text: klijent?.telefon ?? '');
    final TextEditingController kEmail = TextEditingController(text: klijent?.email ?? '');
    bool kPdv = klijent?.uSustavuPdv ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(klijent == null ? 'Novi Klijent' : 'Uredi Klijenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: kNaziv, decoration: const InputDecoration(labelText: 'Naziv klijenta / agencije')),
                TextField(controller: kVlasnik, decoration: const InputDecoration(labelText: 'Vlasnik / Kontakt osoba')),
                TextField(controller: kAdresa, decoration: const InputDecoration(labelText: 'Adresa')),
                TextField(controller: kGrad, decoration: const InputDecoration(labelText: 'Grad')),
                TextField(controller: kOib, decoration: const InputDecoration(labelText: 'OIB')),
                TextField(controller: kTel, decoration: const InputDecoration(labelText: 'Telefon')),
                TextField(controller: kEmail, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                DropdownButtonFormField<bool>(
                  value: kPdv,
                  decoration: const InputDecoration(labelText: 'U sustavu PDV-a?'),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Da')),
                    DropdownMenuItem(value: false, child: Text('Ne')),
                  ],
                  onChanged: (val) => setDialogState(() => kPdv = val ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
            TextButton(
              onPressed: () {
                if (klijent == null) {
                  widget.klijenti.add(KlijentModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    naziv: kNaziv.text, vlasnik: kVlasnik.text, adresa: kAdresa.text,
                    grad: kGrad.text, oib: kOib.text, telefon: kTel.text, email: kEmail.text, uSustavuPdv: kPdv,
                  ));
                } else {
                  klijent.naziv = kNaziv.text;
                  klijent.vlasnik = kVlasnik.text;
                  klijent.adresa = kAdresa.text;
                  klijent.grad = kGrad.text;
                  klijent.oib = kOib.text;
                  klijent.telefon = kTel.text;
                  klijent.email = kEmail.text;
                  klijent.uSustavuPdv = kPdv;
                }
                widget.onUpdate();
                Navigator.pop(context);
              },
              child: const Text('Spremi'),
            ),
          ],
        ),
      ),
    );
  }

  void _potvrdiBrisanjeKlijenta(KlijentModel k) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brisanje klijenta'),
        content: Text('Da li stvarno želite obrisati klijenta "${k.naziv}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
          TextButton(
            onPressed: () {
              setState(() {
                widget.klijenti.removeWhere((element) => element.id == k.id);
              });
              widget.onUpdate();
              Navigator.pop(context);
            },
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Postavke Sustava', style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Prijevoznik'),
              Tab(text: 'Klijenti'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1) Prijevoznik
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: _pNaziv, decoration: const InputDecoration(labelText: 'Naziv tvrtke / obrta')),
                  TextField(controller: _pVlasnik, decoration: const InputDecoration(labelText: 'Vlasnik')),
                  TextField(controller: _pAdresa, decoration: const InputDecoration(labelText: 'Adresa')),
                  TextField(controller: _pGrad, decoration: const InputDecoration(labelText: 'Grad')),
                  TextField(controller: _pOib, decoration: const InputDecoration(labelText: 'OIB')),
                  TextField(controller: _pTel, decoration: const InputDecoration(labelText: 'Telefon')),
                  TextField(controller: _pEmail, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    value: _pPdv,
                    decoration: const InputDecoration(labelText: 'U sustavu PDV-a?'),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Da')),
                      DropdownMenuItem(value: false, child: Text('Ne')),
                    ],
                    onChanged: (val) => setState(() => _pPdv = val ?? true),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _spremiPrijevoznika, child: const Text('Spremi podatke o prijevozniku')),
                ],
              ),
            ),
            // 2) Klijenti
            Scaffold(
              body: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.klijenti.length,
                itemBuilder: (context, index) {
                  var k = widget.klijenti[index];
                  return Card(
                    child: ListTile(
                      title: Text(k.naziv.isEmpty ? 'Nepoznat klijent' : k.naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Grad: ${k.grad} | OIB: ${k.oib} | PDV: ${k.uSustavuPdv ? "Da" : "Ne"}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _urediIliDodajKlijenta(klijent: k)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _potvrdiBrisanjeKlijenta(k)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _urediIliDodajKlijenta(),
                backgroundColor: const Color(0xFF0284C7),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
