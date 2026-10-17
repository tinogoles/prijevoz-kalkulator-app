import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Osigurava inicijalizaciju Flutter vezanja
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicijalizacija Firebase-a za rad u oblaku
  await Firebase.initializeApp();

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

  String polaziste, odrediste1, odrediste2, konacnoOdrediste, cestarina, km;
  bool povratno, koristiAutocestu;
  String odabranaAutocesta, tkoPlacaNocenje, cijenaNocenja, marza, cijenaGoriva, dnevnica;

  KalkulacijaModel({
    required this.id,
    required this.nazivKalkulacije,
    required this.klijentNaziv,
    required this.datumPolaska,
    required this.datumPovratka,
    required this.vozilo,
    required this.ruta,
    required this.ukupnaCijena,
    this.polaziste = 'Zagreb',
    this.odrediste1 = '',
    this.odrediste2 = '',
    this.konacnoOdrediste = 'Split',
    this.cestarina = '35.00',
    this.km = '780',
    this.povratno = true,
    this.koristiAutocestu = true,
    this.odabranaAutocesta = 'HAC (Hrvatske autoceste)',
    this.tkoPlacaNocenje = 'Prijevoznik plaća',
    this.cijenaNocenja = '60',
    this.marza = '20',
    this.cijenaGoriva = '1.45',
    this.dnevnica = '80',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nazivKalkulacije': nazivKalkulacije, 'klijentNaziv': klijentNaziv,
    'datumPolaska': datumPolaska, 'datumPovratka': datumPovratka,
    'vozilo': vozilo, 'ruta': ruta, 'ukupnaCijena': ukupnaCijena,
    'polaziste': polaziste, 'odrediste1': odrediste1, 'odrediste2': odrediste2,
    'konacnoOdrediste': konacnoOdrediste, 'cestarina': cestarina, 'km': km,
    'povratno': povratno, 'koristiAutocestu': koristiAutocestu,
    'odabranaAutocesta': odabranaAutocesta, 'tkoPlacaNocenje': tkoPlacaNocenje,
    'cijenaNocenja': cijenaNocenja, 'marza': marza, 'cijenaGoriva': cijenaGoriva, 'dnevnica': dnevnica,
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
    polaziste: json['polaziste'] ?? 'Zagreb',
    odrediste1: json['odrediste1'] ?? '',
    odrediste2: json['odrediste2'] ?? '',
    konacnoOdrediste: json['konacnoOdrediste'] ?? 'Split',
    cestarina: json['cestarina'] ?? '35.00',
    km: json['km'] ?? '780',
    povratno: json['povratno'] ?? true,
    koristiAutocestu: json['koristiAutocestu'] ?? true,
    odabranaAutocesta: json['odabranaAutocesta'] ?? 'HAC (Hrvatske autoceste)',
    tkoPlacaNocenje: json['tkoPlacaNocenje'] ?? 'Prijevoznik plaća',
    cijenaNocenja: json['cijenaNocenja'] ?? '60',
    marza: json['marza'] ?? '20',
    cijenaGoriva: json['cijenaGoriva'] ?? '1.45',
    dnevnica: json['dnevnica'] ?? '80',
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
  KlijentModel? _aktivniKlijent;

  KalkulacijaModel? _kalkulacijaZaUredivanje;

  @override
  void initState() {
    super.initState();
    _ucitajPodatkeIzMemorije();
  }

  Future<void> _ucitajPodatkeIzMemorije() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? pJson = prefs.getString('prijevoznik');
    if (pJson != null) {
      setState(() => _prijevoznik = PrijevoznikModel.fromJson(json.decode(pJson)));
    }

    String? kListJson = prefs.getString('klijenti');
    if (kListJson != null) {
      List decoded = json.decode(kListJson);
      setState(() {
        _klijenti = decoded.map((e) => KlijentModel.fromJson(e)).toList();
        if (_klijenti.isNotEmpty) _aktivniKlijent = _klijenti.first;
      });
    } else {
      setState(() {
        _klijenti.add(KlijentModel(id: '1', naziv: 'Turistička Agencija Split', vlasnik: 'Marko Marić', grad: 'Split', oib: '98765432109', uSustavuPdv: true));
        _aktivniKlijent = _klijenti.first;
      });
    }

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
        kalkulacijaZaUredivanje: _kalkulacijaZaUredivanje,
        onKlijentChanged: (k) => setState(() => _aktivniKlijent = k),
        onSpremiKalkulaciju: (kalk) {
          setState(() {
            int index = _spremljeneKalkulacije.indexWhere((element) => element.id == kalk.id);
            if (index >= 0) {
              _spremljeneKalkulacije[index] = kalk;
            } else {
              _spremljeneKalkulacije.add(kalk);
            }
            _kalkulacijaZaUredivanje = null;
          });
          _spremiPodatkeUMemoriju();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalkulacija uspješno spremljena u arhivu!'), backgroundColor: Colors.green));
        },
      ),
      KalkulacijeTab(
        kalkulacije: _spremljeneKalkulacije,
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        onObrisi: (id) {
          setState(() => _spremljeneKalkulacije.removeWhere((element) => element.id == id));
          _spremiPodatkeUMemoriju();
        },
        onUredi: (kalk) {
          var pronadjeniKlijent = _klijenti.firstWhere(
            (k) => k.naziv == kalk.klijentNaziv,
            orElse: () => _klijenti.isNotEmpty ? _klijenti.first : KlijentModel(id: '0'),
          );
          setState(() {
            _aktivniKlijent = pronadjeniKlijent;
            _kalkulacijaZaUredivanje = kalk;
            _currentIndex = 0;
          });
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
class IzracunTroskovaTab extends StatelessWidget {
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final KlijentModel? aktivniKlijent;
  final KalkulacijaModel? kalkulacijaZaUredivanje;
  final Function(KlijentModel?) onKlijentChanged;
  final Function(KalkulacijaModel) onSpremiKalkulaciju;

  const IzracunTroskovaTab({
    super.key,
    required this.prijevoznik,
    required this.klijenti,
    required this.aktivniKlijent,
    this.kalkulacijaZaUredivanje,
    required this.onKlijentChanged,
    required this.onSpremiKalkulaciju,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Ekran za izračun troškova',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class KalkulacijeTab extends StatelessWidget {
  final List<KalkulacijaModel> kalkulacije;
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final Function(String) onObrisi;
  final Function(KalkulacijaModel) onUredi;

  const KalkulacijeTab({
    super.key,
    required this.kalkulacije,
    required this.prijevoznik,
    required this.klijenti,
    required this.onObrisi,
    required this.onUredi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Arhiva kalkulacija (${kalkulacije.length})',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class PostavkeTab extends StatelessWidget {
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final VoidCallback onUpdate;

  const PostavkeTab({
    super.key,
    required this.prijevoznik,
    required this.klijenti,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Postavke aplikacije',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
// Ostatak klasa za sučelje (IzracunTroskovaTab, KalkulacijeTab, PostavkeTab itd.) ostaje nepromijenjen ispod...
