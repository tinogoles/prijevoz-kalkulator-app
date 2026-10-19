// lib/services/klijenti_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth/firebase_auth.dart'; // ili odgovarajući import za auth ovisno o projektu

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

  String get _userKey {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? user?.uid ?? 'zadani_korisnik';
  }

  // Dohvat klijenata s Firestore Clouda
  Future<void> ucitajKlijente() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(_userKey)
          .collection('klijenti')
          .get();

      _klijenti = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // osiguravamo da je ID dokumenta spremljen
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Greška pri učitavanju klijenata s Clouda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dodavanje klijenta na Cloud
  Future<void> dodajKlijenta(Map<String, dynamic> klijent) async {
    try {
      final docId = klijent['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      klijent['id'] = docId;

      await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(_userKey)
          .collection('klijenti')
          .doc(docId)
          .set(klijent);

      _klijenti.add(klijent);
      notifyListeners();
    } catch (e) {
      debugPrint('Greška pri dodavanju klijenta na Cloud: $e');
    }
  }

  // Uređivanje klijenta na Cloudu
  Future<void> urediKlijenta(Map<String, dynamic> klijent) async {
    try {
      final id = klijent['id'];
      if (id == null) return;

      await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(_userKey)
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

  // Brisanje klijenta s Clouda
  Future<void> obrisiKlijenta(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('korisnici')
          .doc(_userKey)
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
