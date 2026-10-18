import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import 'izracun_troskova_tab.dart';
import 'kalkulacije_tab.dart';
import 'klijenti_tab.dart';
import 'postavke_tab.dart';

class GlavniNavigatorScreen extends StatefulWidget {
  const GlavniNavigatorScreen({super.key});

  @override
  State<GlavniNavigatorScreen> createState() => _GlavniNavigatorScreenState();
}

class _GlavniNavigatorScreenState extends State<GlavniNavigatorScreen> {
  int _currentIndex = 0;
  PrijevoznikModel _prijevoznik = PrijevoznikModel(id: '1', naziv: 'Moj Obrt', oib: '', grad: '');
  List<KlijentModel> _klijenti = [];
  KlijentModel? _aktivniKlijent;
  List<KalkulacijaModel> _kalkulacije = [];
  KalkulacijaModel? _kalkulacijaZaUredivanje;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _ucitajPodatkeIzFirestore();
  }

  void _ucitajPodatkeIzFirestore() {
    if (_userId.isEmpty) return;

    // Slušanje postavki prijevoznika specifičnih za korisnika
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('postavke')
        .doc('prijevoznik')
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          _prijevoznik = PrijevoznikModel.fromMap(doc.data()!, doc.id);
        });
      }
    });

    // Slušanje klijenata specifičnih za korisnika
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('klijenti')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _klijenti = snapshot.docs.map((d) => KlijentModel.fromMap(d.data(), d.id)).toList();
          if (_klijenti.isNotEmpty && _aktivniKlijent == null) {
            _aktivniKlijent = _klijenti.first;
          }
        });
      }
    });

    // Slušanje kalkulacija specifičnih za korisnika
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('kalkulacije')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _kalkulacije = snapshot.docs.map((d) => KalkulacijaModel.fromMap(d.data(), d.id)).toList();
        });
      }
    });
  }

  Future<void> _spremiKalkulacijuUBazu(KalkulacijaModel kalk) async {
    if (_userId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('kalkulacije')
        .doc(kalk.id)
        .set(kalk.toMap());

    setState(() {
      _kalkulacijaZaUredivanje = null;
      _currentIndex = 1; // Prebaci na tab kalkulacija
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalkulacija uspješno spremljena!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _obrisiKalkulacijuIzBaze(String id) async {
    if (_userId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('kalkulacije')
        .doc(id)
        .delete();
  }

  Future<void> _azurirajPostavkePrijevoznika() async {
    if (_userId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('postavke')
        .doc('prijevoznik')
        .set(_prijevoznik.toMap());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stranice = [
      IzracunTroskovaTab(
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        aktivniKlijent: _aktivniKlijent,
        kalkulacijaZaUredivanje: _kalkulacijaZaUredivanje,
        onKlijentChanged: (k) => setState(() => _aktivniKlijent = k),
        onSpremiKalkulaciju: _spremiKalkulacijuUBazu,
      ),
      KalkulacijeTab(
        kalkulacije: _kalkulacije,
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        onObrisi: _obrisiKalkulacijuIzBaze,
        onUredi: (k) {
          setState(() {
            _kalkulacijaZaUredivanje = k;
            _currentIndex = 0; // Vrati na tab za izračun
          });
        },
      ),
      KlijentiTab(
        klijenti: _klijenti,
        userId: _userId, // Proslijeđujemo userId za Firestore akcije u KlijentiTab-u ako je potrebno
      ),
      PostavkeTab(
        prijevoznik: _prijevoznik,
        klijenti: _klijenti,
        onUpdate: _azurirajPostavkePrijevoznika,
      ),
    ];

    return Scaffold(
      body: stranice[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0284C7),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Izračun'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Kalkulacije'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Klijenti'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Postavke'),
      ],
      ),
    );
  }
}
