import 'package:flutter/material.dart';

void main() {
  runApp(const PrijevozKalkulatorApp());
}

class PrijevozKalkulatorApp extends StatelessWidget {
  const PrijevozKalkulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Prijevoza',
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
  // Kontroleri za podatke prijevoznika
  final TextEditingController _nazivPrijevoznikaController = TextEditingController(text: 'Moj Prijevoz d.o.o.');
  final TextEditingController _oibPrijevoznikaController = TextEditingController(text: '12345678901');
  final TextEditingController _adresaPrijevoznikaController = TextEditingController(text: 'Zagrebačka cesta 10, Zagreb');

  // Kontroleri za podatke klijenta
  final TextEditingController _nazivKlijentaController = TextEditingController(text: 'Turistička agencija / Klijent');
  final TextEditingController _kontaktKlijentaController = TextEditingController(text: 'info@klijent.com');

  // Kontroleri za relacije i troškove
  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odredisteController = TextEditingController(text: 'Ljubljana');
  final TextEditingController _kmController = TextEditingController(text: '280');
  final TextEditingController _cestarinaController = TextEditingController(text: '25');
  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.45');
  final TextEditingController _dnevnicaController = TextEditingController(text: '80');
  final TextEditingController _marzaController = TextEditingController(text: '20'); // Postotak zarade

  // Kategorije vozila i potrošnja (L/100km)
  final Map<String, double> _potrosnjaVozila = {
    'Kombi 8+1 (9L / 100km)': 9.0,
    'Mini bus <20 (15L / 100km)': 15.0,
    'Midi bus 35 (30L / 100km)': 30.0,
    'Veliki autobus 50 (35L / 100km)': 35.0,
  };

  late String _odabranoVozilo;

  // Rezultati izračuna
  double _trosakGoriva = 0;
  double _trosakCestarine = 0;
  double _trosakVozača = 0;
  double _ukupniCistiTrosak = 0;
  double _zarada = 0;
  double _UkupnaCijenaPonude = 0;

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;
    _izracunajTroškove();
  }

  void _izracunajTroškove() {
    setState(() {
      double km = double.tryParse(_kmController.text) ?? 0;
      double cestarina = double.tryParse(_cestarinaController.text) ?? 0;
      double cijenaGoriva = double.tryParse(_cijenaGorivaController.text) ?? 0;
      double dnevnica = double.tryParse(_dnevnicaController.text) ?? 0;
      double marzaPostotak = double.tryParse(_marzaController.text) ?? 0;

      double potrosnjaNa100km = _potrosnjaVozila[_odabranoVozilo] ?? 9.0;

      // Izračuni
      _trosakGoriva = (km / 100) * potrosnjaNa100km * cijenaGoriva;
      _trosakCestarine = cestarina;
      _trosakVozača = dnevnica;

      _ukupniCistiTrosak = _trosakGoriva + _trosakCestarine + _trosakVozača;
      _zarada = _ukupniCistiTrosak * (marzaPostotak / 100);
      _UkupnaCijenaPonude = _ukupniCistiTrosak + _zarada;
    });
  }

  void _dohvatiUdaljenost() {
    String polaziste = _polazisteController.text.trim().toLowerCase();
    String odrediste = _odredisteController.text.trim().toLowerCase();

    double izracunatimKm = 300.0;
    if ((polaziste.contains('zagreb') && odrediste.contains('ljubljana')) || 
        (polaziste.contains('ljubljana') && odrediste.contains('zagreb'))) {
      izracunatimKm = 280.0;
    } else if ((polaziste.contains('zagreb') && odrediste.contains('sarajevo')) || 
               (polaziste.contains('sarajevo') && odrediste.contains('zagreb'))) {
      izracunatimKm = 800.0;
    } else if ((polaziste.contains('split') && odrediste.contains('zagreb')) || 
               (polaziste.contains('zagreb') && odrediste.contains('split'))) {
      izracunatimKm = 780.0;
    }

    setState(() {
      _kmController.text = izracunatimKm.toString();
      _izracunajTroškove();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ruta izračunata: $_kmController km')),
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
            // KARTICA 0.1: Podaci Prijevoznika
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1. Podaci Prijevoznika (Vaša tvrtka/obrt)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nazivPrijevoznikaController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv Prijevoznika',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _oibPrijevoznikaController,
                            decoration: const InputDecoration(
                              labelText: 'OIB',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _adresaPrijevoznikaController,
                            decoration: const InputDecoration(
                              labelText: 'Adresa',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.home),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KARTICA 0.2: Podaci Klijenta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2. Podaci Klijenta (Naručitelja)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nazivKlijentaController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv Klijenta / Agencije',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kontaktKlijentaController,
                      decoration: const InputDecoration(
                        labelText: 'Kontakt (Email / Telefon)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.contact_mail),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KARTICA 1: Odabir Vozila i Ruta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3. Odabir Vozila i Relacija', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      value: _odabranoVozilo,
                      decoration: const InputDecoration(
                        labelText: 'Kategorija Vozila',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_bus),
                      ),
                      items: _potrosnjaVozila.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key, style: const TextStyle(fontSize: 14)),
                        );
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
                        Expanded(
                          child: TextField(
                            controller: _polazisteController,
                            decoration: const InputDecoration(
                              labelText: 'Polazište',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.trip_origin),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _odredisteController,
                            decoration: const InputDecoration(
                              labelText: 'Odredište',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: _dohvatiUdaljenost,
                      icon: const Icon(Icons.map),
                      label: const Text('Izračunaj udaljenost (Ruta)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ukupno Kilometara (u oba smjera)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                        suffixText: 'km',
                      ),
                      onChanged: (_) => _izracunajTroškove(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KARTICA 2: Parametri Troškova
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('4. Procjena Troškova', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cijenaGorivaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Gorivo (€/L)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.local_gas_station),
                            ),
                            onChanged: (_) => _izracunajTroškove(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cestarinaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cestarina (€)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.toll),
                            ),
                            onChanged: (_) => _izracunajTroškove(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dnevnicaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dnevnica (€)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            onChanged: (_) => _izracunajTroškove(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _marzaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Marža (%)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.percent),
                            ),
                            onChanged: (_) => _izracunajTroškove(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KARTICA 3: RAZRADA I REZULTAT
            Card(
              color: const Color(0xFF0C4A6E),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('5. Razrada Ponude', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Divider(color: Colors.white24, height: 20),

                    _prikaziRedak('Trošak Goriva:', '${_trosakGoriva.toStringAsFixed(2)} €'),
                    _prikaziRedak('Trošak Cestarine:', '${_trosakCestarine.toStringAsFixed(2)} €'),
                    _prikaziRedak('Dnevnica Vozača:', '${_trosakVozača.toStringAsFixed(2)} €'),
                    const Divider(color: Colors.white24, height: 20),
                    _prikaziRedak('Čisti Troškovi:', '${_ukupniCistiTrosak.toStringAsFixed(2)} €', isBold: true),
                    _prikaziRedak('Planirana Zarada:', '${_zarada.toStringAsFixed(2)} €', color: Colors.amber),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('UKUPNA PONUDA:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(
                            '${_UkupnaCijenaPonude.toStringAsFixed(2)} €',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gumb za izradu PDF-a
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generiranje PDF ponude s podacima prijevoznika i klijenta slijedi!')),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERIRAJ PDF PONUDU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
          Text(naziv, style: TextStyle(color: color, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(iznos, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
