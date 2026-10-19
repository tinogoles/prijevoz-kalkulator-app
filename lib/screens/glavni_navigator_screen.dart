import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prijevoznik_model.dart';
import '../models/klijent_model.dart';
import '../models/kalkulacija_model.dart';
import 'izracun_troskova_tab.dart';
import 'kalkulacije_tab.dart';
import 'postavke_tab.dart';

class GlavniNavigatorScreen extends StatefulWidget {
  const GlavniNavigatorScreen({super.key});

  @override
  State<GlavniNavigatorScreen> createState() => _GlavniNavigatorScreenState();
}

class _GlavniNavigatorScreenState extends State<GlavniNavigatorScreen> {
  int _currentIndex = 0;
  PrijevoznikModel _prijevoznik = PrijevoznikModel(naziv: 'Moj Obrt', oib: '', grad: '');
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

    // Slušanje postavki prijevoznika
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('postavke')
        .doc('glavne')
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted && doc.data() != null) {
        var data = doc.data()!;
        setState(() {
          _prijevoznik = PrijevoznikModel(
            naziv: data['nazivPrijevoznika'] ?? data['naziv'] ?? '',
            oib: data['oib'] ?? '',
            adresa: data['adresa'] ?? '',
            grad: data['grad'] ?? '',
            iban: data['iban'] ?? '',
            banka: data['banka'] ?? '',
            email: data['email'] ?? '',
          );
        });
      }
    });

    // Slušanje klijenata
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('klijenti')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _klijenti = snapshot.docs.map((d) {
            var m = d.data();
            return KlijentModel.fromJson(m, docId: d.id);
          }).toList();
          if (_klijenti.isNotEmpty && (_aktivniKlijent == null || !_klijenti.any((k) => k.id == _aktivniKlijent?.id))) {
            _aktivniKlijent = _klijenti.first;
          } else if (_klijenti.isEmpty) {
            _aktivniKlijent = null;
          }
        });
      }
    });

    // Slušanje kalkulacija
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('kalkulacije')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _kalkulacije = snapshot.docs.map<KalkulacijaModel>((d) {
            var m = d.data();
            m['id'] = d.id;
            return KalkulacijaModel.fromJson(m);
          }).toList();
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
        .set(kalk.toJson());

    setState(() {
      _kalkulacijaZaUredivanje = null;
      _currentIndex = 1;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kalkulacija uspješno spremljena!'), backgroundColor: Colors.green),
      );
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> stranice = [
      IzracunTroskovaTab(
        prijevoznik: _prijevoznik,
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
            _currentIndex = 0;
          });
        },
      ),
      const PostavkeTab(),
    ];

    return Scaffold(
      body: stranice[_currentIndex >= stranice.length ? 0 : _currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex >= stranice.length ? 0 : _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0284C7),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Izračun'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Kalkulacije'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Postavke'),
        ],
      ),
    );
  }
}
