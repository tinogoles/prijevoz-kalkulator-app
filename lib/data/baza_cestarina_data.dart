// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 0. GPS KOORDINATE GLAVNIH ČVOROVA (Koristi se za dinamički GPS fallback)
  // =========================================================================
  static final Map<String, Map<String, double>> cvoroviKoordinate = {
    'lucko': {'lat': 45.7481, 'lon': 15.8903},
    'zagreb_istok': {'lat': 45.8150, 'lon': 16.1500},
    'zapresic': {'lat': 45.8575, 'lon': 15.8086},
    'krapina': {'lat': 46.1625, 'lon': 15.8783},
    'macelj': {'lat': 46.2514, 'lon': 15.8450},
    'josipdol': {'lat': 45.2342, 'lon': 15.2356},
    'zuta_lokva': {'lat': 44.9850, 'lon': 15.0817},
    'grobnik': {'lat': 45.3683, 'lon': 14.5167},
    'bosiljevo': {'lat': 45.4122, 'lon': 15.2858},
    'pazin': {'lat': 45.2392, 'lon': 13.9358},
    'pula': {'lat': 44.8783, 'lon': 13.8514},
    'dugopolje': {'lat': 43.5683, 'lon': 16.5708},
    'zagvozd': {'lat': 43.4333, 'lon': 16.9667},
    'blato_na_cetini': {'lat': 43.4475, 'lon': 16.7911},
    'sestanovac': {'lat': 43.4500, 'lon': 16.8833},
    'sibenik': {'lat': 43.7250, 'lon': 15.9167},
    'zadar_istok': {'lat': 44.1197, 'lon': 15.3900},
    'posedarje': {'lat': 44.2250, 'lon': 15.4833},
    'gospic': {'lat': 44.5461, 'lon': 15.3778},
    'ploce': {'lat': 43.0550, 'lon': 17.4350},
    'slavonski_brod_zapad': {'lat': 45.1639, 'lon': 18.0147},
    'osijek': {'lat': 45.5511, 'lon': 18.6939},
    'karlovac': {'lat': 45.4929, 'lon': 15.5553},
    'ljubljana_jug': {'lat': 46.0350, 'lon': 14.5100},
    'maribor_jug': {'lat': 46.5167, 'lon': 15.6500},
    'obrezje': {'lat': 45.8817, 'lon': 15.6933},
    'sarajevo_sjever': {'lat': 43.9167, 'lon': 18.2333},
    'zenica_jug': {'lat': 44.1833, 'lon': 17.9000},
    'bijaca': {'lat': 43.1500, 'lon': 17.5833},
    'mahovljani': {'lat': 44.9000, 'lon': 17.3167},
    'smokovac': {'lat': 42.4750, 'lon': 19.3000},
    'matesevo': {'lat': 42.8000, 'lon': 19.5333},
    'sozina': {'lat': 42.2333, 'lon': 19.0833},
  };

  // =========================================================================
  // 1. MATRICA ČVORIŠTA I CIJENA ZA SVE AUTOPUTOVE U REGIJI (HR, SI, BIH, CG)
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveDionice() {
    final Map<String, Map<String, dynamic>> dionice = {};

    void dodaj(String c1, String c2, String koncesionar, String naziv, double p1, double p2, double p3, double p4) {
      final data = {
        'koncesionar': koncesionar,
        'naziv': naziv,
        'I. Skupina (Osobna vozila / motocikli)': p1,
        'II. Skupina (Vozila do 3.5t / kombi)': p2,
        'III. Skupina (Vozila preko 3.5t / midi bus)': p3,
        'IV. Skupina (Vozila preko 3.5t / veliki autobus)': p4,
      };
      dionice['${c1}_$c2'] = data;
      dionice['${c2}_$c1'] = data;
    }

    // --- HRVATSKA - HAC & AZM ---
    dodaj('zapresic', 'krapina', 'AZM (A2)', 'A2: Zaprešić - Krapina', 2.50, 4.00, 10.00, 15.40);
    dodaj('zapresic', 'macelj', 'AZM (A2)', 'A2: Zaprešić - Macelj', 6.40, 10.20, 16.80, 28.50);
    dodaj('krapina', 'macelj', 'AZM (A2)', 'A2: Krapina - Macelj', 3.90, 6.20, 6.80, 13.10);
    dodaj('lucko', 'zapresic', 'AZM (A2)', 'A2: Zagreb - Zaprešić', 1.50, 2.50, 5.00, 8.00);
    dodaj('lucko', 'krapina', 'AZM (A2)', 'A2: Zagreb - Krapina', 2.50, 4.00, 10.00, 15.40);

    dodaj('lucko', 'karlovac', 'HAC', 'A1: Lučko - Karlovac', 2.50, 4.30, 6.50, 10.80);
    dodaj('lucko', 'bosiljevo', 'HAC', 'A1: Lučko - Bosiljevo', 4.40, 7.30, 11.20, 18.50);
    dodaj('lucko', 'josipdol', 'HAC', 'A1: Lučko - Josipdol', 6.50, 10.50, 15.50, 26.00);
    dodaj('lucko', 'zuta_lokva', 'HAC', 'A1: Lučko - Žuta Lokva', 9.50, 15.00, 22.50, 37.50);
    dodaj('lucko', 'gospic', 'HAC', 'A1: Lučko - Gospić', 14.00, 22.00, 33.00, 55.00);
    dodaj('lucko', 'posedarje', 'HAC', 'A1: Lučko - Posedarje', 17.50, 28.00, 42.00, 70.00);
    dodaj('lucko', 'zadar_istok', 'HAC', 'A1: Lučko - Zadar Istok', 18.50, 29.50, 44.50, 74.00);
    dodaj('lucko', 'sibenik', 'HAC', 'A1: Lučko - Šibenik', 21.00, 33.50, 50.50, 84.00);
    dodaj('lucko', 'dugopolje', 'HAC', 'A1: Lučko - Dugopolje', 24.00, 38.50, 57.50, 96.00);
    dodaj('lucko', 'blato_na_cetini', 'HAC', 'A1: Lučko - Blato na Cetini', 25.00, 40.00, 60.00, 100.00);
    dodaj('lucko', 'sestanovac', 'HAC', 'A1: Lučko - Šestanovac', 26.00, 41.50, 62.00, 103.00);
    dodaj('lucko', 'zagvozd', 'HAC', 'A1: Lučko - Zagvozd', 27.00, 43.00, 64.50, 107.50);
    dodaj('lucko', 'ploce', 'HAC', 'A1: Lučko - Ploče', 30.10, 47.50, 71.00, 118.00);
    dodaj('lucko', 'grobnik', 'HAC / ARZ', 'A1/A6: Lučko - Rijeka (Grobnik)', 9.90, 15.90, 23.50, 39.50);

    dodaj('lucko', 'slavonski_brod_zapad', 'HAC', 'A3: Zagreb - Slavonski Brod', 12.00, 19.50, 29.00, 48.00);
    dodaj('lucko', 'osijek', 'HAC', 'A3/A5: Zagreb - Osijek', 17.50, 28.00, 42.00, 70.00);

    dodaj('dugopolje', 'josipdol', 'HAC', 'A1: Dugopolje - Josipdol', 17.50, 28.00, 42.00, 70.00);
    dodaj('dugopolje', 'zuta_lokva', 'HAC', 'A1: Dugopolje - Žuta Lokva', 14.50, 23.00, 34.50, 58.00);
    dodaj('dugopolje', 'grobnik', 'HAC', 'A1: Dugopolje - Grobnik', 30.00, 48.00, 72.00, 120.00);
    dodaj('dugopolje', 'osijek', 'HAC', 'A1/A3/A5: Dugopolje - Osijek', 41.50, 66.50, 99.50, 166.00);
    dodaj('dugopolje', 'zapresic', 'A1/A2', 'Split - Zaprešić', 25.50, 41.00, 62.50, 104.00);
    dodaj('dugopolje', 'krapina', 'A1/A2', 'Split - Krapina', 26.50, 42.50, 67.50, 111.40);
    dodaj('zadar_istok', 'krapina', 'A1/A2', 'Zadar - Krapina', 21.00, 33.50, 54.50, 89.40);

    // --- BINA-ISTRA ---
    dodaj('pazin', 'pula', 'Bina-Istra', 'A8/A9: Pazin - Pula', 3.40, 5.50, 8.50, 14.00);
    dodaj('pazin', 'grobnik', 'Bina-Istra', 'A8: Pazin - Tunel Učka/Rijeka', 4.50, 7.20, 11.50, 19.00);
    dodaj('dugopolje', 'pazin', 'A1/A8', 'Split - Pazin', 33.00, 53.00, 80.00, 132.00);

    // --- SLOVENIJA (DARS) ---
    dodaj('obrezje', 'ljubljana_jug', 'DARS', 'A2 (SI): Obrežje - Ljubljana', 16.00, 16.00, 14.50, 24.00);
    dodaj('maribor_jug', 'ljubljana_jug', 'DARS', 'A1 (SI): Maribor - Ljubljana', 16.00, 16.00, 18.00, 31.00);
    dodaj('obrezje', 'maribor_jug', 'DARS', 'A2/A1 (SI): Obrežje - Maribor', 16.00, 16.00, 25.00, 42.00);

    // --- BOSNA I HERCEGOVINA ---
    dodaj('bijaca', 'sarajevo_sjever', 'Autoceste FBiH', 'A1 (BiH): Bijača - Sarajevo', 6.00, 10.00, 18.00, 30.00);
    dodaj('sarajevo_sjever', 'zenica_jug', 'Autoceste FBiH', 'A1 (BiH): Sarajevo - Zenica', 3.50, 6.00, 11.00, 18.00);
    dodaj('bijaca', 'zenica_jug', 'Autoceste FBiH', 'A1 (BiH): Bijača - Zenica', 9.50, 16.00, 29.00, 48.00);
    dodaj('mahovljani', 'zenica_jug', 'Autoputevi RS / FBiH', 'Banja Luka - Zenica', 5.00, 9.00, 15.00, 25.00);

    // --- CRNA GORA ---
    dodaj('smokovac', 'matesevo', 'Monteput', 'Autoput Bar-Boljare: Smokovac - Mateševo', 3.50, 6.00, 10.50, 17.00);
    dodaj('sozina', 'smokovac', 'Monteput', 'Tunel Sozina: Sutomore - Podgorica', 2.50, 5.00, 7.50, 12.00);
    dodaj('sozina', 'matesevo', 'Monteput', 'Sozina + Autoput Smokovac-Mateševo', 6.00, 11.00, 18.00, 29.00);

    return dionice;
  }

  // =========================================================================
  // 2. CLOUD SYNC (Samo za dionice cestarina u Firestore)
  // =========================================================================
  static Future<void> osvjeziBazuNaCloudu() async {
    final sveDionice = generirajSveDionice();

    WriteBatch batchDionice = _db.batch();
    int brojacDionica = 0;

    for (var entry in sveDionice.entries) {
      DocumentReference ref = _db.collection('cestarine_dionice').doc(entry.key);
      batchDionice.set(ref, entry.value);
      brojacDionica++;
      if (brojacDionica % 400 == 0) {
        await batchDionice.commit();
        batchDionice = _db.batch();
      }
    }
    await batchDionice.commit();
  }
}
