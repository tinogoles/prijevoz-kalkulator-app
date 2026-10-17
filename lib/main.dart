import 'package:prijevoz_kalkulator/services/cestarine_service.dart';
import 'package:prijevoz_kalkulator/data/baza_cestarina_data.dart';
import 'package:prijevoz_kalkulator/widgets/autocesta_sekcija_widget.dart';
import 'package:prijevoz_kalkulator/widgets/nocenje_sekcija_widget.dart';
import 'package:prijevoz_kalkulator/widgets/unos_rute_widget.dart';
import 'package:prijevoz_kalkulator/utils/pdf_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  String naziv, vlasnik, adresa, grad, oib, telefon, email, banka, iban;
  bool uSustavuPdv;

  PrijevoznikModel({
    this.naziv = '"Klanac" obrt za prijevoz',
    this.vlasnik = '',
    this.adresa = '',
    this.grad = '',
    this.oib = '52556102683',
    this.telefon = '',
    this.email = '',
    this.banka = '',
    this.iban = '',
    this.uSustavuPdv = true,
  });

  Map<String, dynamic> toJson() => {
    'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad,
    'oib': oib, 'telefon': telefon, 'email': email, 'banka': banka, 'iban': iban, 'uSustavuPdv': uSustavuPdv,
  };

  factory PrijevoznikModel.fromJson(Map<String, dynamic> json) => PrijevoznikModel(
    naziv: json['naziv'] ?? '"Klanac" obrt za prijevoz',
    vlasnik: json['vlasnik'] ?? '',
    adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '',
    oib: json['oib'] ?? '52556102683',
    telefon: json['telefon'] ?? '',
    email: json['email'] ?? '',
    banka: json['banka'] ?? '',
    iban: json['iban'] ?? '',
    uSustavuPdv: json['uSustavuPdv'] ?? true,
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
    naziv: json['naziv'] ?? '',
    vlasnik: json['vlasnik'] ?? '',
    adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '',
    oib: json['oib'] ?? '',
    telefon: json['telefon'] ?? '',
    email: json['email'] ?? '',
    uSustavuPdv: json['uSustavuPdv'] ?? true,
  );
}

class KalkulacijaModel {
  String id, nazivKalkulacije, klijentNaziv, datumPolaska, datumPovratka, vozilo, ruta;
  double ukupnaCijena;
  String polaziste, odrediste1, odrediste2, konacnoOdrediste, cestarina, km;
  bool povratno, koristiAutocestu;
  String odabranaAutocesta, tkoPlacaNocenje, cijenaNocenja, marza, cijenaGoriva, dnevnica;

  KalkulacijaModel({
    required this.id, required this.nazivKalkulacije, required this.klijentNaziv, required this.datumPolaska,
    required this.datumPovratka, required this.vozilo, required this.ruta, required this.ukupnaCijena,
    this.polaziste = 'Zagreb', this.odrediste1 = '', this.odrediste2 = '', this.konacnoOdrediste = 'Split',
    this.cestarina = '35.00', this.km = '780', this.povratno = true, this.koristiAutocestu = true,
    this.odabranaAutocesta = 'HAC (Hrvatske autoceste)', this.tkoPlacaNocenje = 'Prijevoznik plaća',
    this.cijenaNocenja = '60', this.marza = '20', this.cijenaGoriva = '1.45', this.dnevnica = '80',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nazivKalkulacije': nazivKalkulacije, 'klijentNaziv': klijentNaziv, 'datumPolaska': datumPolaska,
    'datumPovratka': datumPovratka, 'vozilo': vozilo, 'ruta': ruta, 'ukupnaCijena': ukupnaCijena,
    'polaziste': polaziste, 'odrediste1': odrediste1, 'odrediste2': odrediste2, 'konacnoOdrediste': konacnoOdrediste,
    'cestarina': cestarina, 'km': km, 'povratno': povratno, 'koristiAutocestu': koristiAutocestu,
    'odabranaAutocesta': odabranaAutocesta, 'tkoPlacaNocenje': tkoPlacaNocenje, 'cijenaNocenja': cijenaNocenja,
    'marza': marza, 'cijenaGoriva': cijenaGoriva, 'dnevnica': dnevnica,
  };

  factory KalkulacijaModel.fromJson(Map<String, dynamic> json) => KalkulacijaModel(
    id: json['id'] ?? '', nazivKalkulacije: json['nazivKalkulacije'] ?? '', klijentNaziv: json['klijentNaziv'] ?? '',
    datumPolaska: json['datumPolaska'] ?? '', datumPovratka: json['datumPovratka'] ?? '', vozilo: json['vozilo'] ?? '',
    ruta: json['ruta'] ?? '', ukupnaCijena: json['ukupnaCijena'] ?? 0.0, polaziste: json['polaziste'] ?? 'Zagreb',
    odrediste1: json['odrediste1'] ?? '', odrediste2: json['odrediste2'] ?? '', konacnoOdrediste: json['konacnoOdrediste'] ?? 'Split',
    cestarina: json['cestarina'] ?? '35.00', km: json['km'] ?? '780', povratno: json['povratno'] ?? true,
    koristiAutocestu: json['koristiAutocestu'] ?? true, odabranaAutocesta: json['odabranaAutocesta'] ?? 'HAC (Hrvatske autoceste)',
    tkoPlacaNocenje: json['tkoPlacaNocenje'] ?? 'Prijevoznik plaća', cijenaNocenja: json['cijenaNocenja'] ?? '60',
    marza: json['marza'] ?? '20', cijenaGoriva: json['cijenaGoriva'] ?? '1.45', dnevnica: json['dnevnica'] ?? '80',
  );
}

class IbanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();
    if (text.length > 21) text = text.substring(0, 21);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
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
        setState(() => _prijevoznik = PrijevoznikModel.fromJson(doc.data()!));
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
    await FirebaseFirestore.instance.collection('kalkulacije').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> ekrani = [
      IzracunTroskovaTab(
        prijevoznik: _prijevoznik, klijenti: _klijenti, aktivniKlijent: _aktivniKlijent,
        kalkulacijaZaUredivanje: _kalkulacijaZaUredivanje,
        onKlijentChanged: (k) => setState(() => _aktivniKlijent = k),
        onSpremiKalkulaciju: (kalk) {
          setState(() {
            int index = _spremljeneKalkulacije.indexWhere((element) => element.id == kalk.id);
            if (index >= 0) _spremljeneKalkulacije[index] = kalk;
            else _spremljeneKalkulacije.add(kalk);
            _kalkulacijaZaUredivanje = null;
          });
          _spremiPodatkeUFirestore();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalkulacija spremljena!'), backgroundColor: Colors.green));
        },
      ),
      KalkulacijeTab(
        kalkulacije: _spremljeneKalkulacije, prijevoznik: _prijevoznik, klijenti: _klijenti,
        onObrisi: (id) {
          setState(() => _spremljeneKalkulacije.removeWhere((element) => element.id == id));
          _obrisiKalkulacijuIzFirestore(id);
        },
        onUredi: (kalk) {
          var pronadjeni = _klijenti.firstWhere((k) => k.naziv == kalk.klijentNaziv, orElse: () => _klijenti.first);
          setState(() { _aktivniKlijent = pronadjeni; _kalkulacijaZaUredivanje = kalk; _currentIndex = 0; });
        },
      ),
      PostavkeTab(prijevoznik: _prijevoznik, klijenti: _klijenti, onUpdate: () { setState(() {}); _spremiPodatkeUFirestore(); }),
    ];
    return Scaffold(
      body: ekrani[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0284C7),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '1) Izračun'),
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
  const IzracunTroskovaTab({super.key, required this.prijevoznik, required this.klijenti, required this.aktivniKlijent, required this.kalkulacijaZaUredivanje, required this.onKlijentChanged, required this.onSpremiKalkulaciju});
  @override
  State<IzracunTroskovaTab> createState() => _IzracunTroskovaTabState();
}

class _IzracunTroskovaTabState extends State<IzracunTroskovaTab> {
  bool _isLoadingRoute = false;
  final List<Map<String, dynamic>> _bazaRelacijaCestarina = BazaCestarinaData.dioniceCestarina;
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
  final TextEditingController _kmController = TextEditingController(text: '822');
  final TextEditingController _cestarinaController = TextEditingController(text: '0.00');
  
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
  final TextEditingController _dnevnicaController = TextEditingController(text: '50');

  String _tkoPlacaNocenje = 'Bez noćenja';
  final List<String> _opcijeNocenja = [
    'Prijevoznik plaća',
    'Klijent/Agencija plaća (0€ za nas)',
    'Bez noćenja'
  ];
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '120');

  final Map<String, double> _potrosnjaVozila = {'Kombi 8+1': 9.0, 'Mini bus <20': 15.0, 'Midi bus 35': 30.0, 'Veliki autobus 50': 35.0};
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
    _odabranoVozilo = _potrosnjaVozila.keys.last; // Veliki autobus 50
    String danas = _formatirajDatum(DateTime.now());
    _datumPolaskaController = TextEditingController(text: danas);
    _datumPovratkaController = TextEditingController(text: danas);
    _provjeriUredjivanje();
    _preracunajBrojDana();
  }

  @override
  void didUpdateWidget(covariant IzracunTroskovaTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kalkulacijaZaUredivanje != oldWidget.kalkulacijaZaUredivanje) _provjeriUredjivanje();
  }

  void _provjeriUredjivanje() {
    if (widget.kalkulacijaZaUredivanje != null) {
      var k = widget.kalkulacijaZaUredivanje!;
      setState(() {
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
        if (_potrosnjaVozila.containsKey(k.vozilo)) _odabranoVozilo = k.vozilo;
      });
      _preracunajBrojDana();
    }
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
    double gorivoBruto = double.tryParse(_cijenaGorivaController.text) ?? 0;
    double dnevnica = double.tryParse(_dnevnicaController.text) ?? 0;
    double nocenjeBruto = double.tryParse(_cijenaNocenjaController.text) ?? 0;
    double marza = double.tryParse(_marzaController.text) ?? 0;

    double potrosnja = _potrosnjaVozila[_odabranoVozilo] ?? 9.0;
    int brojNocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double cestarinaNeto = (_koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnica * _izracunatiBrojDana;
    double nocenjeNeto = (_tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * brojNocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marza / 100);
    double osnovicaSMarzom = cistiTrosak + zarada;
    
    // Konačna cijena usluge za oba klijenta iznosi isto (puna cijena s uključenim PDV-om)
    double ukupnaCijena = osnovicaSMarzom * 1.25;

    KalkulacijaModel kalk = KalkulacijaModel(
      id: _trenutniIdUredjivanja ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nazivKalkulacije: _nazivKalkulacijeController.text,
      klijentNaziv: widget.aktivniKlijent?.naziv ?? 'Klijent',
      datumPolaska: _datumPolaskaController.text, datumPovratka: _datumPovratkaController.text,
      vozilo: _odabranoVozilo, ruta: '${_polazisteController.text} -> ${_konacnoOdredisteController.text}',
      ukupnaCijena: ukupnaCijena, polaziste: _polazisteController.text, odrediste1: _odrediste1Controller.text,
      odrediste2: _odrediste2Controller.text, konacnoOdrediste: _konacnoOdredisteController.text,
      cestarina: _cestarinaController.text, km: _kmController.text, povratno: _povratnoPutovanje,
      koristiAutocestu: _koristiAutocestu, odabranaAutocesta: _odabranaAutocesta, tkoPlacaNocenje: _tkoPlacaNocenje,
      cijenaNocenja: _cijenaNocenjaController.text, marza: _marzaController.text, cijenaGoriva: _cijenaGorivaController.text, dnevnica: _dnevnicaController.text,
    );
    widget.onSpremiKalkulaciju(kalk);
    setState(() => _trenutniIdUredjivanja = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izračun Troškova Prijevoza', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<KlijentModel>(
              value: widget.aktivniKlijent,
              decoration: const InputDecoration(labelText: 'Klijent', border: OutlineInputBorder()),
              items: widget.klijenti.map((k) => DropdownMenuItem(value: k, child: Text(k.naziv))).toList(),
              onChanged: (val) { widget.onKlijentChanged(val); setState(() {}); },
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

class KalkulacijeTab extends StatelessWidget {
  final List<KalkulacijaModel> kalkulacije;
  final PrijevoznikModel prijevoznik;
  final List<KlijentModel> klijenti;
  final ValueChanged<String> onObrisi;
  final ValueChanged<KalkulacijaModel> onUredi;
  const KalkulacijeTab({super.key, required this.kalkulacije, required this.prijevoznik, required this.klijenti, required this.onObrisi, required this.onUredi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spremljene Kalkulacije i Ponude', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: kalkulacije.isEmpty ? const Center(child: Text('Nema spremljenih kalkulacija.')) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kalkulacije.length,
        itemBuilder: (ctx, idx) {
          var k = kalkulacije[idx];
          bool klijentPdv = klijenti.firstWhere((kl) => kl.naziv == k.klijentNaziv, orElse: () => KlijentModel(id: '', uSustavuPdv: true)).uSustavuPdv;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.nazivKalkulacije, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  const SizedBox(height: 4),
                  Text('Klijent: ${k.klijentNaziv}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Ruta: ${k.ruta}'),
                  Text('Termin: ${k.datumPolaska} - ${k.datumPovratka}'),
                  const SizedBox(height: 6),
                  Text('Ukupno: ${k.ukupnaCijena.toStringAsFixed(2)} EUR', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => onUredi(k),
                        icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                        label: const Text('Uredi', style: TextStyle(color: Colors.blue)),
                      ),
                      TextButton.icon(
                        onPressed: () => PdfGenerator.printajInternuKalkulaciju(k, prijevoznik, klijentUsetPdv: klijentPdv),
                        icon: const Icon(Icons.print, size: 18, color: Colors.indigo),
                        label: const Text('Interna kalkulacija', style: TextStyle(color: Colors.indigo)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => PdfGenerator.printajPonuduPdf(k, prijevoznik, klijentUsetPdv: klijentPdv),
                        icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.green),
                        label: const Text('Ponuda PDF', style: TextStyle(color: Colors.green)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onObrisi(k.id),
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
  final CestarineService _cestarineService = CestarineService();

  late TextEditingController _nazivC;
  late TextEditingController _vlasnikC;
  late TextEditingController _adresaC;
  late TextEditingController _gradC;
  late TextEditingController _oibC;
  late TextEditingController _telC;
  late TextEditingController _emailC;
  late TextEditingController _bankaC;
  late TextEditingController _ibanC;
  late bool _uSustavuPdv;

  @override
  void initState() {
    super.initState();
    _inicijalizirajControllere();
  }

  void _inicijalizirajControllere() {
    _nazivC = TextEditingController(text: widget.prijevoznik.naziv);
    _vlasnikC = TextEditingController(text: widget.prijevoznik.vlasnik);
    _adresaC = TextEditingController(text: widget.prijevoznik.adresa);
    _gradC = TextEditingController(text: widget.prijevoznik.grad);
    _oibC = TextEditingController(text: widget.prijevoznik.oib);
    _telC = TextEditingController(text: widget.prijevoznik.telefon);
    _emailC = TextEditingController(text: widget.prijevoznik.email);
    _bankaC = TextEditingController(text: widget.prijevoznik.banka);
    _ibanC = TextEditingController(text: widget.prijevoznik.iban);
    _uSustavuPdv = widget.prijevoznik.uSustavuPdv;
  }

  void _spremiPostavke() {
    if (_oibC.text.trim().length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OIB mora imati točno 11 znamenki!'), backgroundColor: Colors.red));
      return;
    }
    if (_ibanC.text.trim().length != 21 || !_ibanC.text.toUpperCase().startsWith('HR')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IBAN mora početi s HR i imati točno 21 znak!'), backgroundColor: Colors.red));
      return;
    }

    widget.prijevoznik.naziv = _nazivC.text;
    widget.prijevoznik.vlasnik = _vlasnikC.text;
    widget.prijevoznik.adresa = _adresaC.text;
    widget.prijevoznik.grad = _gradC.text;
    widget.prijevoznik.oib = _oibC.text;
    widget.prijevoznik.telefon = _telC.text;
    widget.prijevoznik.email = _emailC.text;
    widget.prijevoznik.banka = _bankaC.text;
    widget.prijevoznik.iban = _ibanC.text;
    widget.prijevoznik.uSustavuPdv = _uSustavuPdv;

    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Postavke prijevoznika spremljene!'), backgroundColor: Colors.green));
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
              TextField(controller: vlaC, decoration: const InputDecoration(labelText: 'Vlasnik / Kontakt osoba')),
              TextField(controller: adrC, decoration: const InputDecoration(labelText: 'Adresa')),
              TextField(controller: grdC, decoration: const InputDecoration(labelText: 'Grad')),
              TextField(
                controller: oibC,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(labelText: 'OIB (točno 11 znamenki)'),
              ),
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
              if (oibC.text.trim().isNotEmpty && oibC.text.trim().length != 11) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OIB klijenta mora imati točno 11 znamenki!'), backgroundColor: Colors.red));
                return;
              }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Podaci o Vašoj Tvrtki (Prijevoznik)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          const SizedBox(height: 12),
          TextField(controller: _nazivC, decoration: const InputDecoration(labelText: 'Naziv prijevoznika', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _vlasnikC, decoration: const InputDecoration(labelText: 'Vlasnik / Direktor', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _adresaC, decoration: const InputDecoration(labelText: 'Adresa', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _gradC, decoration: const InputDecoration(labelText: 'Grad', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(
            controller: _oibC,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: const InputDecoration(labelText: 'OIB (točno 11 znamenki)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(controller: _telC, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _bankaC, decoration: const InputDecoration(labelText: 'Banka', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(
            controller: _ibanC,
            inputFormatters: [
              IbanInputFormatter(),
              LengthLimitingTextInputFormatter(21),
            ],
            decoration: const InputDecoration(labelText: 'IBAN (npr. HR... - 21 znak)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Prijevoznik je u sustavu PDV-a'),
            value: _uSustavuPdv,
            onChanged: (val) => setState(() => _uSustavuPdv = val ?? true),
          ),
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
          const Divider(height: 40, thickness: 2),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Inicijaliziraj bazu cestarina u Firebase'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            onPressed: () async {
              await _cestarineService.inicijalizirajBazuUFirebaseu();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Baza cestarina inicijalizirana!'), backgroundColor: Colors.green));
              }
            },
          ),
        ],
      ),
    );
  }
}
