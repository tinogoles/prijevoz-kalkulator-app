import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PrijevozKalkulatorApp());
}

class PrijevozKalkulatorApp extends StatelessWidget {
  const PrijevozKalkulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator i Ponude za Prijevoz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFEA580C),
        ),
        useMaterial3: true,
      ),
      home: const KalkulatorHomeScreen(),
    );
  }
}

class KalkulatorHomeScreen extends StatefulWidget {
  const KalkulatorHomeScreen({super.key});

  @override
  State<KalkulatorHomeScreen> createState() => _KalkulatorHomeScreenState();
}

class _KalkulatorHomeScreenState extends State<KalkulatorHomeScreen> {
  final List<Map<String, dynamic>> _bazaRelacijaCestarina = [
    {
      'kljucneRijeci': ['zagreb', 'split'],
      'nazivAutoceste': 'HAC (Hrvatske autoceste)',
      'kmJednosmjerno': 390.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 17.50,
        'Mini bus <20 (15L / 100km)': 27.60,
        'Midi bus 35 (30L / 100km)': 41.85,
        'Veliki autobus 50 (35L / 100km)': 41.85,
      }
    },
    {
      'kljucneRijeci': ['zagreb', 'trakošćan', 'trakoscan'],
      'nazivAutoceste': 'AZM (Zagreb - Macelj)',
      'kmJednosmjerno': 60.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 4.00,
        'Mini bus <20 (15L / 100km)': 6.70,
        'Midi bus 35 (30L / 100km)': 10.00,
        'Veliki autobus 50 (35L / 100km)': 15.40,
      }
    },
    {
      'kljucneRijeci': ['zagreb', 'lipovac'],
      'nazivAutoceste': 'HAC (Hrvatske autoceste)',
      'kmJednosmjerno': 250.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 18.60,
        'Mini bus <20 (15L / 100km)': 25.50,
        'Midi bus 35 (30L / 100km)': 37.40,
        'Veliki autobus 50 (35L / 100km)': 37.40,
      }
    },
    {
      'kljucneRijeci': ['zagreb', 'ljubljana'],
      'nazivAutoceste': 'DARS (Slovenske autoceste)',
      'kmJednosmjerno': 140.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 16.00,
        'Mini bus <20 (15L / 100km)': 25.00,
        'Midi bus 35 (30L / 100km)': 40.00,
        'Veliki autobus 50 (35L / 100km)': 40.00,
      }
    },
  ];

  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta po točkama');
  final TextEditingController _nazivPrijevoznikaController = TextEditingController(text: 'Moj Prijevoz d.o.o.');
  final TextEditingController _oibPrijevoznikaController = TextEditingController(text: '12345678901');
  final TextEditingController _adresaPrijevoznikaController = TextEditingController(text: 'Zagrebačka cesta 10, Zagreb');

  final TextEditingController _nazivKlijentaController = TextEditingController(text: 'Turistička agencija / Klijent');
  final TextEditingController _kontaktKlijentaController = TextEditingController(text: 'info@klijent.com');

  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Split');

  final TextEditingController _datumPolaskaController = TextEditingController(text: '2026-06-01');
  final TextEditingController _datumPovratkaController = TextEditingController(text: '2026-06-03');
  
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
  final TextEditingController _brojDanaController = TextEditingController(text: '3');
  
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  String _tkoPlacaNocenje = 'Prijevoznik placa'; 
  final TextEditingController _marzaController = TextEditingController(text: '20');

  final Map<String, double> _potrosnjaVozila = {
    'Kombi 8+1 (9L / 100km)': 9.0,
    'Mini bus <20 (15L / 100km)': 15.0,
    'Midi bus 35 (30L / 100km)': 30.0,
    'Veliki autobus 50 (35L / 100km)': 35.0,
  };

  late String _odabranoVozilo;

  double _trosakGoriva = 0;
  double _trosakCestarine = 0;
  double _trosakVozaca = 0;
  double _trosakNocenja = 0;
  double _ukupniCistiTrosak = 0;
  double _zarada = 0;
  double _ukupnaCijenaPonude = 0;
  
  bool _kalkulacijaIzradena = false;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;
    _azurirajKilometreICestarinu();
  }

  void _automatskiDetektirajCestarinu(List<String> tocke) {
    String spojeneTocke = tocke.join(' ').toLowerCase();
    bool pronadeno = false;

    for (var relacija in _bazaRelacijaCestarina) {
      List<String> kljucneRijeci = relacija['kljucneRijeci'];
      bool pogodak = kljucneRijeci.every((rijec) => spojeneTocke.contains(rijec));

      if (pogodak) {
        pronadeno = true;
        setState(() {
          _koristiAutocestu = true;
          _odabranaAutocesta = relacija['nazivAutoceste'];
          Map<String, dynamic> cestarineMap = relacija['cestarine'];
          if (cestarineMap.containsKey(_odabranoVozilo)) {
            double jednosmjernaCestarina = cestarineMap[_odabranoVozilo];
            double faktor = _povratnoPutovanje ? 2.0 : 1.0;
            _cestarinaController.text = (jednosmjernaCestarina * faktor).toStringAsFixed(2);
          }
        });
        break;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite barem Polazište i Konačno odredište.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      Future<Map<String, double>?> getCoords(String query) async {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
        final response = await http.get(url, headers: {'User-Agent': 'PrijevozKalkulatorApp'});
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          if (data.isNotEmpty) {
            return {
              'lat': double.parse(data[0]['lat']),
              'lon': double.parse(data[0]['lon']),
            };
          }
        }
        return null;
      }

      List<Map<String, double>> koordinate = [];
      for (String tocka in tocke) {
        var c = await getCoords(tocka);
        if (c != null) {
          koordinate.add(c);
        } else {
          throw Exception('Lokacija "$tocka" nije pronađena.');
        }
      }

      double ukupnoMetara = 0;
      for (int i = 0; i < koordinate.length - 1; i++) {
        var start = koordinate[i];
        var end = koordinate[i + 1];

        final osrmUrl = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/${start['lon']},${start['lat']};${end['lon']},${end['lat']}?overview=false',
        );

        final osrmResponse = await http.get(osrmUrl);
        if (osrmResponse.statusCode == 200) {
          final osrmData = json.decode(osrmResponse.body);
          if (osrmData['code'] == 'Ok') {
            ukupnoMetara += osrmData['routes'][0]['distance'];
          }
        }
      }

      double kmJedanSmjer = ukupnoMetara / 1000.0;

      setState(() {
        _bazaKmJednosmjerno = kmJedanSmjer;
        _azurirajKilometreICestarinu();
      });

      _automatskiDetektirajCestarinu(tocke);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izračunato (${tocke.length} točke): ${kmJedanSmjer.toStringAsFixed(1)} km (1 smjer)'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _azurirajKilometreICestarinu() {
    double faktor = _povratnoPutovanje ? 2.0 : 1.0;
    _kmController.text = (_bazaKmJednosmjerno * faktor).toStringAsFixed(0);
    
    if (!_koristiAutocestu) {
      _cestarinaController.text = '0.00';
    }
    
    _izracunajTroskove();
  }

  String _dohvatiOpisRelacije() {
    List<String> dijelovi = [];
    if (_polazisteController.text.isNotEmpty) dijelovi.add(_polazisteController.text);
    if (_odrediste1Controller.text.isNotEmpty) dijelovi.add(_odrediste1Controller.text);
    if (_odrediste2Controller.text.isNotEmpty) dijelovi.add(_odrediste2Controller.text);
    if (_konacnoOdredisteController.text.isNotEmpty) dijelovi.add(_konacnoOdredisteController.text);
    
    String relacijaTekst = dijelovi.join(' -> ');
    return relacijaTekst.isEmpty ? 'Nije definirano' : relacijaTekst;
  }

  void _izracunajTroskove() {
    setState(() {
      double km = double.tryParse(_kmController.text) ?? 0;
      double cestarina = double.tryParse(_cestarinaController.text) ?? 0;
      double cijenaGoriva = double.tryParse(_cijenaGorivaController.text) ?? 0;
      double dnevnicaPoDanu = double.tryParse(_dnevnicaController.text) ?? 0;
      int brojDana = int.tryParse(_brojDanaController.text) ?? 1;
      
      double cijenaNocenjaPoDanu = double.tryParse(_cijenaNocenjaController.text) ?? 0;
      double marzaPostotak = double.tryParse(_marzaController.text) ?? 0;

      double potrosnjaNa100km = _potrosnjaVozila[_odabranoVozilo] ?? 9.0;
      int brojNocenja = (brojDana > 1) ? (brojDana - 1) : 0;

      _trosakGoriva = (km / 100) * potrosnjaNa100km * cijenaGoriva;
      _trosakCestarine = _koristiAutocestu ? cestarina : 0;
      _trosakVozaca = dnevnicaPoDanu * (brojDana > 0 ? brojDana : 1);

      if (_tkoPlacaNocenje == 'Prijevoznik placa') {
        _trosakNocenja = cijenaNocenjaPoDanu * brojNocenja;
      } else {
        _trosakNocenja = 0;
      }

      _ukupniCistiTrosak = _trosakGoriva + _trosakCestarine + _trosakVozaca + _trosakNocenja;
      _zarada = _ukupniCistiTrosak * (marzaPostotak / 100);
      _ukupnaCijenaPonude = _ukupniCistiTrosak + _zarada;
    });
  }

  void _spremiKalkulaciju() {
    _izracunajTroskove();
    setState(() {
      _kalkulacijaIzradena = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kalkulacija "${_nazivKalkulacijeController.text}" uspješno spremljena!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _generirajInternuKalkulacijuPdf() async {
    final pdf = pw.Document();
    final String idKalkulacije = 'KALK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INTERNA KALKULACIJA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  pw.Text('ID: $idKalkulacije', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(height: 20),
              pw.Text('Naziv: ${_nazivKalkulacijeController.text}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Klijent: ${_nazivKlijentaController.text}'),
              pw.Text('Ruta: ${_dohvatiOpisRelacije()} (${_povratnoPutovanje ? "Povratno putovanje" : "Jednosmjerno"})'),
              pw.Text('Autocesta: ${_koristiAutocestu ? _odabranaAutocesta : "Bez korištenja autoceste"}'),
              pw.Text('Vozilo: $_odabranoVozilo (${_kmController.text} km ukupno)'),
              pw.SizedBox(height: 15),
              pw.Table.fromTextArray(
                headers: ['Stavka troska', 'Iznos'],
                data: [
                  ['Gorivo', '${_trosakGoriva.toStringAsFixed(2)} €'],
                  ['Cestarina', '${_trosakCestarine.toStringAsFixed(2)} €'],
                  ['Dnevnice vozaca', '${_trosakVozaca.toStringAsFixed(2)} €'],
                  ['Nocenje', '${_trosakNocenja.toStringAsFixed(2)} € ($_tkoPlacaNocenje)'],
                  ['Cisti troskovi ukupno', '${_ukupniCistiTrosak.toStringAsFixed(2)} €'],
                  ['Planirana marza (${_marzaController.text}\%)', '${_zarada.toStringAsFixed(2)} €'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
                cellPadding: const pw.EdgeInsets.all(6),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('KONACNA CIJENA ZA KLIJENTA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${_ukupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kalkulacija_${_nazivKalkulacijeController.text}.pdf',
    );
  }

  Future<void> _generirajPdfPonudu() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(_nazivPrijevoznikaController.text, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Adresa: ${_adresaPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('OIB: ${_oibPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('Predmet: ${_nazivKalkulacijeController.text}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Datum: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 30),
              pw.Text('Za klijenta:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Naziv: ${_nazivKlijentaController.text}'),
              pw.Text('Kontakt: ${_kontaktKlijentaController.text}'),
              pw.SizedBox(height: 25),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200, 
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SPECIFIKACIJA USLUGE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 10),
                    pw.Text('Ruta: ${_dohvatiOpisRelacije()} (${_povratnoPutovanje ? "Povratno putovanje" : "Jednosmjerno"})', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Autocesta: ${_koristiAutocestu ? _odabranaAutocesta : "Lokalna cesta (bez autoceste)"}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Tip vozila: $_odabranoVozilo', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Datum polaska: ${_datumPolaskaController.text}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Datum povratka: ${_datumPovratkaController.text}', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.all(15),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange800, 
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('UKUPNA CIJENA USLUGE:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text('${_ukupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text('Zahvaljujemo na povjerenju! Ponuda vrijedi 15 dana od datuma izdavanja.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ponuda_${_nazivKalkulacijeController.text}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Prijevoza (HR, SLO, BiH)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Planiranje Rute po Točkama (Primarno)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 8),
                    const Text('Unesite relaciju (Polazište -> Međuodredišta -> Konačno odredište):', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 12),
                    TextField(controller: _polazisteController, decoration: const InputDecoration(labelText: '1) Polazište (obavezno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.trip_origin))),
                    const SizedBox(height: 8),
                    TextField(controller: _odrediste1Controller, decoration: const InputDecoration(labelText: '2) Međuodredište A (opcionalno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_location_alt_outlined))),
                    const SizedBox(height: 8),
                    TextField(controller: _odrediste2Controller, decoration: const InputDecoration(labelText: '3) Međuodredište B (opcionalno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_location_alt_outlined))),
                    const SizedBox(height: 8),
                    TextField(controller: _konacnoOdredisteController, decoration: const InputDecoration(labelText: '4) Konačno odredište (obavezno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))),
                    const SizedBox(height: 12),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
                      icon: _isLoadingRoute 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Icon(Icons.route, color: Colors.white),
                      label: Text(_isLoadingRoute ? 'Izračunavam dionice...' : 'Izračunaj kilometre po točkama (OSRM)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Povratno putovanje (U oba smjera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Automatski množi kilometre s 2', style: TextStyle(fontSize: 12)),
                      value: _povratnoPutovanje,
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool? value) {
                        setState(() {
                          _povratnoPutovanje = value ?? true;
                          _azurirajKilometreICestarinu();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ukupno Kilometara', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed), suffixText: 'km'),
                      onChanged: (_) => _izracunajTroskove(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Korištenje Autoceste i Cestarina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Hoće li se koristiti autocesta?', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatski uključeno prema ruti (možete ručno isključiti)', style: TextStyle(fontSize: 11)),
                      value: _koristiAutocestu,
                      activeColor: const Color(0xFFEA580C),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (bool value) {
                        setState(() {
                          _koristiAutocestu = value;
                          _azurirajKilometreICestarinu();
                        });
                      },
                    ),
                    if (_koristiAutocestu) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _odabranaAutocesta,
                        decoration: const InputDecoration(
                          labelText: 'Odabrani sustav naplate / autocesta',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _opcijeAutocesta.map((autocesta) {
                          return DropdownMenuItem<String>(
                            value: autocesta,
                            child: Text(autocesta, style: const TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _odabranaAutocesta = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cestarinaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Iznos cestarine (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.toll),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (_) => _izracunajTroskove(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Naziv kalkulacije / ponude', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nazivKalkulacijeController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bookmark),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Podaci Prijevoznika i Klijenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nazivPrijevoznikaController, decoration: const InputDecoration(labelText: 'Naziv Prijevoznika', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business))),
                    const SizedBox(height: 12),
                    TextField(controller: _nazivKlijentaController, decoration: const InputDecoration(labelText: 'Naziv Klijenta / Agencije', border: OutlineInputBorder(), prefix
