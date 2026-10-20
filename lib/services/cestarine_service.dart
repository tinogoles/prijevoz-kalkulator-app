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
          .collection('cestarine_gradovi')
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
    
    // Direktno mapiramo kategoriju vozila na točne ključeve u bazi (skupina1 - skupina4)
    String dbKljuc = 'skupina2'; // Default

    if (kLower.contains('iv.') || kLower.contains('4+')) {
      dbKljuc = 'skupina4';
    } else if (kLower.contains('iii.') || kLower.contains('2-3')) {
      dbKljuc = 'skupina3';
    } else if (kLower.contains('ii.') || kLower.contains('kombi') || kLower.contains('do 3.5t')) {
      dbKljuc = 'skupina2';
    } else if (kLower.contains('i.') || kLower.contains('osobna')) {
      dbKljuc = 'skupina1';
    }

    print('CESTARISE_SERVICE: Tražim dionicu Ulaz: "$ulaz", Izlaz: "$izlaz" za ključ: "$dbKljuc" (iz kategorije: "$kategorijaVozila")');

    try {
      double? pronadjiCijenuUDokumentu(Map<String, dynamic> docData) {
        print('Pronađen dokument u bazi. Polja u dokumentu: ${docData.keys.toList()}');
        
        // 1. Provjera izravnog polja na root razini (npr. skupina2)[cite: 11]
        if (docData.containsKey(dbKljuc) && docData[dbKljuc] != null) {
          double val = (docData[dbKljuc] as num).toDouble();
          print('Pronađena cijena direktno po ključu $dbKljuc: $val');
          return val;
        }

        // 2. Provjera unutar mape 'cijene' ako postoji
        final cijeneMap = docData['cijene'] as Map<String, dynamic>?;
        if (cijeneMap != null) {
          if (cijeneMap.containsKey(dbKljuc) && cijeneMap[dbKljuc] != null) {
            double val = (cijeneMap[dbKljuc] as num).toDouble();
            print('Pronađena cijena unutar mape cijene po ključu $dbKljuc: $val');
            return val;
          }
        }
        
        print('Ključ $dbKljuc nije pronađen u ovom dokumentu.');
        return null;
      }

      // Pretraga A -> B u kolekciji cestarine_dionice
      final query1 = await _db
          .collection('cestarine_dionice')
          .where('ulaz', isEqualTo: ulaz)
          .where('izlaz', isEqualTo: izlaz)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        double? cijena = pronadjiCijenuUDokumentu(query1.docs.first.data());
        if (cijena != null && cijena > 0) return cijena;
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
        if (cijena != null && cijena > 0) return cijena;
      }
    } catch (e) {
      print('Greška pri dohvaćanju cijene dionice s Clouda: $e');
    }

    print('Nije pronađena cijena za dionicu $ulaz -> $izlaz');
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
      print('Postaje nisu pronađene za gradove: $polaziste -> $odrediste');
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
