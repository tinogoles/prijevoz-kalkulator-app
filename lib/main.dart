import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Obavezno osigurava inicijalizaciju Flutter vezanja
  WidgetsFlutterBinding.ensureInitialized();

  // Inicijalizacija Firebase-a s eksplicitnim opcijama za stabilan rad na mobitelu i webu
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCYB1XlQMLH5DQc_hkrs15pRB-YvovMpmg",
      authDomain: "prijevozkalkulator.firebaseapp.com",
      projectId: "prijevozkalkulator",
      storageBucket: "prijevozkalkulator.firebasestorage.app",
      messagingSenderId: "922321976582",
      appId: "1:922321976582:web:dc5e206991297b10b7287",
    ),
  );

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
    _ucitajPodatkeIzFirestore();
  }

  void _ucitajPodatkeIzFirestore() {
    final firestore = FirebaseFirestore.instance;

    firestore.collection('postavke').doc('prijevoznik').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        setState(() {
          _prijevoznik = PrijevoznikModel.fromJson(doc.data()!);
        });
      }
    });

    firestore.collection('klijenti').snapshots().listen((snapshot) {
      setState(() {
        _klijenti = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return KlijentModel.fromJson(data);
        }).toList();

        if (_klijenti.isNotEmpty && _aktivniKlijent == null) {
          _aktivniKlijent = _klijenti.first;
        } else if (_klijenti.isEmpty) {
          _klijenti.add(KlijentModel(id: '1', naziv: 'Turistička Agencija Split', vlasnik: 'Marko Marić', grad: 'Split', oib: '98765432109', uSustavuPdv: true));
          _aktivniKlijent = _klijenti.first;
        }
      });
    });

    firestore.collection('kalkulacije').snapshots().listen((snapshot) {
      setState(() {
        _spremljeneKalkulacije = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return KalkulacijaModel.fromJson(data);
        }).toList();
      });
    });
  }

  Future<void> _spremiPodatkeUFirestore() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('postavke').doc('prijevoznik').set(_prijevoznik.toJson());
    for (var kalk in _spremljeneKalkulacije) {
      await firestore.collection('kalkulacije').doc(kalk.id).set(kalk.toJson());
    }
  }

  Future<void> _obrisiKalkulacijuIzFirestore(String id) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('kalkulacije').doc(id).delete();
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
          _spremiPodatkeUFirestore();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalkulacija uspješno spremljena u arhivu!'), backgroundColor: Colors.green));
        },
      ),
      KalkulacijeTab(
        kalkulacije: _spremljeneKalkulacije,
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        onObrisi: (id) {
          setState(() => _spremljeneKalkulacije.removeWhere((element) => element.id == id));
          _obrisiKalkulacijuIzFirestore(id);
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
          _spremiPodatkeUFirestore();
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
  final KalkulacijaModel? kalkulacijaZaUredivanje;
  final ValueChanged<KlijentModel?> onKlijentChanged;
  final ValueChanged<KalkulacijaModel> onSpremiKalkulaciju;

  const IzracunTroskovaTab({
    super.key,
    required this.prijevoznik,
    required this.klijenti,
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

  final List<Map<String, dynamic>> _bazaRelacijaCestarina = [
    {
      'kljucneRijeci': ['zagreb', 'split'],
      'nazivAutoceste': 'HAC (Hrvatske autoceste)',
      'kmJednosmjerno': 390.0,
      'cestarine': {
        'Kombi 8+1': 17.50,
        'Mini bus <20': 27.60,
        'Midi bus 35': 41.85,
        'Veliki autobus 50': 41.85,
      }
    },
    {
      'kljucneRijeci': ['zagreb', 'trakošćan', 'trakoscan'],
      'nazivAutoceste': 'AZM (Zagreb - Macelj)',
      'kmJednosmjerno': 60.0,
      'cestarine': {
        'Kombi 8+1': 4.00,
        'Mini bus <20': 6.70,
        'Midi bus 35': 10.00,
        'Veliki autobus 50': 15.40,
      }
    },
  ];

  final TextEditingController _nazivKalkulacijeController = TextEditingController(text: 'Izlet - Ruta po točkama');
  final TextEditingController _polazisteController = TextEditingController(text: 'Zagreb');
  final TextEditingController _odrediste1Controller = TextEditingController();
  final TextEditingController _odrediste2Controller = TextEditingController();
  final TextEditingController _konacnoOdredisteController = TextEditingController(text: 'Split');

  late TextEditingController _datumPolaskaController;
  late TextEditingController _datumPovratkaController;
  int _izracunatiBrojDana = 1;

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
    'Kombi 8+1': 9.0,
    'Mini bus <20': 15.0,
    'Midi bus 35': 30.0,
    'Veliki autobus 50': 35.0,
  };
  late String _odabranoVozilo;
  String? _trenutniIdUredjivanja;

  String _formatirajDatum(DateTime d) {
    String day = d.day.toString().padLeft(2, '0');
    String month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}.';
  }

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;

    String danas = _formatirajDatum(DateTime.now());
    _datumPolaskaController = TextEditingController(text: danas);
    _datumPovratkaController = TextEditingController(text: danas);

    _provjeriUredjivanje();
    _preracunajBrojDana();
    _izracunajTroskove();
  }

  @override
  void didUpdateWidget(covariant IzracunTroskovaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kalkulacijaZaUredivanje != oldWidget.kalkulacijaZaUredivanje) {
      _provjeriUredjivanje();
    }
  }

  void _provjeriUredjivanje() {
    if (widget.kalkulacijaZaUredivanje != null) {
      var k = widget.kalkulacijaZaUredivanje!;
      _trenutniIdUredjivanja = k.id;
      _nazivKalkulacijeController.text = k.nazivKalkulacije;
      _polazisteController.text = k.polaziste;
      _odrediste1Controller.text = k.odrediste1;
      _odrediste2Controller.text = k.odrediste2;
      _konacnoOdredisteController.text = k.konacnoOdrediste;
      _datumPolaskaController.text = k.datumPolaska;
      _datumPovratkaController.text = k.datumPovratka;
      _kmController.text = k.km;
      _cestarinaController.text = k.cestarina;
      _povratnoPutovanje = k.povratno;
      _koristiAutocestu = k.koristiAutocestu;
      _odabranaAutocesta = k.odabranaAutocesta;
      _tkoPlacaNocenje = k.tkoPlacaNocenje;
      _cijenaNocenjaController.text = k.cijenaNocenja;
      _marzaController.text = k.marza;
      _cijenaGorivaController.text = k.cijenaGoriva;
      _dnevnicaController.text = k.dnevnica;
      
      if (_potrosnjaVozila.containsKey(k.vozilo)) {
        _odabranoVozilo = k.vozilo;
      }
    }
  }

  Future<void> _odaberiDatum(BuildContext context, TextEditingController controller) async {
    DateTime inicijalni = DateTime.now();
    try {
      String dStr = controller.text.replaceAll('.', '').trim();
      if (dStr.length >= 8) {
        inicijalni = DateTime(int.parse(dStr.substring(4, 8)), int.parse(dStr.substring(2, 4)), int.parse(dStr.substring(0, 2)));
      }
    } catch (_) {}

    final DateTime? odabir = await showDatePicker(
      context: context,
      initialDate: inicijalni,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (odabir != null) {
      setState(() {
        controller.text = _formatirajDatum(odabir);
        _izracunajTroskove();
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
        setState(() {
          _izracunatiBrojDana = razlika > 0 ? razlika : 1;
        });
      }
    } catch (_) {}
  }

  void _izracunajTroskove() {
    _preracunajBrojDana();
    setState(() {});
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
      _automatskiDetektirajCestarinu(tocke);
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
    double km = double.tryParse(_kmController.text) ?? 0;
    double cestarinaBruto = double.tryParse(_cestarinaController.text) ?? 0;
    double cijenaGorivaBruto = double.tryParse(_cijenaGorivaController.text) ?? 0;
    double dnevnicaPoDanu = double.tryParse(_dnevnicaController.text) ?? 0;
    double cijenaNocenjaBruto = double.tryParse(_cijenaNocenjaController.text) ?? 0;
    double marzaPostotak = double.tryParse(_marzaController.text) ?? 0;

    double potrosnjaNa100km = _potrosnjaVozila[_odabranoVozilo] ?? 9.0;
    int brojNocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnjaNa100km * cijenaGorivaBruto) / 1.25;
    double cestarinaNeto = (_koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnicaPoDanu * _izracunatiBrojDana;
    double nocenjeNeto = (_tkoPlacaNocenje == 'Prijevoznik plaća' ? (cijenaNocenjaBruto * brojNocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marzaPostotak / 100);
    double osnovica = cistiTrosak + zarada;
    bool klijentPdv = widget.aktivniKlijent?.uSustavuPdv ?? true;
    double ukupnaCijena = klijentPdv ? (osnovica * 1.25) : osnovica;

    String relacija = '${_polazisteController.text} -> ${_konacnoOdredisteController.text}';
    KalkulacijaModel kalk = KalkulacijaModel(
      id: _trenutniIdUredjivanja ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: _nazivKalkulacijeController.text,
      klijentNaziv: widget.aktivniKlijent?.naziv ?? 'Nepoznat klijent',
      datumPolaska: _datumPolaskaController.text,
      datumPovratka: _datumPovratkaController.text,
      vozilo: _odabranoVozilo,
      ruta: relacija,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Izračun Troškova Prijevoza', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    CheckboxListTile(
                      title: const Text('Povratno putovanje (U oba smjera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Automatski množi kilometre s 2', style: TextStyle(fontSize: 12)),
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
                    TextField(controller: _kmController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ukupno Kilometara', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed), suffixText: 'km'), onChanged: (_) => _izracunajTroskove()),
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
                    const Text('Termin i Trajanje Putovanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _datumPolaskaController,
                            readOnly: true,
                            onTap: () => _odaberiDatum(context, _datumPolaskaController),
                            decoration: const InputDecoration(labelText: 'Datum polaska', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_month)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _datumPovratkaController,
                            readOnly: true,
                            onTap: () => _odaberiDatum(context, _datumPovratkaController),
                            decoration: const InputDecoration(labelText: 'Datum povratka', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_month)),
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
            TextField(controller: _nazivKalkulacijeController, decoration: const InputDecoration(labelText: 'Naziv kalkulacije / ponude', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bookmark), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 16),
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
                      items: _potrosnjaVozila.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _odabranoVozilo = val;
                            _izracunajTroskove();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cijenaGorivaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gorivo (€/L, bruto)', border: OutlineInputBorder()), onChanged: (_) => _izracunajTroskove())),
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
                      items: _opcijeNocenja.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() { _tkoPlacaNocenje = val; _izracunajTroskove(); });
                      },
                    ),
                    if (_tkoPlacaNocenje == 'Prijevoznik plaća') ...[
                      const SizedBox(height: 8),
                      TextField(controller: _cijenaNocenjaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cijena noćenja po noći (€, bruto)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.hotel)), onChanged: (_) => _izracunajTroskove()),
                    ],
                    const SizedBox(height: 12),
                    TextField(controller: _marzaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.percent)), onChanged: (_) => _izracunajTroskove()),
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
                          if (!_koristiAutocestu) _cestarinaController.text = '0.00';
                          _izracunajTroskove();
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
              icon: _isLoadingRoute
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.route, color: Colors.white),
              label: Text(_isLoadingRoute ? 'Izračunavam dionice...' : 'Izračunaj kilometre po točkama (OSRM)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _spremi,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: Text(_trenutniIdUredjivanja == null ? '1. KORAK: IZRADI I SPREMI KALKULACIJU' : 'AŽURIRAJ KALKULACIJU', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class KalkulacijeTab extends StatelessWidget {
  final List<KalkulacijaModel> kalkulacije;
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final ValueChanged<String> onObrisi;
  final ValueChanged<KalkulacijaModel> onUredi;

  const KalkulacijeTab({
    super.key,
    required this.kalkulacije,
    required this.prijevoznik,
    required this.klijenti,
    required this.onObrisi,
    required this.onUredi,
  });

  void _printajKalkulaciju(BuildContext context, KalkulacijaModel k) async {
    var klijentObj = klijenti.firstWhere(
      (kl) => kl.naziv == k.klijentNaziv,
      orElse: () => KlijentModel(id: '0', naziv: k.klijentNaziv, uSustavuPdv: true),
    );

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double km = double.tryParse(k.km) ?? 0;
    double cestarinaBruto = double.tryParse(k.cestarina) ?? 0;
    double cijenaGorivaBruto = double.tryParse(k.cijenaGoriva) ?? 0;
    double dnevnicaPoDanu = double.tryParse(k.dnevnica) ?? 0;
    double cijenaNocenjaBruto = double.tryParse(k.cijenaNocenja) ?? 0;
    double marzaPostotak = double.tryParse(k.marza) ?? 0;

    double potrosnja = 9.0;
    if (k.vozilo.contains('Mini')) potrosnja = 15.0;
    else if (k.vozilo.contains('Midi')) potrosnja = 30.0;
    else if (k.vozilo.contains('Veliki')) potrosnja = 35.0;

    double trosakGorivaBruto = (km / 100) * potrosnja * cijenaGorivaBruto;
    double gorivoNeto = trosakGorivaBruto / 1.25;
    double gorivoPdv = trosakGorivaBruto - gorivoNeto;

    double trosakCestarineBruto = k.koristiAutocestu ? cestarinaBruto : 0;
    double cestarinaNeto = trosakCestarineBruto / 1.25;
    double cestarinaPdv = trosakCestarineBruto - cestarinaNeto;

    double trosakVozaca = dnevnicaPoDanu;

    double trosakNocenjaBruto = (k.tkoPlacaNocenje == 'Prijevoznik plaća') ? cijenaNocenjaBruto : 0;
    double nocenjeNeto = trosakNocenjaBruto / 1.25;
    double nocenjePdv = trosakNocenjaBruto - nocenjeNeto;

    double ukupnoNeto = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double marza = ukupnoNeto * (marzaPostotak / 100);
    double osnovica = ukupnoNeto + marza;
    double izlazniPdv = klijentObj.uSustavuPdv ? (osnovica * 0.25) : 0;
    double ukupnoTotal = osnovica + izlazniPdv;

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
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
                      pw.Text('INTERNA KALKULACIJA TROŠKOVA', style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.red800)),
                      pw.Text('ID: ${k.id.length > 6 ? k.id.substring(k.id.length - 6) : k.id}', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Text('Prijevoznik: ${prijevoznik.naziv} (OIB: ${prijevoznik.oib})', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  pw.Text('Klijent: ${k.klijentNaziv} (PDV sustav: ${klijentObj.uSustavuPdv ? "DA" : "NE"})', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  pw.Text('Ruta: ${k.ruta} (${k.km} km) | Termin: ${k.datumPolaska} - ${k.datumPovratka}', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                  pw.SizedBox(height: 15),
                  pw.Table.fromTextArray(
                    headers: ['Stavka troška', 'Bez PDV-a (Neto)', 'PDV (25%)', 'Ukupno (Bruto)'],
                    data: [
                      ['Gorivo (${k.vozilo})', '${gorivoNeto.toStringAsFixed(2)} €', '${gorivoPdv.toStringAsFixed(2)} €', '${trosakGorivaBruto.toStringAsFixed(2)} €'],
                      ['Cestarina', '${cestarinaNeto.toStringAsFixed(2)} €', '${cestarinaPdv.toStringAsFixed(2)} €', '${trosakCestarineBruto.toStringAsFixed(2)} €'],
                      ['Dnevnica vozača', '${trosakVozaca.toStringAsFixed(2)} €', '0.00 €', '${trosakVozaca.toStringAsFixed(2)} €'],
                      ['Noćenje vozača', '${nocenjeNeto.toStringAsFixed(2)} €', '${nocenjePdv.toStringAsFixed(2)} €', '${trosakNocenjaBruto.toStringAsFixed(2)} €'],
                    ],
                    headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                    cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    child: pw.Column(
                      children: [
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Ukupni troškovi (Neto):', style: pw.TextStyle(font: fontRegular)), pw.Text('${ukupnoNeto.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular))]),
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Marža (${k.marza}%):', style: pw.TextStyle(font: fontRegular)), pw.Text('${marza.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular))]),
                        pw.Divider(),
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Osnovica za ponudu:', style: pw.TextStyle(font: fontRegular)), pw.Text('${osnovica.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular))]),
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Izlazni PDV (25%):', style: pw.TextStyle(font: fontRegular)), pw.Text('${izlazniPdv.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular))]),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL ZA SVE:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                            pw.Text('${ukupnoTotal.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.red900)),
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
        return pdf.save();
      },
      name: 'Kalkulacija_${k.nazivKalkulacije}.pdf',
    );
  }

  void _izradiPonudu(BuildContext context, KalkulacijaModel k) async {
    var klijentObj = klijenti.firstWhere(
      (kl) => kl.naziv == k.klijentNaziv,
      orElse: () => KlijentModel(id: '0', naziv: k.klijentNaziv, uSustavuPdv: true),
    );

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double km = double.tryParse(k.km) ?? 0;
    double cestarinaBruto = double.tryParse(k.cestarina) ?? 0;
    double cijenaGorivaBruto = double.tryParse(k.cijenaGoriva) ?? 0;
    double dnevnicaPoDanu = double.tryParse(k.dnevnica) ?? 0;
    double cijenaNocenjaBruto = double.tryParse(k.cijenaNocenja) ?? 0;
    double marzaPostotak = double.tryParse(k.marza) ?? 0;

    double potrosnja = 9.0;
    if (k.vozilo.contains('Mini')) potrosnja = 15.0;
    else if (k.vozilo.contains('Midi')) potrosnja = 30.0;
    else if (k.vozilo.contains('Veliki')) potrosnja = 35.0;

    double gorivoNeto = ((km / 100) * potrosnja * cijenaGorivaBruto) / 1.25;
    double cestarinaNeto = (k.koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnicaPoDanu;
    double nocenjeNeto = (k.tkoPlacaNocenje == 'Prijevoznik plaća' ? cijenaNocenjaBruto : 0) / 1.25;

    double ukupnoNeto = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double marza = ukupnoNeto * (marzaPostotak / 100);
    double osnovica = ukupnoNeto + marza;
    double izlasniPdv = klijentObj.uSustavuPdv ? (osnovica * 0.25) : 0;
    double ukupnaCijenaSPdv = osnovica + izlasniPdv;

    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
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
                          pw.Text(prijevoznik.naziv, style: pw.TextStyle(font: fontBold, fontSize: 16)),
                          pw.Text('Adresa: ${prijevoznik.adresa}, ${prijevoznik.grad}', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                          pw.Text('OIB: ${prijevoznik.oib} | Tel: ${prijevoznik.telefon}', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Za klijenta:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                          pw.Text(k.klijentNaziv, style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                          pw.SizedBox(height: 6),
                          pw.Text('Datum: ${k.datumPolaska}', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(height: 20),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text('PONUDA ZA PRIJEVOZ', style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.blue800)),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Predmet: ${k.nazivKalkulacije}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 15),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SPECIFIKACIJA USLUGE', style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.blue900)),
                        pw.SizedBox(height: 8),
                        pw.Text('Ruta: ${k.ruta}', style: pw.TextStyle(font: fontRegular, fontSize: 11)),
                        pw.Text('Termin: ${k.datumPolaska} - ${k.datumPovratka}', style: pw.TextStyle(font: fontRegular, fontSize: 11)),
                        pw.Text('Kategorija vozila: ${k.vozilo}', style: pw.TextStyle(font: fontRegular, fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 25),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: const pw.BoxDecoration(color: PdfColors.orange800, borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
                    child: pw.Column(
                      children: [
                        if (klijentObj.uSustavuPdv) ...[
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Osnovica (Bez PDV-a):', style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.white)),
                              pw.Text('${osnovica.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.white)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('PDV (25%):', style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.white)),
                              pw.Text('${izlasniPdv.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.white)),
                            ],
                          ),
                          pw.Divider(color: PdfColors.white),
                        ],
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(klijentObj.uSustavuPdv ? 'UKUPNA CIJENA S PDV-om:' : 'UKUPNA CIJENA USLUGE:', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.white)),
                            pw.Text('${ukupnaCijenaSPdv.toStringAsFixed(2)} €', style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  pw.Center(child: pw.Text('Zahvaljujemo na povjerenju! Ponuda vrijedi 15 dana.', style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700))),
                ],
              );
            },
          ),
        );
        return pdf.save();
      },
      name: 'Ponuda_${k.nazivKalkulacije}.pdf',
    );
  }

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
                        Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => onUredi(k),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Uredi'),
                            ),
                            TextButton.icon(
                              onPressed: () => _printajKalkulaciju(context, k),
                              icon: const Icon(Icons.print, size: 18, color: Colors.indigo),
                              label: const Text('Interna kalkulacija', style: TextStyle(color: Colors.indigo)),
                            ),
                            TextButton.icon(
                              onPressed: () => _izradiPonudu(context, k),
                              icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.green),
                              label: const Text('Ponuda PDF', style: TextStyle(color: Colors.green)),
                            ),
                            IconButton(
                              onPressed: () => onObrisi(k.id),
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
  late TextEditingController _nazivController;
  late TextEditingController _vlasnikController;
  late TextEditingController _adresaController;
  late TextEditingController _gradController;
  late TextEditingController _oibController;
  late TextEditingController _telController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _inicijalizirajControllere();
  }

  void _inicijalizirajControllere() {
    _nazivController = TextEditingController(text: widget.prijevoznik.naziv);
    _vlasnikController = TextEditingController(text: widget.prijevoznik.vlasnik);
    _adresaController = TextEditingController(text: widget.prijevoznik.adresa);
    _gradController = TextEditingController(text: widget.prijevoznik.grad);
    _oibController = TextEditingController(text: widget.prijevoznik.oib);
    _telController = TextEditingController(text: widget.prijevoznik.telefon);
    _emailController = TextEditingController(text: widget.prijevoznik.email);
  }

  @override
  void didUpdateWidget(covariant PostavkeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prijevoznik != oldWidget.prijevoznik) {
      _inicijalizirajControllere();
    }
  }

  void _spremiPostavke() {
    widget.prijevoznik.naziv = _nazivController.text;
    widget.prijevoznik.vlasnik = _vlasnikController.text;
    widget.prijevoznik.adresa = _adresaController.text;
    widget.prijevoznik.grad = _gradController.text;
    widget.prijevoznik.oib = _oibController.text;
    widget.prijevoznik.telefon = _telController.text;
    widget.prijevoznik.email = _emailController.text;

    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Postavke prijevoznika uspješno spremljene!'), backgroundColor: Colors.green));
  }

  void _prikaziDijalogZaKlijenta({KlijentModel? klijent}) {
    final nazC = TextEditingController(text: klijent?.naziv ?? '');
    final vlaC = TextEditingController(text: klijent?.vlasnik ?? '');
    final adrC = TextEditingController(text: klijent?.adresa ?? '');
    final grdC = TextEditingController(text: klijent?.grad ?? '');
    final oibC = TextEditingController(text: klijent?.oib ?? '');
    final telC = TextEditingController(text: klijent?.telefon ?? '');
    final emlC = TextEditingController(text: klijent?.email ?? '');
    bool pdv = klijent?.uSustavuPdv ?? true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(klijent == null ? 'Novi Klijent' : 'Uredi Klijenta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nazC, decoration: const InputDecoration(labelText: 'Naziv klijenta / agencije')),
              TextField(controller: vlaC, decoration: const InputDecoration(labelText: 'Kontakt osoba')),
              TextField(controller: adrC, decoration: const InputDecoration(labelText: 'Adresa')),
              TextField(controller: grdC, decoration: const InputDecoration(labelText: 'Grad')),
              TextField(controller: oibC, decoration: const InputDecoration(labelText: 'OIB')),
              TextField(controller: telC, decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(controller: emlC, decoration: const InputDecoration(labelText: 'Email')),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setStateModal) {
                  return CheckboxListTile(
                    title: const Text('Klijent je u sustavu PDV-a?'),
                    value: pdv,
                    onChanged: (val) => setStateModal(() => pdv = val ?? true),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Odustani')),
          ElevatedButton(
            onPressed: () {
              if (nazC.text.trim().isEmpty) return;
              String id = klijent?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
              var noviK = KlijentModel(
                id: id,
                naziv: nazC.text,
                vlasnik: vlaC.text,
                adresa: adrC.text,
                grad: grdC.text,
                oib: oibC.text,
                telefon: telC.text,
                email: emlC.text,
                uSustavuPdv: pdv,
              );

              setState(() {
                if (klijent == null) {
                  widget.klijenti.add(noviK);
                } else {
                  int idx = widget.klijenti.indexWhere((element) => element.id == klijent.id);
                  if (idx >= 0) widget.klijenti[idx] = noviK;
                }
              });

              FirebaseFirestore.instance.collection('klijenti').doc(id).set(noviK.toJson());
              widget.onUpdate();
              Navigator.pop(ctx);
            },
            child: const Text('Spremi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postavke i Klijenti', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Podaci o Vašoj Tvrtki (Prijevoznik)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            const SizedBox(height: 12),
            TextField(controller: _nazivController, decoration: const InputDecoration(labelText: 'Naziv prijevoznika', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _vlasnikController, decoration: const InputDecoration(labelText: 'Vlasnik / Direktor', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _adresaController, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _gradController, decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _oibController, decoration: const InputDecoration(labelText: 'OIB', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _telController, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _spremiPostavke,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Spremi Postavke Prijevoznika', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const Divider(height: 40, thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popis Klijenta / Agencija', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                ElevatedButton.icon(
                  onPressed: () => _prikaziDijalogZaKlijenta(),
                  icon: const Icon(Icons.add),
                  label: const Text('Novi Klijent'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.klijenti.length,
              itemBuilder: (ctx, idx) {
                var k = widget.klijenti[idx];
                return Card(
                  child: ListTile(
                    title: Text(k.naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${k.grad} | OIB: ${k.oib} | PDV: ${k.uSustavuPdv ? "DA" : "NE"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _prikaziDijalogZaKlijenta(klijent: k)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => widget.klijenti.removeAt(idx));
                            FirebaseFirestore.instance.collection('klijenti').doc(k.id).delete();
                            widget.onUpdate();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
