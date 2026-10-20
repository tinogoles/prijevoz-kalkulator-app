// lib/services/klijenti_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KlijentiService extends ChangeNotifier {
  static final KlijentiService _instance = KlijentiService._internal();
  factory KlijentiService() => _instance;
  KlijentiService._internal();

  List<Map<String, dynamic>> _klijenti = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get klijenti => _klijenti;
  bool get isLoading => _isLoading;

  List<String> get naziviKlijenata =>
      _klijenti.map((k) => k['naziv'].toString()).toList();

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('UPOZORENJE: Korisnik nije prijavljen!');
      return '';
    }
    return user.uid;
  }

  // Čisto učitavanje isključivo s users/{userId}/klijenti
  Future<void> ucitajKlijente() async {
    if (_userId.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('klijenti')
          .get();

      _klijenti = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Greška pri učitavanju klijenata s Clouda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dodavanje klijenta isključivo na users/{userId}/klijenti
  Future<void> dodajKlijenta(Map<String, dynamic> klijent) async {
    if (_userId.isEmpty) return;
    try {
      final docId = klijent['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      klijent['id'] = docId;
      klijent['userId'] = _userId;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('klijenti')
          .doc(docId)
          .set(klijent, SetOptions(merge: true));

      _klijenti.add(klijent);
      notifyListeners();
    } catch (e) {
      debugPrint('Greška pri dodavanju klijenta na Cloud: $e');
    }
  }

  // Uređivanje klijenta
  Future<void> urediKlijenta(Map<String, dynamic> klijent) async {
    if (_userId.isEmpty) return;
    try {
      final id = klijent['id'];
      if (id == null) return;
      klijent['userId'] = _userId;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('klijenti')
          .doc(id.toString())
          .set(klijent, SetOptions(merge: true));

      final idx = _klijenti.indexWhere((k) => k['id'] == id);
      if (idx != -1) {
        _klijenti[idx] = klijent;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Greška pri uređivanju klijenta na Cloudu: $e');
    }
  }

  // Brisanje klijenta
  Future<void> obrisiKlijenta(String id) async {
    if (_userId.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('klijenti')
          .doc(id)
          .delete();

      _klijenti.removeWhere((k) => k['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Greška pri brisanju klijenta s Clouda: $e');
    }
  }
}
