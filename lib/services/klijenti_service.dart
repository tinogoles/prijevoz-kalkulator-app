import 'package:flutter/material.dart';

class KlijentiService extends ChangeNotifier {
  static final KlijentiService _instance = KlijentiService._internal();
  factory KlijentiService() => _instance;
  KlijentiService._internal();

  final List<Map<String, dynamic>> _klijenti = [
    {
      'id': '1',
      'naziv': 'Dječji vrtić Omiš',
      'odgovornaOsoba': 'Ravnateljica Ana Anić',
      'adresa': 'Četvrt Vrilo 23',
      'grad': '21250 Omiš',
      'oib': '32145678910',
      'email': 'info@dv-omis.hr',
      'telefon': '+385 21 862 111',
      'banka': 'Erste & Steiermärkische Bank',
      'iban': 'HR1224020061100000000',
      'uSustavuPdvA': false,
    },
    {
      'id': '2',
      'naziv': 'OŠ 1. listopada 1942 Čišla',
      'odgovornaOsoba': 'Ravnatelj Marko Marković',
      'adresa': 'Čišla bb',
      'grad': '21252 Gata',
      'oib': '12345678901',
      'email': 'os-cisla@skole.hr',
      'telefon': '+385 21 868 010',
      'banka': 'Privredna banka Zagreb',
      'iban': 'HR4023400091100000000',
      'uSustavuPdvA': false,
    },
  ];

  List<Map<String, dynamic>> get klijenti => _klijenti;

  List<String> get naziviKlijenata =>
      _klijenti.map((k) => k['naziv'].toString()).toList();

  void dodajKlijenta(Map<String, dynamic> klijent) {
    _klijenti.add(klijent);
    notifyListeners();
  }

  void urediKlijenta(Map<String, dynamic> klijent) {
    final idx = _klijenti.indexWhere((k) => k['id'] == klijent['id']);
    if (idx != -1) {
      _klijenti[idx] = klijent;
      notifyListeners();
    }
  }

  void obrisiKlijenta(String id) {
    _klijenti.removeWhere((k) => k['id'] == id);
    notifyListeners();
  }
}
