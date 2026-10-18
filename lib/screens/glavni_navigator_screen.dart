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
  PrijevoznikModel _prijevoznik = PrijevoznikModel();
  List<KlijentModel> _klijenti = [];
  List<KalkulacijaModel> _spremljeneKalkulacije = [];
  KlijentModel? _aktivniKlijent;
  KalkulacijaModel? _kalkulacijaZaUredivanje;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _ucitajPodatkeIzFirestore();
  }

  void _ucitajPodatkeIzFirestore() {
    if (_userId.isEmpty) return;
    final firestore = FirebaseFirestore.instance;
    
    firestore.collection('users').doc(_userId).collection('postavke').doc('prijevoznik').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        setState(() => _prijevoznik = PrijevoznikModel.fromJson(doc.data()!));
      }
    });

    firestore.collection('users').doc(_userId).collection('klijenti').snapshots().listen((snapshot) {
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

    firestore.collection('users').doc(_userId).collection('kalkulacije').snapshots().listen((snapshot) {
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
    if (_userId.isEmpty) return;
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(_userId).collection('postavke').doc('prijevoznik').set(_prijevoznik.toJson());
    for (var kalk in _spremljeneKalkulacije) {
      await firestore.collection('users').doc(_userId).collection('kalkulacije').doc(kalk.id).set(kalk.toJson());
    }
  }

  Future<void> _obrisiKalkulacijuIzFirestore(String id) async {
    if (_userId.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(_userId).collection('kalkulacije').doc(id).delete();
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
