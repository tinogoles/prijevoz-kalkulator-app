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

  // Opći podaci
  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta po točkama');

  // Podaci prijevoznika
  final TextEditingController _nazivPrijevoznikaController = TextEditingController(text: 'Moj Prijevoz d.o.o.');
  final TextEditingController _vlasnikPrijevoznikaController = TextEditingController(text: 'Ivan Horvat');
  final TextEditingController _oibPrijevoznikaController = TextEditingController(text: '12345678901');
  final TextEditingController _adresaPrijevoznikaController = TextEditingController(text: 'Zagrebačka cesta 10, Zagreb');
  final TextEditingController _telefonPrijevoznikaController = TextEditingController(text: '+385 91 123 4567');
  final TextEditingController _emailPrijevoznikaController = TextEditingController(text: 'info@mojprijevoz.hr');

  // Podaci klijenta
  final TextEditingController _nazivKlijentaController = TextEditingController(text: 'Turistička agencija d.o.o.');
  final TextEditingController _vlasnikKlijentaController = TextEditingController(text: 'Marko Marić');
  final TextEditingController _oibKlijentaController = TextEditingController(text: '98765432109');
  final TextEditingController _adresaKlijentaController = TextEditingController(text: 'Riva 5, Split');
  final TextEditingController _telefonKlijentaController = TextEditingController(text: '+385 98 765 4321');
  final TextEditingController _emailKlijentaController = TextEditingController(text: 'info@klijent.hr');
  bool _klijentUSustavuPdv = true;

  // Ruta
  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Split');

  // Datumi i dani
  final TextEditingController _datumPolaskaController = TextEditingController(text: '2026-06-01');
  final TextEditingController _datumPovratkaController = TextEditingController(text: '2026-06-03');
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

  // Troškovi (bruto - s uključenim PDV-om)
  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.45');
  final TextEditingController _dnevnicaController = TextEditingController(text: '80');

  // Noćenje
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

  // Izračunate varijable troškova
  double _trosakGorivaBruto = 0;
  double _trosakGorivaPdv = 0;
  
  double _trosakCestarineBruto = 0;
  double _trosakCestarinePdv = 0;

  double _trosakVozaca = 0; // Dnevnice nemaju PDV (neoporezivo/izuzeto)

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
    _azurirajKilometreICestarinu();
  }

  void _preracunajBrojDana() {
    try {
      DateTime d1 = DateTime.parse(_datumPolaskaController.text.trim());
      DateTime d2 = DateTime.parse(_datumPovratkaController.text.trim());
      int razlika = d2.difference(d1).inDays + 1;
      setState(() {
        _izracunatiBrojDana = razlika > 0 ? razlika : 1;
      });
    } catch (_) {}
  }

  void _automatskiDetektirajCestarinu(List<String> tocke) {
    String spojeneTocke = tocke.join(' ').toLowerCase();

    for (var relacija in _bazaRelacijaCestarina) {
      List<String> kljucneRijeci = relacija['kljucneRijeci'];
      bool pogodak = kljucneRijeci.every((rijec) => spojeneTocke.contains(rijec));

      if (pogodak) {
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

      // 1. Gorivo (Bruto, Neto i PDV 25%)
      _trosakGorivaBruto = (km / 100) * potrosnjaNa100km * cijenaGorivaBruto;
      double gorivoNeto = _trosakGorivaBruto / 1.25;
      _trosakGorivaPdv = _trosakGorivaBruto - gorivoNeto;

      // 2. Cestarina (Bruto, Neto i PDV 25%)
      _trosakCestarineBruto = _koristiAutocestu ? cestarinaBruto : 0;
      double cestarinaNeto = _trosakCestarineBruto / 1.25;
      _trosakCestarinePdv = _trosakCestarineBruto - cestarinaNeto;

      // 3. Dnevnice vozača (Neoporezivo / nemaju PDV)
      _trosakVozaca = dnevnicaPoDanu * _izracunatiBrojDana;

      // 4. Noćenje (Bruto, Neto i PDV 25%)
      if (_tkoPlacaNocenje == 'Prijevoznik plaća') {
        _trosakNocenjaBruto = cijenaNocenjaBruto * brojNocenja;
      } else {
        _trosakNocenjaBruto = 0;
      }
      double nocenjeNeto = _trosakNocenjaBruto / 1.25;
      _trosakNocenjaPdv = _trosakNocenjaBruto - nocenjeNeto;

      // Ukupni ulazni PDV na troškove
      _ukupniUlazniPdv = _trosakGorivaPdv + _trosakCestarinePdv + _trosakNocenjaPdv;

      // Čisti trošak (zbroj neto vrijednosti troškova + dnevnice)
      _ukupniCistiTrosak = gorivoNeto + cestarinaNeto + _trosakVozaca + nocenjeNeto;
      
      // Planirana zarada
      _zarada = _ukupniCistiTrosak * (marzaPostotak / 100);
      
      // Osnovica za naplatu
      _osnovicaNeto = _ukupniCistiTrosak + _zarada;
      
      // Izlazni PDV i ukupna cijena
      if (_klijentUSustavuPdv) {
        _iznosIzlaznogPdv = _osnovicaNeto * 0.25;
        _ukupnaCijenaPonude = _osnovicaNeto + _iznosIzlaznogPdv;
      } else {
        _iznosIzlaznogPdv = 0;
        _ukupnaCijenaPonude = _osnovicaNeto;
      }
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
              pw.Divider(height: 15),
              pw.Text('Naziv kalkulacije: ${_nazivKalkulacijeController.text}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PRIJEVOZNIK:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text(_nazivPrijevoznikaController.text, style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Vlasnik: ${_vlasnikPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('OIB: ${_oibPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Adresa: ${_adresaPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KLIJENT / AGENCIJA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text(_nazivKlijentaController.text, style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('U sustavu PDV-a: ${_klijentUSustavuPdv ? "DA" : "NE"}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('OIB: ${_oibKlijentaController.text}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Adresa: ${_adresaKlijentaController.text}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(height: 15),
              pw.Text('Ruta: ${_dohvatiOpisRelacije()} (${_povratnoPutovanje ? "Povratno" : "Jednosmjerno"})'),
              pw.Text('Termin: ${_datumPolaskaController.text} do ${_datumPovratkaController.text} ($_izracunatiBrojDana dana)'),
              pw.Text('Vozilo: $_odabranoVozilo (${_kmController.text} km)'),
              pw.SizedBox(height: 12),
              pw.Table.fromTextArray(
                headers: ['Stavka troška (Bruto)', 'Iznos s PDV-om', 'Uključeni PDV (25%)'],
                data: [
                  ['Gorivo', '${_trosakGorivaBruto.toStringAsFixed(2)} €', '${_trosakGorivaPdv.toStringAsFixed(2)} €'],
                  ['Cestarina', '${_trosakCestarineBruto.toStringAsFixed(2)} €', '${_trosakCestarinePdv.toStringAsFixed(2)} €'],
                  ['Dnevnice vozača ($_izracunatiBrojDana dana)', '${_trosakVozaca.toStringAsFixed(2)} €', '0.00 € (neoporezivo)'],
                  ['Noćenje vozača', '${_trosakNocenjaBruto.toStringAsFixed(2)} €', '${_trosakNocenjaPdv.toStringAsFixed(2)} €'],
                  ['UKUPNO ULAZNI PDV', '---', '${_ukupniUlazniPdv.toStringAsFixed(2)} €'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(5),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                child: pw.Column(
                  children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Čisti troškovi (neto):'), pw.Text('${_ukupniCistiTrosak.toStringAsFixed(2)} €')]),
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Planirana marža (${_marzaController.text}%):'), pw.Text('${_zarada.toStringAsFixed(2)} €')]),
                    pw.Divider(),
                    if (_klijentUSustavuPdv) ...[
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Osnovica (neto):'), pw.Text('${_osnovicaNeto.toStringAsFixed(2)} €')]),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Izlazni PDV (25%):'), pw.Text('${_iznosIzlaznogPdv.toStringAsFixed(2)} €')]),
                      pw.Divider(),
                    ],
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('KONAČNA CIJENA ZA PONUDU:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${_ukupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                      ],
                    ),
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
                      pw.Text(_nazivPrijevoznikaController.text, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Adresa: ${_adresaPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('OIB: ${_oibPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Tel: ${_telefonPrijevoznikaController.text} | Email: ${_emailPrijevoznikaController.text}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('Predmet: ${_nazivKalkulacijeController.text}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Datum: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 20),
              pw.Text('Za klijenta:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('${_nazivKlijentaController.text} (Kontakt: ${_vlasnikKlijentaController.text})', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Adresa: ${_adresaKlijentaController.text} | OIB: ${_oibKlijentaController.text}', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SPECIFIKACIJA USLUGE', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 8),
                    pw.Text('Ruta: ${_dohvatiOpisRelacije()} (${_povratnoPutovanje ? "Povratno putovanje" : "Jednosmjerno"})', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Datum polaska: ${_datumPolaskaController.text}', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Datum povratka: ${_datumPovratkaController.text} (Trajanje: $_izracunatiBrojDana dana)', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Autocesta: ${_koristiAutocestu ? _odabranaAutocesta : "Lokalna cesta"}', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Kategorija vozila: $_odabranoVozilo', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange800,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  children: [
                    if (_klijentUSustavuPdv) ...[
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Cijena bez PDV-a (Osnovica):', style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                          pw.Text('${_osnovicaNeto.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('PDV (25%):', style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                          pw.Text('${_iznosIzlaznogPdv.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                        ],
                      ),
                      pw.Divider(color: PdfColors.white),
                    ],
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(_klijentUSustavuPdv ? 'UKUPNA CIJENA S PDV-om:' : 'UKUPNA CIJENA USLUGE:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.Text('${_ukupnaCijenaPonude.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      ],
                    ),
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
            // RUTA
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Planiranje Rute po Točkama (OSRM)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
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

            // DATUMI
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Termin i Trajanje Putovanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _datumPolaskaController,
                            decoration: const InputDecoration(labelText: 'Datum polaska (GGGG-MM-DD)', border: OutlineInputBorder()),
                            onChanged: (_) => _izracunajTroskove(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _datumPovratkaController,
                            decoration: const InputDecoration(labelText: 'Datum povratka (GGGG-MM-DD)', border: OutlineInputBorder()),
                            onChanged: (_) => _izracunajTroskove(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Izračunato trajanje:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('$_izracunatiBrojDana dana (${_izracunatiBrojDana > 1 ? _izracunatiBrojDana - 1 : 0} noćenja)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AUTOCESTA
            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Korištenje Autoceste i Cestarina (s PDV-om)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Hoće li se koristiti autocesta?', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        decoration: const InputDecoration(labelText: 'Sustav naplate / Autocesta', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                        items: _opcijeAutocesta.map((autocesta) => DropdownMenuItem(value: autocesta, child: Text(autocesta))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _odabranaAutocesta = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cestarinaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Iznos cestarine (€, bruto s PDV-om)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.toll), filled: true, fillColor: Colors.white),
                        onChanged: (_) => _izracunajTroskove(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NAZIV PONUDE
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
                      decoration: const InputDecoration(labelText: 'Naziv izleta / predmeta ponude', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bookmark), filled: true, fillColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PRIJEVOZNIK
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
                    TextField(controller: _nazivPrijevoznikaController, decoration: const InputDecoration(labelText: 'Naziv tvrtke / obrta', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _vlasnikPrijevoznikaController, decoration: const InputDecoration(labelText: 'Vlasnik / Odgovorna osoba', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _oibPrijevoznikaController, decoration: const InputDecoration(labelText: 'OIB Prijevoznika', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _telefonPrijevoznikaController, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _adresaPrijevoznikaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _emailPrijevoznikaController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // KLIJENT
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Podaci Klijenta / Agencije', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _nazivKlijentaController, decoration: const InputDecoration(labelText: 'Naziv Klijenta / Agencije', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<bool>(
                      value: _klijentUSustavuPdv,
                      decoration: const InputDecoration(labelText: 'U sustavu PDV-a?', border: OutlineInputBorder(), prefixIcon: Icon(Icons.receipt_long)),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Da (Iskazati PDV 25%)')),
                        DropdownMenuItem(value: false, child: Text('Ne (Samo ukupni iznos)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _klijentUSustavuPdv = val;
                            _izracunajTroskove();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _vlasnikKlijentaController, decoration: const InputDecoration(labelText: 'Kontakt osoba / Vlasnik', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _oibKlijentaController, decoration: const InputDecoration(labelText: 'OIB Klijenta', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _telefonKlijentaController, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: _adresaKlijentaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _emailKlijentaController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // VOZILO, GORIVO, NOĆENJE
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vozilo i Parametri Troškova (s PDV-om)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _odabranoVozilo,
                      decoration: const InputDecoration(labelText: 'Kategorija Vozila', border: OutlineInputBorder(), prefixIcon: Icon(Icons.directions_bus)),
                      items: _potrosnjaVozila.keys.map((String key) => DropdownMenuItem(value: key, child: Text(key))).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _odabranoVozilo = newValue;
                            _azurirajKilometreICestarinu();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaGorivaController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Gorivo (€/L, bruto)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _dnevnicaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dnevnica/dan (€)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Parametri Noćenja Vozača:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tkoPlacaNocenje,
                      decoration: const InputDecoration(labelText: 'Plaćanje noćenja', border: OutlineInputBorder()),
                      items: _opcijeNocenja.map((opcija) => DropdownMenuItem(value: opcija, child: Text(opcija))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _tkoPlacaNocenje = val;
                            _izracunajTroskove();
                          });
                        }
                      },
                    ),
                    if (_tkoPlacaNocenje == 'Prijevoznik plaća') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _cijenaNocenjaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cijena noćenja po noći (€, bruto)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.hotel)),
                        onChanged: (_) => _izracunajTroskove(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _marzaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.percent)),
                      onChanged: (_) => _izracunajTroskove(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SPREMANJE I REZULTATI
            ElevatedButton.icon(
              onPressed: _spremiKalkulaciju,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('1. KORAK: IZRADI I SPREMI KALKULACIJU', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            if (_kalkulacijaIzradena) ...[
              Card(
                color: const Color(0xFF0C4A6E),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rezultat kalkulacije: "${_nazivKalkulacijeController.text}"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                      const Divider(color: Colors.white24, height: 20),
                      _prikaziRedak('Trošak Goriva (bruto):', '${_trosakGorivaBruto.toStringAsFixed(2)} € (PDV: ${_trosakGorivaPdv.toStringAsFixed(2)} €)'),
                      _prikaziRedak('Trošak Cestarine (bruto):', '${_trosakCestarineBruto.toStringAsFixed(2)} € (PDV: ${_trosakCestarinePdv.toStringAsFixed(2)} €)'),
                      _prikaziRedak('Dnevnice vozača (${_izracunatiBrojDana} d.):', '${_trosakVozaca.toStringAsFixed(2)} €'),
                      _prikaziRedak('Noćenje vozača (bruto):', '${_trosakNocenjaBruto.toStringAsFixed(2)} € (PDV: ${_trosakNocenjaPdv.toStringAsFixed(2)} €)'),
                      _prikaziRedak('Ukupni PDV na troškove:', '${_ukupniUlazniPdv.toStringAsFixed(2)} €', color: Colors.amberAccent),
                      const Divider(color: Colors.white24, height: 20),
                      _prikaziRedak('Čisti Troškovi (neto):', '${_ukupniCistiTrosak.toStringAsFixed(2)} €', isBold: true),
                      _prikaziRedak('Planirana Zarada:', '${_zarada.toStringAsFixed(2)} €', color: Colors.amber),
                      const Divider(color: Colors.white24, height: 20),
                      if (_klijentUSustavuPdv) ...[
                        _prikaziRedak('Osnovica (Bez PDV-a):', '${_osnovicaNeto.toStringAsFixed(2)} €'),
                        _prikaziRedak('Izlazni PDV (25%):', '${_iznosIzlaznogPdv.toStringAsFixed(2)} €'),
                        const SizedBox(height: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFEA580C), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_klijentUSustavuPdv ? 'UKUPNA CIJENA S PDV-om:' : 'UKUPNA CIJENA USLUGE:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('${_ukupnaCijenaPonude.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _generirajInternuKalkulacijuPdf,
                icon: const Icon(Icons.archive, color: Colors.red),
                label: const Text('Spremi internu kalkulaciju (PDF Arhiva)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _generirajPdfPonudu,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('2. KORAK: GENERIRAJ PONUDU ZA KLIJENTA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _prikaziRedak(String naziv, String iznos, {bool isBold = false, Color color = Colors.white70}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(naziv, style: TextStyle(color: color, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(iznos, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
