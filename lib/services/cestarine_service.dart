// lib/services/cestarine_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CestarineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String _normalizirajKljuc(String unos) {
    return unos
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('š', 's')
        .replaceAll('ž', 'z')
        .replaceAll('đ', 'd');
  }

  /// 1. Dohvat naplatne postaje za grad ISKLJUČIVO iz globalne Cloud baze
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = _normalizirajKljuc(gradNaziv);

    try {
      final docSnapshot = await _db
          .collection('globalne_cestarine_gradovi')
          .doc(gradKey)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return {
          'postaja': data['postaja'] ?? '',
          'koncesionar': data['koncesionar'] ?? '',
        };
      }
    } catch (e) {
      print('Greška pri dohvaćanju gradova s Clouda: $e');
    }

    return null;
  }

  /// 2. Izračun cijene dionice ISKLJUČIVO iz globalne Cloud baze cestarina
  Future<double> dohvatiCijenuDionice({
    required String ulaz,
    required String izlaz,
    required String kategorijaVozila,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return 0.0;

    String katKljuc = 'Veliki autobus 50';
    String kLower = kategorijaVozila.toLowerCase();
    if (kLower.contains('kombi') || kLower.contains('8+1')) {
      katKljuc = 'Kombi 8+1';
    } else if (kLower.contains('mini') || kLower.contains('<20')) {
      katKljuc = 'Mini bus <20';
    } else if (kLower.contains('midi') || kLower.contains('35')) {
      katKljuc = 'Midi bus 35';
    } else if (kLower.contains('veliki') || kLower.contains('50') || kLower.contains('autobus')) {
      katKljuc = 'Veliki autobus 50';
    }

    try {
      // Pretraga A -> B
      final query1 = await _db
          .collection('globalne_cestarine_dionice')
          .where('ulaz', isEqualTo: ulaz)
          .where('izlaz', isEqualTo: izlaz)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        final cijene = query1.docs.first.data()['cijene'] as Map<String, dynamic>?;
        if (cijene != null && cijene.containsKey(katKljuc)) {
          return (cijene[katKljuc] as num).toDouble();
        }
      }

      // Pretraga B -> A (obrnuti smjer)
      final query2 = await _db
          .collection('globalne_cestarine_dionice')
          .where('ulaz', isEqualTo: izlaz)
          .where('izlaz', isEqualTo: ulaz)
          .limit(1)
          .get();

      if (query2.docs.isNotEmpty) {
        final cijene = query2.docs.first.data()['cijene'] as Map<String, dynamic>?;
        if (cijene != null && cijene.containsKey(katKljuc)) {
          return (cijene[katKljuc] as num).toDouble();
        }
      }
    } catch (e) {
      print('Greška pri dohvaćanju cijene dionice s Clouda: $e');
    }

    return 0.0;
  }

  /// 3. Glavna funkcija za izračun ukupne cestarine
  Future<double> izracunajUkupnuCestarinu({
    required String polaziste,
    required String odrediste,
    String? medustajaliste,
    required String kategorijaVozila,
  }) async {
    double ukupno = 0.0;

    final postajaPolaziste = await dohvatiPostajuZaGrad(polaziste);
    final postajaOdrediste = await dohvatiPostajuZaGrad(odrediste);

    if (postajaPolaziste == null || postajaOdrediste == null) {
      return 0.0;
    }

    final String ulaznaPostaja = postajaPolaziste['postaja'] ?? '';
    final String izlaznaPostaja = postajaOdrediste['postaja'] ?? '';

    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedustajaliste = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedustajaliste?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        ukupno += await dohvatiCijenuDionice(
          ulaz: ulaznaPostaja,
          izlaz: meduPostaja,
          kategorijaVozila: kategorijaVozila,
        );

        ukupno += await dohvatiCijenuDionice(
          ulaz: meduPostaja,
          izlaz: izlaznaPostaja,
          kategorijaVozila: kategorijaVozila,
        );

        return ukupno;
      }
    }

    ukupno = await dohvatiCijenuDionice(
      ulaz: ulaznaPostaja,
      izlaz: izlaznaPostaja,
      kategorijaVozila: kategorijaVozila,
    );

    return ukupno;
  }
}
