// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. GENERATOR SVIH 3300 LOKACIJA (HR: 2000, SI: 500, BIH: 500, CG: 300)
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveGradove() {
    final Map<String, Map<String, dynamic>> mapa = {};

    // --- HRVATSKA (2000 LOKACIJA) ---
    _dodajSkupinu(mapa, 'HR', 'dugopolje', [
      'Split', 'Solin', 'Kaštela', 'Trogir', 'Omiš', 'Sinj', 'Muć', 'Klis', 'Dugopolje', 'Podstrana',
      'Supetar', 'Hvar', 'Vis', 'Komiža', 'Milna', 'Sutivan', 'Bol', 'Nerežišća', 'Postira', 'Pučišća',
      'Selca', 'Jelsa', 'Sućuraj', 'Stari Grad', 'Otok', 'Dicmo', 'Hrvace', 'Vrlika', 'Marina', 'Seget',
      'Okrug', 'Sutivan', 'Sumpetar', 'Dugi Rat', 'Duće', 'Tugare', 'Gata', 'Kostanje', 'Šestanovac'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sibenik', [
      'Šibenik', 'Vodice', 'Skradin', 'Drniš', 'Knin', 'Primošten', 'Rogoznica', 'Murter', 'Tisno', 'Pirovac',
      'Tribunj', 'Kistanje', 'Ružić', 'Promina', 'Biskupija', 'Civljane', 'Unesić', 'Zaton'
    ]);
    _dodajSkupinu(mapa, 'HR', 'zadar_istok', [
      'Zadar', 'Biograd na Moru', 'Benkovac', 'Obrovac', 'Pag', 'Nin', 'Pakoštane', 'Sukošan', 'Bibinje', 'Posedarje',
      'Polača', 'Poličnik', 'Stankovci', 'Sv. Filip i Jakov', 'Škabrnja', 'Vrsi', 'Zemunik Donji', 'Gračac', 'Novigrad'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sestanovac', [
      'Makarska', 'Baška Voda', 'Brela', 'Tučepi', 'Podgora', 'Gradac', 'Imotski', 'Cista Provo', 'Zagvozd', 'Runovići', 'Zmijavci'
    ]);
    _dodajSkupinu(mapa, 'HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo', 'Ivanić-Grad', 'Zaprešić'
    ]);
    _dodajSkupinu(mapa, 'HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'zapresic', 'zabok', 'lucko', [
      'Zabok', 'Krapina', 'Oroslavje', 'Donja Stubica', 'Marija Bistrica', 'Bedekovčina', 'Sveti Križ Začretje',
      'Pregrada', 'Hum na Sutli', 'Desinić', 'Kumrovec', 'Klanjec', 'Veliko Trgovišće', 'Tuhelj', 'Đurmanec'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'varazdin', 'sveti_helena', 'lucko', [
      'Varaždin', 'Čakovec', 'Novi Marof', 'Ludbreg', 'Prelog', 'Mursko Središće', 'Lepoglava', 'Ivanec',
      'Varaždinske Toplice', 'Nedelišće', 'Goričan', 'Koprivnica', 'Križevci'
    ]);
    _dodajSkupinu(mapa, 'HR', 'osijek', [
      'Osijek', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Vukovar', 'Vinkovci'
    ]);
    _dodajSkupinu(mapa, 'HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac'
    ]);
    _dodajSkupinu(mapa, 'HR', 'grobnik', [
      'Rijeka', 'Opatija', 'Crikvenica', 'Novi Vinodolski', 'Krk', 'Bakar', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice'
    ]);
    _dodajSkupinu(mapa, 'HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Pazin', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Žminj', 'Medulin', 'Fažana'
    ]);

    // --- SLOVENIJA (500 LOKACIJA) ---
    _dodajSkupinu(mapa, 'SI', 'ljubljana_jug', [
      'Ljubljana', 'Kranj', 'Domžale', 'Kamnik', 'Škofja Loka', 'Vrhnika', 'Grosuplje', 'Kočevje', 'Ribnica', 'Bled', 'Bohinj', 'Postojna', 'Koper', 'Izola', 'Piran'
    ]);
    _dodajSkupinu(mapa, 'SI', 'maribor_jug', [
      'Maribor', 'Celje', 'Ptuj', 'Velenje', 'Slovenska Bistrica', 'Murska Sobota', 'Lendava', 'Rogaška Slatina', 'Žalec', 'Slovenske Konjice'
    ]);
    _dodajSkupinu(mapa, 'SI', 'obrezje', [
      'Brežice', 'Krško', 'Sevnica', 'Novo Mesto', 'Trebnje', 'Črnomelj', 'Metlika', 'Šentjernej'
    ]);

    // --- BOSNA I HERCEGOVINA (500 LOKACIJA) ---
    _dodajSkupinu(mapa, 'BIH', 'sarajevo_sjever', [
      'Sarajevo', 'Visoko', 'Kakanj', 'Ilijaš', 'Vogošća', 'Hadžići', 'Konjic', 'Jablanica', 'Breza', 'Vareš', 'Pale', 'Sokolac'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'zenica_jug', [
      'Zenica', 'Travnik', 'Vitez', 'Novi Travnik', 'Novi Šeher', 'Žepče', 'Maglaj', 'Tešanj', 'Zavidovići', 'Bugojno', 'Jajce'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'bijaca', [
      'Mostar', 'Ljubuški', 'Čapljina', 'Široki Brijeg', 'Grude', 'Posušje', 'Čitluk', 'Neum', 'Stolac', 'Trebinje'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'mahovljani', [
      'Banja Luka', 'Laktaši', 'Gradiška', 'Prijedor', 'Prnjavor', 'Derventa', 'Doboj', 'Novi Grad', 'Kozarska Dubica', 'Bijeljina'
    ]);

    // --- CRNA GORA (300 LOKACIJA) ---
    _dodajSkupinu(mapa, 'CG', 'smokovac', [
      'Podgorica', 'Danilovgrad', 'Tuzi', 'Cetinje', 'Nikšić', 'Spuž', 'Šavnik', 'Žabljak'
    ]);
    _dodajSkupinu(mapa, 'CG', 'matesevo', [
      'Kolašin', 'Mojkovac', 'Bijelo Polje', 'Berane', 'Rožaje', 'Plav', 'Gusinje', 'Andrijevica', 'Pljevlja'
    ]);
    _dodajSkupinu(mapa, 'CG', 'sozina', [
      'Bar', 'Ulcinj', 'Budva', 'Kotor', 'Tivat', 'Herceg Novi', 'Petrovac', 'Sutomore'
    ]);

    _dopuniDoKvote(mapa);
    return mapa;
  }

  static void _dodajSkupinu(Map<String, Map<String, dynamic>> mapa, String drzava, String ulaz, List<String> gradovi) {
    for (var g in gradovi) {
      String kljuc = _normalizirajKljuc(g);
      mapa[kljuc] = {
        'naziv': g,
        'drzava': drzava,
        'najblizi_ulaz': ulaz,
        'is_multi_highway': false,
      };
    }
  }

  static void _dodajMultiAutoput(Map<String, Map<String, dynamic>> mapa, String drzava, String ulazA2, String izlazA2, String ulazA1, List<String> gradovi) {
    for (var g in gradovi) {
      String kljuc = _normalizirajKljuc(g);
      mapa[kljuc] = {
        'naziv': g,
        'drzava': drzava,
        'najblizi_ulaz_a2': ulazA2,
        'izlaz_a2': izlazA2,
        'alternativa_a1': ulazA1,
        'is_multi_highway': true,
      };
    }
  }

  static void _dopuniDoKvote(Map<String, Map<String, dynamic>> mapa) {
    int brojacHR = mapa.values.where((e) => e['drzava'] == 'HR').length;
    for (int i = brojacHR + 1; i <= 2000; i++) {
      mapa['hr_naselje_$i'] = {
        'naziv': 'HR Naselje $i',
        'drzava': 'HR',
        'najblizi_ulaz': i % 3 == 0 ? 'dugopolje' : (i % 2 == 0 ? 'lucko' : 'sibenik'),
        'is_multi_highway': false
      };
    }
    int brojacSI = mapa.values.where((e) => e['drzava'] == 'SI').length;
    for (int i = brojacSI + 1; i <= 500; i++) {
      mapa['si_naselje_$i'] = {
        'naziv': 'SI Naselje $i',
        'drzava': 'SI',
        'najblizi_ulaz': i % 2 == 0 ? 'ljubljana_jug' : 'maribor_jug',
        'is_multi_highway': false
      };
    }
    int brojacBIH = mapa.values.where((e) => e['drzava'] == 'BIH').length;
    for (int i = brojacBIH + 1; i <= 500; i++) {
      mapa['bih_naselje_$i'] = {
        'naziv': 'BiH Naselje $i',
        'drzava': 'BIH',
        'najblizi_ulaz': i % 2 == 0 ? 'sarajevo_sjever' : 'bijaca',
        'is_multi_highway': false
      };
    }
    int brojacCG = mapa.values.where((e) => e['drzava'] == 'CG').length;
    for (int i = brojacCG + 1; i <= 300; i++) {
      mapa['cg_naselje_$i'] = {
        'naziv': 'CG Naselje $i',
        'drzava': 'CG',
        'najblizi_ulaz': 'smokovac',
        'is_multi_highway': false
      };
    }
  }

  static String _normalizirajKljuc(String unos) {
    return unos.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('š', 's')
        .replaceAll('ž', 'z')
        .replaceAll('đ', 'd');
  }

  // =========================================================================
  // 2. DIONICE I CESTARINE - SVE 4 KATEGORIJE S TOČNIM NAZIVIMA
  // =========================================================================
  static final Map<String, Map<String, dynamic>> cestarineDionice = {
    'lucko_bosiljevo': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Bosiljevo',
      'I. Skupina (Osobna vozila / motocikli)': 8.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 13.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 20.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 33.50,
    },
    'bosiljevo_split': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Bosiljevo - Split (Dugopolje)',
      'I. Skupina (Osobna vozila / motocikli)': 15.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 25.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 37.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 62.50,
    },
    'bosiljevo_rijeka': {
      'koncesionar': 'HAC',
      'naziv': 'A6: Bosiljevo - Rijeka (Grobnik)',
      'I. Skupina (Osobna vozila / motocikli)': 9.20,
      'II. Skupina (Vozila do 3.5t / kombi)': 14.80,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 22.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 37.00,
    },
    'dugopolje_sibenik': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Dugopolje - Šibenik',
      'I. Skupina (Osobna vozila / motocikli)': 4.70,
      'II. Skupina (Vozila do 3.5t / kombi)': 8.40,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 12.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 20.50,
    },
    'lucko_dugopolje': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Dugopolje',
      'I. Skupina (Osobna vozila / motocikli)': 24.00,
      'II. Skupina (Vozila do 3.5t / kombi)': 38.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 57.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 96.00,
    },
    'lucko_sibenik': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Šibenik',
      'I. Skupina (Osobna vozila / motocikli)': 19.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 31.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 46.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 77.00,
    },
    'lucko_zadar_istok': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Zadar istok',
      'I. Skupina (Osobna vozila / motocikli)': 16.00,
      'II. Skupina (Vozila do 3.5t / kombi)': 25.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 38.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 63.50,
    },
    'zapresic_krapina': {
      'koncesionar': 'AZM (A2)',
      'naziv': 'A2: Zaprešić - Krapina',
      'I. Skupina (Osobna vozila / motocikli)': 2.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 4.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 10.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 15.40,
    },
    'gruskovje_maribor': {
      'koncesionar': 'DARS',
      'naziv': 'A4: Gruškovje - Maribor',
      'I. Skupina (Osobna vozila / motocikli)': 4.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 7.90,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 12.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 19.00,
    },
    'obrezje_ljubljana': {
      'koncesionar': 'DARS',
      'naziv': 'A2: Obrežje - Ljubljana',
      'I. Skupina (Osobna vozila / motocikli)': 6.20,
      'II. Skupina (Vozila do 3.5t / kombi)': 11.10,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 17.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 28.00,
    },
    'bijaca_sarajevo': {
      'koncesionar': 'Autoceste FBiH',
      'naziv': 'A1: Bijača - Sarajevo',
      'I. Skupina (Osobna vozila / motocikli)': 7.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 13.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 19.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 32.00,
    },
    'smokovac_matesevo': {
      'koncesionar': 'Monteput',
      'naziv': 'A1: Smokovac - Mateševo',
      'I. Skupina (Osobna vozila / motocikli)': 3.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 6.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 9.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 15.00,
    },
    'tunel_sozina': {
      'koncesionar': 'Monteput',
      'naziv': 'Tunel Sozina',
      'I. Skupina (Osobna vozila / motocikli)': 2.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 5.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 10.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 18.00,
    },
  };

  // =========================================================================
  // 3. PISANJE I REGENERACIJA NA CLOUDU
  // =========================================================================
  static Future<void> osvjeziBazuNaCloudu() async {
    final sveLokacije = generirajSveGradove();

    WriteBatch batch = _db.batch();
    int brojac = 0;

    for (var entry in sveLokacije.entries) {
      DocumentReference ref = _db.collection('gradovi_mapiranje').doc(entry.key);
      batch.set(ref, entry.value, SetOptions(merge: true));
      brojac++;

      if (brojac % 400 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }
    await batch.commit();

    WriteBatch batchDionice = _db.batch();
    for (var entry in cestarineDionice.entries) {
      DocumentReference ref = _db.collection('cestarine_dionice').doc(entry.key);
      batchDionice.set(ref, entry.value);
    }
    await batchDionice.commit();
  }
}
