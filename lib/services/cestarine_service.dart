import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/baza_cestarina_data.dart';

class CestarineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1. Funkcija za inicijalno punjenje/osvježavanje Firebase baze
  Future<void> inicijalizirajBazuUFirebaseu() async {
    // Punjenje kolekcije 'gradovi_mapiranje'
    for (var entry in BazaCestarinaData.gradoviMapiranje.entries) {
      await _db
          .collection('gradovi_mapiranje')
          .doc(entry.key)
          .set(entry.value, SetOptions(merge: true));
    }

    // Punjenje kolekcije 'cestarine_dionice'
    for (var dionica in BazaCestarinaData.dioniceCestarina) {
      await _db
          .collection('cestarine_dionice')
          .doc(dionica['id'])
          .set(dionica, SetOptions(merge: true));
    }
  }

  /// 2. Pomoćna funkcija za dohvat naplatne postaje za zadani grad
  Future<Map<String, String>?> dohvatiPostajuZaGrad(String gradNaziv) async {
    if (gradNaziv.trim().isEmpty) return null;

    final gradKey = gradNaziv.trim().toLowerCase().replaceAll(' ', '_');

    // Prvo tražimo po točnom ključu (id-u dokumenta)
    final docSnapshot =
        await _db.collection('gradovi_mapiranje').doc(gradKey).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return {
          'postaja': data['postaja'] ?? '',
          'koncesionar': data['koncesionar'] ?? '',
        };
      }
    }

    // Pomoćna prettraga ako unos nije točan ključ
    final query = await _db
        .collection('gradovi_mapiranje')
        .where('grad', isEqualTo: gradNaziv.trim())
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      return {
        'postaja': data['postaja'] ?? '',
        'koncesionar': data['koncesionar'] ?? '',
      };
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

    // Tražimo dionicu neovisno o smjeru (ulaz-izlaz ili izlaz-ulaz)
    final query1 = await _db
        .collection('cestarine_dionice')
        .where('ulaz', isEqualTo: ulaz)
        .where('izlaz', isEqualTo: izlaz)
        .limit(1)
        .get();

    if (query1.docs.isNotEmpty) {
      final cijene = query1.docs.first.data()['cijene'] as Map<String, dynamic>?;
      return (cijene?[kategorijaVozila] as num?)?.toDouble() ?? 0.0;
    }

    // Obrnuti smjer
    final query2 = await _db
        .collection('cestarine_dionice')
        .where('ulaz', isEqualTo: izlaz)
        .where('izlaz', isEqualTo: ulaz)
        .limit(1)
        .get();

    if (query2.docs.isNotEmpty) {
      final cijene = query2.docs.first.data()['cijene'] as Map<String, dynamic>?;
      return (cijene?[kategorijaVozila] as num?)?.toDouble() ?? 0.0;
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

    // Dohvati postaje za polazište i odredište
    final postajaPolaziste = await dohvatiPostajuZaGrad(polaziste);
    final postajaOdrediste = await dohvatiPostajuZaGrad(odrediste);

    if (postajaPolaziste == null || postajaOdrediste == null) {
      return 0.0;
    }

    final String ulaznaPostaja = postajaPolaziste['postaja'] ?? '';
    final String izlaznaPostaja = postajaOdrediste['postaja'] ?? '';

    // Ako imamo međustajalište (npr. Split -> Lučko/Zagreb -> Krapina)
    if (medustajaliste != null && medustajaliste.trim().isNotEmpty) {
      final postajaMedustajaliste = await dohvatiPostajuZaGrad(medustajaliste);
      final String meduPostaja = postajaMedustajaliste?['postaja'] ?? '';

      if (meduPostaja.isNotEmpty) {
        // Zbroji Dionica 1 (Polazište -> Međustajalište)
        ukupno += await dohvatiCijenuDionice(
          ulaz: ulaznaPostaja,
          izlaz: meduPostaja,
          kategorijaVozila: kategorijaVozila,
        );

        // Zbroji Dionica 2 (Međustajalište -> Odredište)
        ukupno += await dohvatiCijenuDionice(
          ulaz: meduPostaja,
          izlaz: izlaznaPostaja,
          kategorijaVozila: kategorijaVozila,
        );

        return ukupno;
      }
    }

    // Izračun za izravnu dionicu bez međustajališta
    ukupno = await dohvatiCijenuDionice(
      ulaz: ulaznaPostaja,
      izlaz: izlaznaPostaja,
      kategorijaVozila: kategorijaVozila,
    );

    return ukupno;
  }
}
