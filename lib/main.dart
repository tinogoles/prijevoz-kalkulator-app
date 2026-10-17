import 'package:prijevoz_kalkulator/services/cestarine_service.dart';
import 'package:prijevoz_kalkulator/data/baza_cestarina_data.dart';
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
  Map<String, dynamic> toJson() => {'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad, 'oib': oib, 'telefon': telefon, 'email': email, 'uSustavuPdv': uSustavuPdv};
  factory PrijevoznikModel.fromJson(Map<String, dynamic> json) => PrijevoznikModel(
    naziv: json['naziv'] ?? '', vlasnik: json['vlasnik'] ?? '', adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '', oib: json['oib'] ?? '', telefon: json['telefon'] ?? '',
    email: json['email'] ?? '', uSustavuPdv: json['uSustavuPdv'] ?? true,
  );
}

class KlijentModel {
  String id, naziv, vlasnik, adresa, grad, oib, telefon, email;
  bool uSustavuPdv;
  KlijentModel({required this.id, this.naziv = '', this.vlasnik = '', this.adresa = '', this.grad = '', this.oib = '', this.telefon = '', this.email = '', this.uSustavuPdv = true});
  Map<String, dynamic> toJson() => {'id': id, 'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad, 'oib': oib, 'telefon': telefon, 'email': email, 'uSustavuPdv': uSustavuPdv};
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
  final List<String> _opcijeAutocesta = ['HAC (Hrvatske autoceste)', 'AZM (Zagreb - Macelj)', 'DARS (Slovenske autoceste)', 'Autoceste FBiH / RS', 'Bez autoceste'];
  final TextEditingController _cijenaGorivaController = TextEditingController(text: '1.45');
  final TextEditingController _dnevnicaController = TextEditingController(text: '80');
  String _tkoPlacaNocenje = 'Prijevoznik plaća';
  final List<String> _opcijeNocenja = ['Prijevoznik plaća', 'Klijent plaća', 'Bez noćenja'];
  final TextEditingController _cijenaNocenjaController = TextEditingController(text: '60');
  final TextEditingController _marzaController = TextEditingController(text: '20');
  final Map<String, double> _potrosnjaVozila = {'Kombi 8+1': 9.0, 'Mini bus <20': 15.0, 'Midi bus 35': 30.0, 'Veliki autobus 50': 35.0};
  late String _odabranoVozilo;
  String? _trenutniIdUredjivanja;

  String _formatirajDatum(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  @override
  void initState() {
    super.initState();
    _odabranoVozilo = _potrosnjaVozila.keys.first;
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
    }
  }

  Future<void> _odaberiDatum(BuildContext context, TextEditingController controller) async {
    final DateTime? odabir = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (odabir != null) { setState(() { controller.text = _formatirajDatum(odabir); _preracunajBrojDana(); }); }
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

  void _automatskiDetektirajCestarinu(List<String> tocke) {
    String spojeneTocke = tocke.join(' ').toLowerCase();
    for (var relacija in _bazaRelacijaCestarina) {
      List<String> kljucneRijeci = relacija['kljucneRijeci'];
      if (kljucneRijeci.every((rijec) => spojeneTocke.contains(rijec))) {
        setState(() {
          _koristiAutocestu = true;
          _odabranaAutocesta = relacija['nazivAutoceste'];
          Map<String, dynamic> cestarineMap = relacija['cestarine'];
          if (cestarineMap.containsKey(_odabranoVozilo)) {
            double jednosmjerna = cestarineMap[_odabranoVozilo];
            _cestarinaController.text = (jednosmjerna * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(2);
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
      _automatskiDetektirajCestarinu(tocke);
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
    int nocenja = (_izracunatiBrojDana > 1) ? (_izracunatiBrojDana - 1) : 0;

    double gorivoNeto = ((km / 100) * potrosnja * gorivoBruto) / 1.25;
    double cestarinaNeto = (_koristiAutocestu ? cestarinaBruto : 0) / 1.25;
    double trosakVozaca = dnevnica * _izracunatiBrojDana;
    double nocenjeNeto = (_tkoPlacaNocenje == 'Prijevoznik plaća' ? (nocenjeBruto * nocenja) : 0) / 1.25;

    double cistiTrosak = gorivoNeto + cestarinaNeto + trosakVozaca + nocenjeNeto;
    double zarada = cistiTrosak * (marza / 100);
    double osnovica = cistiTrosak + zarada;
    bool klijentPdv = widget.aktivniKlijent?.uSustavuPdv ?? true;
    double ukupnaCijena = klijentPdv ? (osnovica * 1.25) : osnovica;

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
      appBar: AppBar(title: const Text('Izračun Troškova', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
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
            TextField(controller: _polazisteController, decoration: const InputDecoration(labelText: 'Polazište', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _odrediste1Controller, decoration: const InputDecoration(labelText: 'Međuodredište A (opcionalno)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _odrediste2Controller, decoration: const InputDecoration(labelText: 'Međuodredište B (opcionalno)', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: _konacnoOdredisteController, decoration: const InputDecoration(labelText: 'Konačno odredište', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Povratno putovanje'),
              value: _povratnoPutovanje,
              onChanged: (val) {
                setState(() {
                  _povratnoPutovanje = val ?? true;
                  _kmController.text = (_bazaKmJednosmjerno * (_povratnoPutovanje ? 2.0 : 1.0)).toStringAsFixed(0);
                });
              },
            ),
            TextField(controller: _kmController, decoration: const InputDecoration(labelText: 'Kilometri', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _datumPolaskaController, readOnly: true, onTap: () => _odaberiDatum(context, _datumPolaskaController), decoration: const InputDecoration(labelText: 'Polazak', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _datumPovratkaController, readOnly: true, onTap: () => _odaberiDatum(context, _datumPovratkaController), decoration: const InputDecoration(labelText: 'Povratak', border: OutlineInputBorder()))),
            ]),
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
              Expanded(child: TextField(controller: _dnevnicaController, decoration: const InputDecoration(labelText: 'Dnevnica (€)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            TextField(controller: _marzaController, decoration: const InputDecoration(labelText: 'Marža (%)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoadingRoute ? null : _izracunajRutuMultiPoint,
              icon: const Icon(Icons.route),
              label: Text(_isLoadingRoute ? 'Računam...' : 'Izračunaj kilometre preko OSRM'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _spremi,
              icon: const Icon(Icons.save),
              label: Text(_trenutniIdUredjivanja == null ? 'Spremi kalkulaciju' : 'Ažuriraj kalkulaciju'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
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

  void _printaj(KalkulacijaModel k) async {
    Printing.layoutPdf(onLayout: (format) async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Kalkulacija: ${k.nazivKalkulacije}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('Klijent: ${k.klijentNaziv}'),
        pw.Text('Ruta: ${k.ruta} (${k.km} km)'),
        pw.Text('Cijena: ${k.ukupnaCijena.toStringAsFixed(2)} €', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ])));
      return pdf.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spremljene kalkulacije', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: kalkulacije.isEmpty ? const Center(child: Text('Nema spremljenih kalkulacija.')) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kalkulacije.length,
        itemBuilder: (ctx, idx) {
          var k = kalkulacije[idx];
          return Card(
            child: ListTile(
              title: Text(k.nazivKalkulacije, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${k.klijentNaziv} | ${k.ukupnaCijena.toStringAsFixed(2)} €'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => onUredi(k)),
                  IconButton(icon: const Icon(Icons.print, color: Colors.indigo), onPressed: () => _printaj(k)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onObrisi(k.id)),
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
  late TextEditingController _nazivC = TextEditingController(text: widget.prijevoznik.naziv);
  late TextEditingController _oibC = TextEditingController(text: widget.prijevoznik.oib);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postavke', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).colorScheme.primary, centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nazivC, decoration: const InputDecoration(labelText: 'Naziv prijevoznika')),
          const SizedBox(height: 8),
          TextField(controller: _oibC, decoration: const InputDecoration(labelText: 'OIB')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              widget.prijevoznik.naziv = _nazivC.text;
              widget.prijevoznik.oib = _oibC.text;
              widget.onUpdate();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spremljeno!')));
            },
            child: const Text('Spremi postavke'),
          ),
          const Divider(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Inicijaliziraj bazu cestarina u Firebase'),
            onPressed: () async {
              await _cestarineService.inicijalizirajBazuUFirebaseu();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Baza cestarina inicijalizirana!')));
            },
          ),
        ],
      ),
    );
  }
}
