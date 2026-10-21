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

  Future<Map<String, dynamic>?> dohvatiDokumentDionice({
    required String ulaz,
    required String izlaz,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return null;

    String ulazKey = _normalizirajKljuc(ulaz);
    String izlazKey = _normalizirajKljuc(izlaz);

    try {
      var doc1 = await _db.collection('cestarine_dionice').doc('${ulazKey}_$izlazKey').get();
      if (doc1.exists && doc1.data() != null) return doc1.data();

      var doc2 = await _db.collection('cestarine_dionice').doc('${izlazKey}_$ulazKey').get();
      if (doc2.exists && doc2.data() != null) return doc2.data();
    } catch (e) {
      print('Greška pri dohvaćanju dokumenta dionice: $e');
    }

    return null;
  }

  // Glavna metoda obogaćena provjerom prekidača (toggle stanja po koncesionarima)
  Future<double> izracunajUkupnuCestarinu({
    required String polaziste,
    required String odrediste,
    String? medustajaliste,
    required String kategorijaVozila,
    Map<String, bool>? statusiAutoputeva,
  }) async {
    final postajaPolaziste = await dohvatiPostajuZaGrad(polaziste);
    final postajaOdrediste = await dohvatiPostajuZaGrad(odrediste);

    if (postajaPolaziste == null || postajaOdrediste == null) return 0.0;

    final String ulaznaPostaja = postajaPolaziste['postaja'] ?? '';
    final String izlaznaPostaja = postajaOdrediste['postaja'] ?? '';

    // Pomoćna funkcija za provjeru je li koncesionar uključen putem prekidača
    bool provjeriKoncesionara(String? koncesionarNaziv) {
      if (statusiAutoputeva == null || koncesionarNaziv == null) return true;
      String k = koncesionarNaziv.toLowerCase();
      for (var entry in statusiAutoputeva.entries) {
        if (k.contains(entry.key.toLowerCase())) {
          return entry.value; // vraća true ako je uključen, false ako je isključen
        }
      }
      return true; // Zadano uključeno ako nema unosa
    }

    // Ako postoji međustaustajalište (dva segmenta)
    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedu = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedu?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        double ukupnoMedu = 0.0;

        // Prvi segment
        var doc1 = await dohvatiDokumentDionice(ulaz: ulaznaPostaja, izlaz: meduPostaja);
        if (doc1 != null) {
          String koncesionar1 = doc1['koncesionar'] ?? 'HAC';
          if (provjeriKoncesionara(koncesionar1)) {
            double? c1 = _izvuciCijenuIzDokumenta(doc1, kategorijaVozila);
            if (c1 != null) ukupnoMedu += c1;
          }
        }

        // Drugi segment
        var doc2 = await dohvatiDokumentDionice(ulaz: meduPostaja, izlaz: izlaznaPostaja);
        if (doc2 != null) {
          String koncesionar2 = doc2['koncesionar'] ?? 'HAC';
          if (provjeriKoncesionara(koncesionar2)) {
            double? c2 = _izvuciCijenuIzDokumenta(doc2, kategorijaVozila);
            if (c2 != null) ukupnoMedu += c2;
          }
        }

        return ukupnoMedu;
      }
    }

    // Direktna relacija
    var direktniDoc = await dohvatiDokumentDionice(ulaz: ulaznaPostaja, izlaz: izlaznaPostaja);
    if (direktniDoc != null) {
      String koncesionar = direktniDoc['koncesionar'] ?? 'HAC';
      if (!provjeriKoncesionara(koncesionar)) {
        return 0.0; // Ako je koncesionar isključen prekidačem
      }
      double? cijena = _izvuciCijenuIzDokumenta(direktniDoc, kategorijaVozila);
      if (cijena != null && cijena > 0) return cijena;
    }

    // Fallback preko Lučkog / Bosiljeva
    if (ulaznaPostaja == 'lucko' || izlaznaPostaja == 'lucko') {
      String udaljena = (ulaznaPostaja == 'lucko') ? izlaznaPostaja : ulaznaPostaja;
      
      var doc1 = await dohvatiDokumentDionice(ulaz: 'lucko', izlaz: 'bosiljevo');
      var doc2 = await dohvatiDokumentDionice(ulaz: 'bosiljevo', izlaz: udaljena);
      
      double subTotal = 0.0;
      if (doc1 != null && provjeriKoncesionara(doc1['koncesionar'] ?? 'HAC')) {
        double? c1 = _izvuciCijenuIzDokumenta(doc1, kategorijaVozila);
        if (c1 != null) subTotal += c1;
      }
      if (doc2 != null && provjeriKoncesionara(doc2['koncesionar'] ?? 'HAC')) {
        double? c2 = _izvuciCijenuIzDokumenta(doc2, kategorijaVozila);
        if (c2 != null) subTotal += c2;
      }
      if (subTotal > 0) return subTotal;
    }

    return 0.0;
  }
}
