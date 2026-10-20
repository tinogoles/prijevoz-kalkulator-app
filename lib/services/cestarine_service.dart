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

  /// 1. Dohvat naplatne postaje za grad iz baze cestarine_gradovi
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = _normalizirajKljuc(gradNaziv);

    try {
      final docSnapshot = await _db
          .collection('cestarine_gradovi') // Ispravljen naziv kolekcije prema bazi
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

  /// 2. Izračun cijene dionice iz baze cestarine_dionice
  Future<double> dohvatiCijenuDionice({
    required String ulaz,
    required String izlaz,
    required String kategorijaVozila,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return 0.0;

    String kLower = kategorijaVozila.toLowerCase();
    
    // Određujemo koji ključevi odgovaraju odabranoj kategoriji vozila u bazi
    List<String> moguciKljucevi = [];

    if (kLower.contains('iv.') || kLower.contains('veliki autobus') || kLower.contains('skupina 4') || kLower.contains('4+')) {
      moguciKljucevi = ['skupina4', 'Veliki autobus 50', 'IV. Skupina'];
    } else if (kLower.contains('iii.') || kLower.contains('midi bus') || kLower.contains('skupina 3') || kLower.contains('2-3')) {
      moguciKljucevi = ['skupina3', 'Midi bus 35', 'III. Skupina'];
    } else if (kLower.contains('ii.') || kLower.contains('kombi') || kLower.contains('skupina 2') || kLower.contains('do 3.5t')) {
      moguciKljucevi = ['skupina2', 'Kombi 8+1', 'Mini bus <20', 'II. Skupina'];
    } else if (kLower.contains('i.') || kLower.contains('osobna') || kLower.contains('skupina 1')) {
      moguciKljucevi = ['skupina1', 'I. Skupina', 'Osobna vozila'];
    } else {
      moguciKljucevi = [kategorijaVozila, 'skupina2', 'Kombi 8+1'];
    }

    try {
      double? pronadjiCijenuUDokumentu(Map<String, dynamic> docData) {
        // 1. Provjera izravnih polja na root razini dokumenta (npr. skupina1, skupina2...)[cite: 12]
        for (String kljuc in moguciKljucevi) {
          if (docData.containsKey(kljuc) && docData[kljuc] != null) {
            return (docData[kljuc] as num).toDouble();
          }
        }

        // 2. Provjera unutar mape 'cijene' (npr. "Kombi 8+1", "Midi bus 35"...)[cite: 12]
        final cijeneMap = docData['cijene'] as Map<String, dynamic>?;
        if (cijeneMap != null) {
          for (String kljuc in moguciKljucevi) {
            if (cijeneMap.containsKey(kljuc) && cijeneMap[kljuc] != null) {
              return (cijeneMap[kljuc] as num).toDouble();
            }
          }
          // Fleksibilno traženje po djelomičnom nazivu
          for (var entry in cijeneMap.entries) {
            String dbKeyLower = entry.key.toLowerCase();
            for (String trazeni in moguciKljucevi) {
              if (dbKeyLower.contains(trazeni.toLowerCase()) || trazeni.toLowerCase().contains(dbKeyLower)) {
                return (entry.value as num).toDouble();
              }
            }
          }
        }
        return null;
      }

      // Pretraga A -> B u ispravnoj kolekciji cestarine_dionice[cite: 12]
      final query1 = await _db
          .collection('cestarine_dionice')
          .where('ulaz', isEqualTo: ulaz)
          .where('izlaz', isEqualTo: izlaz)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        double? cijena = pronadjiCijenuUDokumentu(query1.docs.first.data());
        if (cijena != null) return cijena;
      }

      // Pretraga B -> A (obrnuti smjer)
      final query2 = await _db
          .collection('cestarine_dionice')
          .where('ulaz', isEqualTo: izlaz)
          .where('izlaz', isEqualTo: ulaz)
          .limit(1)
          .get();

      if (query2.docs.isNotEmpty) {
        double? cijena = pronadjiCijenuUDokumentu(query2.docs.first.data());
        if (cijena != null) return cijena;
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
