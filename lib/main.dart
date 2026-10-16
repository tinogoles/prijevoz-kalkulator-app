import 'package:flutter/material.dart';
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
  final List<Map<String, dynamic>> _sluzbeneRelacije = [
    {
      'naziv': 'A1: Zagreb - Split (HAC)',
      'tocka1': 'Zagreb',
      'tocka2': '',
      'tocka3': '',
      'tocka4': 'Split',
      'kmJednosmjerno': 390.0,
      'cestarinaJednosmjerno': {
        'Kombi 8+1 (9L / 100km)': 17.50,
        'Mini bus <20 (15L / 100km)': 27.60,
        'Midi bus 35 (30L / 100km)': 41.85,
        'Veliki autobus 50 (35L / 100km)': 41.85,
      }
    },
    {
      'naziv': 'A2: Zagreb - Trakošćan (AZM)',
      'tocka1': 'Zagreb',
      'tocka2': '',
      'tocka3': '',
      'tocka4': 'Trakošćan',
      'kmJednosmjerno': 60.0,
      'cestarinaJednosmjerno': {
        'Kombi 8+1 (9L / 100km)': 4.00,
        'Mini bus <20 (15L / 100km)': 6.70,
        'Midi bus 35 (30L / 100km)': 10.00,
        'Veliki autobus 50 (35L / 100km)': 15.40,
      }
    },
    {
      'naziv': 'A3: Zagreb - Lipovac (HAC)',
      'tocka1': 'Zagreb',
      'tocka2': '',
      'tocka3': '',
      'tocka4': 'Lipovac',
      'kmJednosmjerno': 250.0,
      'cestarinaJednosmjerno': {
        'Kombi 8+1 (9L / 100km)': 18.60,
        'Mini bus <20 (15L / 100km)': 25.50,
        'Midi bus 35 (30L / 100km)': 37.40,
        'Veliki autobus 50 (35L / 100km)': 37.40,
      }
    },
    {
      'naziv': 'Međunarodna: Zagreb - Ljubljana (SLO)',
      'tocka1': 'Zagreb',
      'tocka2': '',
      'tocka3': '',
      'tocka4': 'Ljubljana',
      'kmJednosmjerno': 140.0,
      'cestarinaJednosmjerno': {
        'Kombi 8+1 (9L / 100km)': 16.00,
        'Mini bus <20 (15L / 100km)': 25.00,
        'Midi bus 35 (30L / 100km)': 40.00,
        'Veliki autobus 50 (35L / 100km)': 40.00,
      }
    },
  ];

  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Split');
  final TextEditingController _nazivPrijevoznikaController = TextEditingController(text: 'Moj Prijevoz d.o.o.');
  final TextEditingController _oibPrijevoznikaController = TextEditingController(text: '12345678901');
  final TextEditingController _adresaPrijevoznikaController = TextEditingController(text: 'Zagrebačka cesta 10, Zagreb');

  final TextEditingController _nazivKlijentaController = TextEditingController(text: 'Turistička agencija / Klijent');
  final TextEditingController _kontaktKlijentaController = TextEditingController(text: 'info@klijent.com');

  // 4 zasebna polja za lokacije rute
  final TextEditingController _tocka1Controller = TextEditingController(text: 'Zagreb');
  final TextEditingController _tocka2Controller = TextEditingController();
  final TextEditingController _tocka3Controller = TextEditingController();
  final TextEditingController _tocka4Controller = TextEditingController(text: 'Split');

  final TextEditingController _datumPolaskaController = TextEditingController(text: '2026-06-01');
  final TextEditingController _datumPovratkaController = TextEditingController(text: '2026-06-03');
  
  double _bazaKmJednosmjerno = 390.0;
  double _bazaCestarinaJednosmjerno = 17.50;
  bool _povratnoPutovanje = true; 

  final TextEditingController _kmController = TextEditingController(text: '780'); 
  final TextEditingController _cestarinaController = TextEditingController(text: '35.00'); 

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

  Future<void> _izracunajRutuMultiPoint() async {
    List<String> aktivneTocke = [];
    
    if (_tocka1Controller.text.trim().isNotEmpty) aktivneTocke.add(_tocka1Controller.text.trim());
    if (_tocka2Controller.text.trim().isNotEmpty) aktivneTocke.add(_tocka2Controller.text.trim());
    if (_tocka3Controller.text.trim().isNotEmpty) aktivneTocke.add(_tocka3Controller.text.trim());
    if (_tocka4Controller.text.trim().isNotEmpty) aktivneTocke.add(_tocka4Controller.text.trim());

    if (aktivneTocke.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite barem Polazište (1) i Konačno odredište (4).'), backgroundColor: Colors.orange),
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
      for (String tocka in aktivneTocke) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izračunato (${aktivneTocke.length} točke): ${kmJedanSmjer.toStringAsFixed(1)} km (1 smjer)'), backgroundColor: Colors.green),
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
    _cestarinaController.text = (_bazaCestarinaJednosmjerno * faktor).toStringAsFixed(2);
    _izracunajTroskove();
  }

  void _primjeniSluzbenuRelaciju(Map<String, dynamic> relacija) {
    setState(() {
      _tocka1Controller.text = relacija['tocka1'];
      _tocka2Controller.text = relacija['tocka2'];
      _tocka3Controller.text = relacija['tocka3'];
      _tocka4Controller.text = relacija['tocka4'];
      _bazaKmJednosmjerno = relacija['kmJednosmjerno'];
      
      Map<String, dynamic> cestarineMap = relacija['cestarinaJednosmjerno'];
      if (cestarineMap.containsKey(_odabranoVozilo)) {
        _bazaCestarinaJednosmjerno = cestarineMap[_odabranoVozilo];
      }

      _nazivKalkulacijeController.text = relacija['naziv'] + (_povratnoPutovanje ? ' (Povratno)' : ' (Jednosmjerno)');
      _azurirajKilometreICestarinu();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Učitano iz cjenika: ${relacija['naziv']}'), backgroundColor: Colors.blue),
    );
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
      _trosakCestarine = cestarina;
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
                        Text('Pretrazivac cjenika (A1 HAC, A2 AZM, A3 HAC)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Odaberite relaciju s autocesta za automatski unos cestarina i kilometara:', style: TextStyle(fontSize: 12, color: Colors.black87)),
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vozilo i Planiranje Rute (do 4 točke)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            _azurirajKilometreICestarinu();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Definiranje točaka rute (Sekvencijalno):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0284C7))),
                    const SizedBox(height: 8),
                    TextField(controller: _tocka1Controller, decoration: const InputDecoration(labelText: '1) Polazište (obavezno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.trip_origin))),
                    const SizedBox(height: 8),
                    TextField(controller: _tocka2Controller, decoration: const InputDecoration(labelText: '2) Međuodredište A (opcionalno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_location_alt_outlined))),
                    const SizedBox(height: 8),
                    TextField(controller: _tocka3Controller, decoration: const InputDecoration(labelText: '3) Međuodredište B (opcionalno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_location_alt_outlined))),
                    const SizedBox(height: 8),
                    TextField(controller: _tocka4Controller, decoration: const InputDecoration(labelText: '4) Konačno odredište (obavezno)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
                      icon: _isLoadingRoute 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Icon(Icons.route, color: Colors.white),
                      label: Text(_isLoadingRoute ? 'Izračunavam sve dionice...' : 'Izračunaj kilometre po točkama (1->2->3->4)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Povratno putovanje (U oba smjera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Automatski množi kilometre i cestarinu s 2', style: TextStyle(fontSize: 12)),
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
                      onChanged: (_) => _izracunajTroskove(),
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
                    const Text('Parametri Troskova i Marza (Interno)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaGorivaController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Gorivo (€/L)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_gas_station)), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _cestarinaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cestarina (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.toll)), onChanged: (_) => _izracunajTroskove())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _dnevnicaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dnevnica/dan (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _brojDanaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Broj dana', border: OutlineInputBorder(), prefixIcon: Icon(Icons.date_range)), onChanged: (_) => _izracunajTroskove())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaNocenjaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nocenje / noc (€)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.hotel)), onChanged: (_) => _izracunajTroskove())),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tkoPlacaNocenje,
                            decoration: const InputDecoration(labelText: 'Nocenje placa', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'Prijevoznik placa', child: Text('Prijevoznik')),
                              DropdownMenuItem(value: 'Klijent snosi trosak', child: Text('Klijent')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _tkoPlacaNocenje = val
