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

  /// 1. Dohvat naplatne postaje za grad iz baze gradovi_mapiranje
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = _normalizirajKljuc(gradNaziv);

    try {
      final docSnapshot = await _db
          .collection('gradovi_mapiranje')
          .doc(gradKey)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        
        String postajaVal = data['najblizi_ulaz'] ?? data['izlaz_a2'] ?? '';
        
        return {
          'postaja': postajaVal,
          'koncesionar': data['koncesionar'] ?? 'HAC',
        };
      }
    } catch (e) {
      print('Greška pri dohvaćanju gradova s Clouda: $e');
    }

    return null;
  }

  /// 2. Izračun cijene dionice direktno preko ID-ja i fleksibilnog pretraživanja
  Future<double> dohvatiCijenuDionice({
    required String ulaz,
    required String izlaz,
    required String kategorijaVozila,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return 0.0;

    String ulazKey = _normalizirajKljuc(ulaz);
    String izlazKey = _normalizirajKljuc(izlaz);

    String kLower = kategorijaVozila.toLowerCase();
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

    print('CESTARISE_SERVICE: Tražim dionicu Ulaz: "$ulazKey", Izlaz: "$izlazKey" za ključ: "$dbKljuc"');

    try {
      double? pronadjiCijenuUDokumentu(Map<String, dynamic> docData) {
        if (docData.containsKey(dbKljuc) && docData[dbKljuc] != null) {
          return (docData[dbKljuc] as num).toDouble();
        }
        final cijeneMap = docData['cijene'] as Map<String, dynamic>?;
        if (cijeneMap != null && cijeneMap[dbKljuc] != null) {
          return (cijeneMap[dbKljuc] as num).toDouble();
        }
        return null;
      }

      // 1. Pokušaj točnog dohvata po ID-ju: ulaz_izlaz
      var doc1 = await _db.collection('cestarine_dionice').doc('${ulazKey}_$izlazKey').get();
      if (doc1.exists && doc1.data() != null) {
        double? val = pronadjiCijenuUDokumentu(doc1.data()!);
        if (val != null && val > 0) return val;
      }

      // 2. Pokušaj obrnutog dohvata po ID-ju: izlaz_ulaz
      var doc2 = await _db.collection('cestarine_dionice').doc('${izlazKey}_$ulazKey').get();
      if (doc2.exists && doc2.data() != null) {
        double? val = pronadjiCijenuUDokumentu(doc2.data()!);
        if (val != null && val > 0) return val;
      }

      // 3. Fleksibilna pretraga preko svih dokumenata (za slučajeve sa sufiksima poput zadar_istok)
      final allDocs = await _db.collection('cestarine_dionice').get();
      for (var d in allDocs.docs) {
        String docId = d.id.toLowerCase();
        if (docId.contains(ulazKey.split('_')[0]) && docId.contains(izlazKey.split('_')[0])) {
          double? val = pronadjiCijenuUDokumentu(d.data());
          if (val != null && val > 0) return val;
        }
      }
    } catch (e) {
      print('Greška pri dohvaćanju cijene dionice s Clouda: $e');
    }

    print('Nije pronađena cijena za dionicu $ulaz -> $izlaz');
    return 0.0;
  }

  /// 3. Glavna funkcija za izračun ukupne cestarine (sa automatskim tranzitom preko Bosiljeva)
  Future<double> izracunajUkupnuCestarinu({
    required String polaziste,
    required String odrediste,
    String? medustajaliste,
    required String kategorijaVozila,
  }) async {
    final postajaPolaziste = await dohvatiPostajuZaGrad(polaziste);
    final postajaOdrediste = await dohvatiPostajuZaGrad(odrediste);

    if (postajaPolaziste == null || postajaOdrediste == null) {
      print('Postaje nisu pronađene za gradove: $polaziste -> $odrediste');
      return 0.0;
    }

    final String ulaznaPostaja = postajaPolaziste['postaja'] ?? '';
    final String izlaznaPostaja = postajaOdrediste['postaja'] ?? '';

    // Ako imamo međuodredište
    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedustajaliste = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedustajaliste?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        double c1 = await dohvatiCijenuDionice(ulaz: ulaznaPostaja, izlaz: meduPostaja, kategorijaVozila: kategorijaVozila);
        double c2 = await dohvatiCijenuDionice(ulaz: meduPostaja, izlaz: izlaznaPostaja, kategorijaVozila: kategorijaVozila);
        return c1 + c2;
      }
    }

    // 1. Pokušaj direktnog izračuna dionice
    double direktnaCijena = await dohvatiCijenuDionice(
      ulaz: ulaznaPostaja,
      izlaz: izlaznaPostaja,
      kategorijaVozila: kategorijaVozila,
    );

    if (direktnaCijena > 0) {
      return direktnaCijena;
    }

    // 2. Automatski tranzit preko Bosiljeva (za relacije koje idu preko Zagreba/Lučkog prema Rijeci, Splitu, Zadru...)
    if (ulaznaPostaja == 'lucko' || izlaznaPostaja == 'lucko') {
      String udaljenaPostaja = (ulaznaPostaja == 'lucko') ? izlaznaPostaja : ulaznaPostaja;

      double c1 = await dohvatiCijenuDionice(ulaz: 'lucko', izlaz: 'bosiljevo', kategorijaVozila: kategorijaVozila);
      double c2 = await dohvatiCijenuDionice(ulaz: 'bosiljevo', izlaz: udaljenaPostaja, kategorijaVozila: kategorijaVozila);

      if (c1 > 0 && c2 > 0) {
        return c1 + c2;
      }
    }

    return 0.0;
  }
}
