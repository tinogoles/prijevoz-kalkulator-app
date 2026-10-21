// lib/services/cestarine_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../data/baza_cestarina_data.dart';

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

  // -------------------------------------------------------------------------
  // 1. HAVERSINE FORMULA (Zračna udaljenost)
  // -------------------------------------------------------------------------
  double _izracunajHaversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    double dLat = (lat2 - lat1) * pi / 180.0;
    double dLon = (lon2 - lon1) * pi / 180.0;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  // -------------------------------------------------------------------------
  // 2. HIBRIDNI ODABIR ČVORA (Haversine Top 3 + OSRM Cestovna potvrda)
  // -------------------------------------------------------------------------
  Future<String> pronadjiNajbliziCvorHibridno(double gradLat, double gradLon) async {
    final cvoroviMap = BazaCestarinaData.cvoroviKoordinate;

    List<Map<String, dynamic>> kandidati = [];
    cvoroviMap.forEach((cvorId, coords) {
      double zracnaKm = _izracunajHaversineKm(
        gradLat, gradLon, 
        coords['lat']!, coords['lon']!
      );
      kandidati.add({'cvorId': cvorId, 'zracnaKm': zracnaKm, 'coords': coords});
    });

    // Sortiraj i uzmi Top 3 najbliža po zračnoj liniji
    kandidati.sort((a, b) => (a['zracnaKm'] as double).compareTo(b['zracnaKm'] as double));
    var topKandidati = kandidati.take(3).toList();

    if (topKandidati.first['zracnaKm'] < 3.0) {
      return topKandidati.first['cvorId'];
    }

    String najbliziCvorId = topKandidati.first['cvorId'];
    double minCestovnaMetara = double.infinity;

    for (var k in topKandidati) {
      double cvorLat = k['coords']['lat'];
      double cvorLon = k['coords']['lon'];

      try {
        final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$gradLon,$gradLat;$cvorLon,$cvorLat?overview=false'
        );
        final response = await http.get(url, headers: {'User-Agent': 'PrijevozKalkulatorApp'});

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
            double distMetara = (data['routes'][0]['distance'] as num).toDouble();
            if (distMetara < minCestovnaMetara) {
              minCestovnaMetara = distMetara;
              najbliziCvorId = k['cvorId'];
            }
          }
        }
      } catch (e) {
        // Fallback na zračnu udaljenost ako mreža zakaže
      }
    }

    return najbliziCvorId;
  }

  // -------------------------------------------------------------------------
  // 3. DOHVAT POSTAJE ZA GRAD (Dinamički GPS Fallback)
  // -------------------------------------------------------------------------
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    try {
      // Dinamički poziv Nominatim API-ja za bilo koje uneseno mjesto
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(gradNaziv)}&format=json&limit=1'),
        headers: {'User-Agent': 'PrijevozKalkulatorApp'},
      );

      if (res.statusCode == 200) {
        List data = json.decode(res.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(data[0]['lon']);

          // Pozivamo naš hibridni izračun najbližeg čvora
          String izracunatiCvor = await pronadjiNajbliziCvorHibridno(lat, lon);

          return {
            'postaja': izracunatiCvor,
            'koncesionar': 'HAC',
          };
        }
      }
    } catch (e) {
      print('Greška pri dohvaćanju grada preko API-ja: $e');
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
        if (kljuc.contains('iv.') || katLower.contains('autobus') || katLower.contains('skupina4')) return val.toDouble();
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

  // Glavna metoda obogaćena provjerom prekidača i rezervnim fallback mehanizmom
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

    bool provjeriKoncesionara(String? koncesionarNaziv) {
      if (statusiAutoputeva == null || koncesionarNaziv == null) return true;
      String k = koncesionarNaziv.toLowerCase();
      for (var entry in statusiAutoputeva.entries) {
        if (k.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
      return true;
    }

    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedu = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedu?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        double ukupnoMedu = 0.0;

        var doc1 = await dohvatiDokumentDionice(ulaz: ulaznaPostaja, izlaz: meduPostaja);
        if (doc1 != null) {
          String koncesionar1 = doc1['koncesionar'] ?? 'HAC';
          if (provjeriKoncesionara(koncesionar1)) {
            double? c1 = _izvuciCijenuIzDokumenta(doc1, kategorijaVozila);
            if (c1 != null) ukupnoMedu += c1;
          }
        }

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

    // 1. KORAK: DIREKTNI UPIT (Primarni mehanizam)
    var direktniDoc = await dohvatiDokumentDionice(ulaz: ulaznaPostaja, izlaz: izlaznaPostaja);
    if (direktniDoc != null) {
      String koncesionar = direktniDoc['koncesionar'] ?? 'HAC';
      if (!provjeriKoncesionara(koncesionar)) {
        return 0.0;
      }
      double? cijena = _izvuciCijenuIzDokumenta(direktniDoc, kategorijaVozila);
      if (cijena != null && cijena > 0) return cijena;
    }

    // 2. KORAK: REZERVNI FALLBACK MEHANIZAM (Preko glavnog čvora Lučko ako direktna dionica nedostaje)
    if (ulaznaPostaja != 'lucko' && izlaznaPostaja != 'lucko') {
      var doc1 = await dohvatiDokumentDionice(ulaz: ulaznaPostaja, izlaz: 'lucko');
      var doc2 = await dohvatiDokumentDionice(ulaz: 'lucko', izlaz: izlaznaPostaja);

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

    // 3. KORAK: Fallback za Lučko
    if (ulaznaPostaja == 'lucko' || izlaznaPostaja == 'lucko') {
      String udaljena = (ulaznaPostaja == 'lucko') ? izlaznaPostaja : ulaznaPostaja;
      
      var doc1 = await dohvatiDokumentDionice(ulaz: 'lucko', izlaz: 'bosiljevo');
      var doc3 = await dohvatiDokumentDionice(ulaz: 'bosiljevo', izlaz: udaljena);
      
      double subTotal = 0.0;
      if (doc1 != null && provjeriKoncesionara(doc1['koncesionar'] ?? 'HAC')) {
        double? c1 = _izvuciCijenuIzDokumenta(doc1, kategorijaVozila);
        if (c1 != null) subTotal += c1;
      }
      if (doc3 != null && provjeriKoncesionara(doc3['koncesionar'] ?? 'HAC')) {
        double? c2 = _izvuciCijenuIzDokumenta(doc3, kategorijaVozila);
        if (c2 != null) subTotal += c2;
      }
      if (subTotal > 0) return subTotal;
    }

    return 0.0;
  }
}
