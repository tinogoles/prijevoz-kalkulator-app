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

  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = _normalizirajKljuc(gradNaziv);

    try {
      final docSnapshot = await _db.collection('gradovi_mapiranje').doc(gradKey).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        String postajaVal = data['najblizi_ulaz'] ?? data['najblizi_ulaz_a2'] ?? data['izlaz_a2'] ?? '';
        
        return {
          'postaja': postajaVal,
          'koncesionar': data['koncesionar'] ?? 'HAC',
        };
      }
    } catch (e) {
      print('Greška pri dohvaćanju grada: $e');
    }

    return null;
  }

  double? _izvuciCijenuIzDokumenta(Map<String, dynamic> data, String kategorijaVozila) {
    if (data.containsKey(kategorijaVozila) && data[kategorijaVozila] != null) {
      return (data[kategorijaVozila] as num).toDouble();
    }

    Map<String, dynamic> traziU = Map<String, dynamic>.from(data);
    if (data['cijene'] is Map<String, dynamic>) {
      traziU.addAll(Map<String, dynamic>.from(data['cijene']));
    }

    String katLower = kategorijaVozila.toLowerCase();

    for (var entry in traziU.entries) {
      String kljuc = entry.key.toLowerCase();
      var val = entry.value;
      if (val is! num) continue;

      if (katLower.contains('ii.') || katLower.contains('kombi') || katLower.contains('do 3.5t')) {
        if (kljuc.contains('ii.') || kljuc.contains('kombi') || kljuc.contains('skupina2')) return val.toDouble();
      } else if (katLower.contains('iii.') || katLower.contains('midi')) {
        if (kljuc.contains('iii.') || kljuc.contains('midi') || kljuc.contains('skupina3')) return val.toDouble();
      } else if (katLower.contains('iv.') || katLower.contains('veliki')) {
        if (kljuc.contains('iv.') || kljuc.contains('autobus') || kljuc.contains('skupina4')) return val.toDouble();
      } else if (katLower.contains('i.') || katLower.contains('osobna')) {
        if (kljuc.contains('i.') || kljuc.contains('osobna') || kljuc.contains('skupina1')) return val.toDouble();
      }
    }

    return null;
  }

  Future<double> dohvatiCijenuDionice({
    required String ulaz,
    required String izlaz,
    required String kategorijaVozila,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return 0.0;

    String ulazKey = _normalizirajKljuc(ulaz);
    String izlazKey = _normalizirajKljuc(izlaz);

    try {
      var doc1 = await _db.collection('cestarine_dionice').doc('${ulazKey}_$izlazKey').get();
      if (doc1.exists && doc1.data() != null) {
        double? cijena = _izvuciCijenuIzDokumenta(doc1.data()!, kategorijaVozila);
        if (cijena != null && cijena > 0) return cijena;
      }

      var doc2 = await _db.collection('cestarine_dionice').doc('${izlazKey}_$ulazKey').get();
      if (doc2.exists && doc2.data() != null) {
        double? cijena = _izvuciCijenuIzDokumenta(doc2.data()!, kategorijaVozila);
        if (cijena != null && cijena > 0) return cijena;
      }

      final allDocs = await _db.collection('cestarine_dionice').get();
      for (var d in allDocs.docs) {
        String docId = d.id.toLowerCase();
        if (docId.contains(ulazKey.split('_')[0]) && docId.contains(izlazKey.split('_')[0])) {
          double? cijena = _izvuciCijenuIzDokumenta(d.data(), kategorijaVozila);
          if (cijena != null && cijena > 0) return cijena;
        }
      }
    } catch (e) {
      print('Greška pri dohvaćanju cijene dionice: $e');
    }

    return 0.0;
  }

  Future<double> izracunajUkupnuCestarinu({
    required String polaziste,
    required String odrediste,
    String? medustajaliste,
    required String kategorijaVozila,
  }) async {
    final postajaPolaziste = await dohvatiPostajuZaGrad(polaziste);
    final postajaOdrediste = await dohvatiPostajuZaGrad(odrediste);

    if (postajaPolaziste == null || postajaOdrediste == null) return 0.0;

    final String ulaznaPostaja = postajaPolaziste['postaja'] ?? '';
    final String izlaznaPostaja = postajaOdrediste['postaja'] ?? '';

    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedu = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedu?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        double c1 = await dohvatiCijenuDionice(ulaz: ulaznaPostaja, izlaz: meduPostaja, kategorijaVozila: kategorijaVozila);
        double c2 = await dohvatiCijenuDionice(ulaz: meduPostaja, izlaz: izlaznaPostaja, kategorijaVozila: kategorijaVozila);
        return c1 + c2;
      }
    }

    double direktna = await dohvatiCijenuDionice(ulaz: ulaznaPostaja, izlaz: izlaznaPostaja, kategorijaVozila: kategorijaVozila);
    if (direktna > 0) return direktna;

    if (ulaznaPostaja == 'lucko' || izlaznaPostaja == 'lucko') {
      String udaljena = (ulaznaPostaja == 'lucko') ? izlaznaPostaja : ulaznaPostaja;
      double c1 = await dohvatiCijenuDionice(ulaz: 'lucko', izlaz: 'bosiljevo', kategorijaVozila: kategorijaVozila);
      double c2 = await dohvatiCijenuDionice(ulaz: 'bosiljevo', izlaz: udaljena, kategorijaVozila: kategorijaVozila);
      if (c1 > 0 && c2 > 0) return c1 + c2;
    }

    return 0.0;
  }
}
