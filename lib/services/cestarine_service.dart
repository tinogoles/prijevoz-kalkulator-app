// lib/services/cestarine_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/baza_cestarina_data.dart';

class CestarineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Pomoćna funkcija za normalizaciju naziva gradova (uklanjanje kvačica i razmaka)
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

  /// 1. Funkcija za inicijalno punjenje/osvježavanje Firebase baze
  Future<void> inicijalizirajBazuUFirebaseu() async {
    for (var entry in BazaCestarinaData.gradoviMapiranje.entries) {
      await _db
          .collection('gradovi_mapiranje')
          .doc(entry.key)
          .set(entry.value, SetOptions(merge: true));
    }

    for (var dionica in BazaCestarinaData.dioniceCestarina) {
      await _db
          .collection('cestarine_dionice')
          .doc(dionica['id'])
          .set(dionica, SetOptions(merge: true));
    }
  }

  /// 2. Pomoćna funkcija za dohvat naplatne postaje za zadani grad (s hibridnim Firestore + lokalnim fallbackom)
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = _normalizirajKljuc(gradNaziv);

    // 1. Probaj iz Firestorea
    try {
      final docSnapshot =
          await _db.collection('gradovi_mapiranje').doc(gradKey).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return {
          'postaja': data['postaja'] ?? '',
          'koncesionar': data['koncesionar'] ?? '',
        };
      }
    } catch (_) {}

    // 2. Rezervni (offline/brzi) dohvat iz BazaCestarinaData
    if (BazaCestarinaData.gradoviMapiranje.containsKey(gradKey)) {
      final data = BazaCestarinaData.gradoviMapiranje[gradKey]!;
      return {
        'postaja': data['postaja'] ?? '',
        'koncesionar': data['koncesionar'] ?? '',
      };
    }

    // Prettraga po dijelu naziva u lokalnoj mapi
    for (var entry in BazaCestarinaData.gradoviMapiranje.entries) {
      if (entry.value['grad']!.toLowerCase().contains(gradNaziv.trim().toLowerCase())) {
        return {
          'postaja': entry.value['postaja'] ?? '',
          'koncesionar': entry.value['koncesionar'] ?? '',
        };
      }
    }

    return null;
  }

  /// 3. Izračun cestarine za dionicu između dvije naplatne postaje
  Future<double> dohvatiCijenuDionice({
    required String ulaz,
    required String izlaz,
    required String kategorijaVozila,
  }) async {
    if (ulaz.isEmpty || izlaz.isEmpty) return 0.0;

    // Normalizacija kategorije u ključ baze ('Veliki autobus 50', 'Midi bus 35', 'Mini bus <20', 'Kombi 8+1')
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

    // 1. Pretraga kroz Firestore
    try {
      final query1 = await _db
          .collection('cestarine_dionice')
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

      final query2 = await _db
          .collection('cestarine_dionice')
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
    } catch (_) {}

    // 2. Rezervna lokalna pretraga u BazaCestarinaData
    for (var dionica in BazaCestarinaData.dioniceCestarina) {
      String u = dionica['ulaz'].toString().toLowerCase();
      String i = dionica['izlaz'].toString().toLowerCase();
      String ulazLower = ulaz.toLowerCase();
      String izlazLower = izlaz.toLowerCase();

      if ((u == ulazLower && i == izlazLower) || (u == izlazLower && i == ulazLower)) {
        Map<String, dynamic> cijene = dionica['cijene'];
        if (cijene.containsKey(katKljuc)) {
          return (cijene[katKljuc] as num).toDouble();
        }
      }
    }

    return 0.0;
  }

  /// 4. Glavna funkcija: Pametni izračun za cijelu rutu (podržava i međustajališta)
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

    // Ako imamo međustajalište
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

    // Izravna dionica
    ukupno = await dohvatiCijenuDionice(
      ulaz: ulaznaPostaja,
      izlaz: izlaznaPostaja,
      kategorijaVozila: kategorijaVozila,
    );

    return ukupno;
  }
}
