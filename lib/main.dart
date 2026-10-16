import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
          seedColor: const Color(0xFF0284C7), // Adriatic plava
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFEA580C), // Terracotta narančasta
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
  // Službena baza relacija i cestarina za A1, A2, A3 i regionalne rute
  final List<Map<String, dynamic>> _sluzbeneRelacije = [
    {
      'naziv': 'A1: Zagreb - Split',
      'polaziste': 'Zagreb',
      'odrediste': 'Split',
      'km': 780.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 35.00,       // Skupina II
        'Mini bus <20 (15L / 100km)': 55.20,    // Skupina III
        'Midi bus 35 (30L / 100km)': 83.70,     // Skupina IV
        'Veliki autobus 50 (35L / 100km)': 83.70, // Skupina IV
      }
    },
    {
      'naziv': 'A1: Zagreb - Zadar',
      'polaziste': 'Zagreb',
      'odrediste': 'Zadar',
      'km': 560.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 25.00,
        'Mini bus <20 (15L / 100km)': 37.00,
        'Midi bus 35 (30L / 100km)': 57.30,
        'Veliki autobus 50 (35L / 100km)': 57.30,
      }
    },
    {
      'naziv': 'A2: Zagreb - Macelj (Trakošćan)',
      'polaziste': 'Zagreb (Zaprešić)',
      'odrediste': 'Trakošćan',
      'km': 120.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 9.00,         // Skupina II
        'Mini bus <20 (15L / 100km)': 15.40,    // Skupina III
        'Midi bus 35 (30L / 100km)': 30.10,     // Skupina IV
        'Veliki autobus 50 (35L / 100km)': 30.10, // Skupina IV
      }
    },
    {
      'naziv': 'A3: Zagreb - Slavonski Brod',
      'polaziste': 'Zagreb istok',
      'odrediste': 'Slavonski Brod',
      'km': 380.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 23.80,        // Skupina II (ovisi o ulazu/izlazu)
        'Mini bus <20 (15L / 100km)': 32.80,    // Skupina III
        'Midi bus 35 (30L / 100km)': 48.20,     // Skupina IV
        'Veliki autobus 50 (35L / 100km)': 48.20, // Skupina IV
      }
    },
    {
      'naziv': 'A3: Zagreb - Lipovac',
      'polaziste': 'Zagreb istok',
      'odrediste': 'Lipovac',
      'km': 500.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 37.20,        // Skupina II
        'Mini bus <20 (15L / 100km)': 51.00,    // Skupina III
        'Midi bus 35 (30L / 100km)': 74.80,     // Skupina IV
        'Veliki autobus 50 (35L / 100km)': 74.80, // Skupina IV
      }
    },
    {
      'naziv': 'Međunarodna: Zagreb - Ljubljana (SLO)',
      'polaziste': 'Zagreb',
      'odrediste': 'Ljubljana',
      'km': 280.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 16.00,
        'Mini bus <20 (15L / 100km)': 25.00,
        'Midi bus 35 (30L / 100km)': 40.00,
        'Veliki autobus 50 (35L / 100km)': 40.00,
      }
    },
    {
      'naziv': 'Međunarodna: Zagreb - Sarajevo (BiH)',
      'polaziste': 'Zagreb',
      'odrediste': 'Sarajevo',
      'km': 800.0,
      'cestarine': {
        'Kombi 8+1 (9L / 100km)': 20.00,
        'Mini bus <20 (15L / 100km)': 35.00,
        'Midi bus 35 (30L / 100km)': 55.00,
        'Veliki autobus 50 (35L / 100km)': 55.00,
      }
    },
  ];

  // Kontroleri
  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Split (A1)');
  final TextEditingController _nazivPrijevoznikaController = TextEditingController(text: 'Moj Prijevoz d.o.o.');
  final TextEditingController _oibPrijevoznikaController = TextEditingController(text: '12345678901');
  final TextEditingController _adresaPrijevoznikaController = TextEditingController(text: 'Zagrebačka cesta 10, Zagreb');

  final TextEditingController _nazivKlijentaController = TextEditingController(text: 'Turistička agencija / Klijent');
  final TextEditingController _kontaktKlijentaController = TextEditingController(text: 'info@klijent.com');

  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odredisteController = TextEditingController(text: 'Split');
  final TextEditingController _datumPolaskaController = TextEditingController(text: '2026-06-01');
  final TextEditingController _datumPovratkaController = TextEditingController(text: '2026-06-03');
  final TextEditingController _kmController = TextEditingController(text: '780');
  final TextEditingController _cestarinaController = TextEditingController(text: '35.00');
  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.45');
  final TextEditingController _dnevnicaController = TextEditingController(text: '80');
  final TextEditingController _brojDanaController = TextEditingController(text: '3');
  
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  String _tkoPlacaNocenje = 'Prijevoznik plaća'; 
  final TextEditingController _marzaController = TextEditingController(text: '20');

  // Točne kategorije vozila i potrošnja (L/100km)
  final Map<String, double> _potrosnjaVozila = {
    'Kombi 8+1 (9L / 100km)': 9.0,
    'Mini bus <20 (15L / 100km)': 15.0,
    'Midi bus 35 (30L / 100km)': 30.0,
    'Veliki autobus 50 (35L / 100km)': 35.0,
  };

  late String _odabranoVozilo;

  double _trosakGoriva = 0;
  double _trosakCestarine = 0;
  double _trosakVozača = 0;
  double _trosakNocenja = 0;
  double _ukupniCistiTrosak = 0;
  double _zarada = 0;
  double _UkupnaCijenaPonude = 0;
  
  bool _kalkulacijaIzradena = false;

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;
    _izracunajTroškove();
  }

  // Automatska primjena službene relacije i cestarine prema odabranom vozilu
  void _primjeniSluzbenuRelaciju(Map<String, dynamic> relacija) {
    setState(() {
      _polazisteController.text = relacija['polaziste'];
      _odredisteController.text = relacija['odrediste'];
      _kmController.text = relacija['km'].toString();
      
      Map<String, dynamic> cestarineMap = relacija['cestarine'];
      if (cestarineMap.containsKey(_odabranoVozilo)) {
        _cestarinaController.text = cestarineMap[_odabranoVozilo].toString();
      }

      _nazivKalkulacijeController.text = relacija['naziv'];
      _izracunajTroškove();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Učitano iz cjenika: ${relacija['naziv']}'), backgroundColor: Colors.blue),
    );
  }

  void _izracunajTroškove() {
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
      _trosakCestarine = cestarina;
      _trosakVozača = dnevnicaPoDanu * (brojDana > 0 ? brojDana : 1);

      if (_tkoPlacaNocenje == 'Prijevoznik plaća') {
        _trosakNocenja = cijenaNocenjaPoDanu * brojNocenja;
      } else {
        _trosakNocenja = 0;
      }

      _ukupniCistiTrosak = _trosakGoriva + _trosakCestarine + _trosakVozača + _trosakNocenja;
      _zarada = _ukupniCistiTrosak * (marzaPostotak / 100);
      _UkupnaCijenaPonude = _ukupniCistiTrosak + _zarada;
    });
  }

  void _spremiKalkulaciju() {
    _izracunajTroškove();
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
              pw.Text('Relacija: ${_polazisteController.text} -${_odredisteController.text}'),
              pw.Text('Vozilo: $_odabranoVozilo (${_kmController.text} km)'),
              pw.SizedBox(height: 15),
              pw.Table.fromTextArray(
                headers: ['Stavka troška', 'Iznos'],
                data: [
                  ['Gorivo', '${_trosakGoriva.toStringAsFixed(2)} €'],
                  ['Cestarina (A1/A2/A3 cjenik)', '${_trosakCestarine.toStringAsFixed(2)} €'],
                  ['Dnevnice vozača', '${_trosakVozača.toStringAsFixed(2)} €'],
                  ['Noćenje', '${_trosakNocenja.toStringAsFixed(2)} € ($_tkoPlacaNocenje)'],
                  ['Čisti troškovi ukupno', '${_ukupniCistiTrosak.toStringAsFixed(2)} €'],
                  ['Planirana marža (${_marzaController.text}\%)', '${_zarada.toStringAsFixed(2)} €'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
                cellPadding: const EdgeInsets.all(6),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('KONAČNA CIJENA ZA KLIJENTA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${_UkupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
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
                padding: const EdgeInsets.all(15),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200, 
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SPECIFIKACIJA USLUGE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 10),
                    pw.Text('Relacija: ${_polazisteController.text} -${_odredisteController.text}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Tip vozila: $_odabranoVozilo', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Datum polaska: ${_datumPolaskaController.text}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Datum povratka: ${_datumPovratkaController.text}', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const EdgeInsets.all(15),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange800, 
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('UKUPNA CIJENA USLUGE:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text('${_UkupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
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
            // PRETRAŽIVAČ SLUŽBENIH CESTARINA (A1 HAC, A2 AZM, A3 HAC)
            Card(
              elevation: 3,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFFEA580C)),
                        SizedBox(width: 8),
                        Text('Pretraživač cjenika (A1, A2, A3 i regija)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Odaberite relaciju s autocesta (HAC A1/A3, AZM A2) za automatski unos cestarina i kilometara:', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: const InputDecoration(
                        labelText: 'Brzi odabir relacije iz cjenika',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _sluzbeneRelacije.map((relacija) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: relacija,
                          child: Text(relacija['naziv'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                      onChanged: (selectedRelacija) {
                        if (selectedRelacija != null) {
                          _primjeniSluzbenuRelaciju(selectedRelacija);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Naziv Kalkulacije
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
                        labelText: 'Naziv (npr. Izlet Split A1)',
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

            // Podaci prijevoznika
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Podaci Prijevoznika', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nazivPrijevoznikaController, decoration: const InputDecoration(labelText: 'Naziv Prijevoznika', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _oibPrijevoznikaController, decoration: const InputDecoration(labelText: 'OIB', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _adresaPrijevoznikaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Podaci klijenta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Podaci Klijenta (Agencije)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nazivKlijentaController, decoration: const InputDecoration(labelText: 'Naziv Klijenta', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 12),
                    TextField(controller: _kontaktKlijentaController, decoration: const InputDecoration(labelText: 'Kontakt (Email / Tel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.contact_mail))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vozilo, Relacija i Datumi
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vozilo, Relacija i Datumi Puta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _odabranoVozilo,
                      decoration: const InputDecoration(labelText: 'Kategorija Vozila', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_bus)),
                      items: _potrosnjaVozila.keys.map((String key) {
                        return DropdownMenuItem<String>(value: key, child: Text(key, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _odabranoVozilo = newValue;
                            _izracunajTroškove();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _polazisteController, decoration: const InputDecoration(labelText: 'Polazište', border: OutlineInputBorder(), prefixIcon: Icon(Icons.trip_origin)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _odredisteController, decoration: const InputDecoration(labelText: 'Odredište', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _datumPolaskaController, decoration: const InputDecoration(labelText: 'Datum polaska', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _datumPovratkaController, decoration: const InputDecoration(labelText: 'Datum povratka', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event)))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ukupno Kilometara', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed), suffixText: 'km'),
                      onChanged: (_) => _izracunajTroškove(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parametri troškova
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parametri Troškova i Marža (Interno)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaGorivaController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Gorivo (€/L)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_gas_station)), onChanged: (_) => _izracunajTroškove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _cestarinaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cestarina (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.toll)), onChanged: (_) => _izracunajTroškove())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _dnevnicaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dnevnica/dan (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), onChanged: (_) => _izracunajTroškove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _brojDanaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Broj dana', border: OutlineInputBorder(), prefixIcon: Icon(Icons.date_range)), onChanged: (_) => _izracunajTroškove())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaNocenjaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Noćenje / noć (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.hotel)), onChanged: (_) => _izracunajTroškove())),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tkoPlacaNocenje,
                            decoration: const InputDecoration(labelText: 'Noćenje plaća', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'Prijevoznik plaća', child: Text('Prijevoznik')),
                              DropdownMenuItem(value: 'Klijent snosi trošak', child: Text('Klijent')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _tkoPlacaNocenje = val;
                                  _izracunajTroškove();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _marzaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.percent)),
                      onChanged: (_) => _izracunajTroškove(),
                    ),
                  ],
                ),
              ),
            ),
            const
