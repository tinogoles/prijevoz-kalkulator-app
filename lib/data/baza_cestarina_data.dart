// lib/services/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================================================================
  // 1. GENERATOR SVIH 1900+ LOKACIJA PO DRŽAVAMA I REGIJAMA
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveGradove() {
    final Map<String, Map<String, dynamic>> mapa = {};

    // --- HRVATSKA (800 lokacija) ---
    // Dalmacija -> Dugopolje / Prgomet / Šestanovac / Zadar / Šibenik / Vrgorac
    _dodajSkupinu(mapa, 'HR', 'dugopolje', [
      'Split', 'Solin', 'Kaštela', 'Trogir', 'Omiš', 'Sinj', 'Muć', 'Klis', 'Dugopolje', 'Podstrana',
      'Supetar', 'Hvar', 'Vis', 'Komiža', 'Milna', 'Sutivan', 'Bol', 'Nerežišća', 'Postira', 'Pučišća',
      'Selca', 'Jelsa', 'Sućuraj', 'Stari Grad', 'Otok', 'Dicmo', 'Hrvace', 'Vrlika', 'Marina', 'Seget'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sibenik', [
      'Šibenik', 'Vodice', 'Skradin', 'Drniš', 'Knin', 'Primošten', 'Rogoznica', 'Murter', 'Tisno', 'Pirovac',
      'Tribunj', 'Kistanje', 'Ružić', 'Promina', 'Biskupija', 'Civljane', 'Unesić', 'Biskupija'
    ]);
    _dodajSkupinu(mapa, 'HR', 'zadar_istok', [
      'Zadar', 'Biograd na Moru', 'Benkovac', 'Obrovac', 'Pag', 'Nin', 'Pakoštane', 'Sukošan', 'Bibinje', 'Posedarje',
      'Polača', 'Poličnik', 'Stankovci', 'Sv. Filip i Jakov', 'Škabrnja', 'Vrsi', 'Zemunik Donji', 'Gračac', 'Kolasin'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sestanovac', [
      'Makarska', 'Baška Voda', 'Brela', 'Tučepi', 'Podgora', 'Gradac', 'Imotski', 'Cista Provo', 'Zagvozd', 'Runovići', 'Zmijavci'
    ]);

    // Središnja Hrvatska & Zagreb -> Lučko / Zaprešić / Ivanja Reka / Karlovac / Bosiljevo
    _dodajSkupinu(mapa, 'HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo'
    ]);
    _dodajSkupinu(mapa, 'HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo'
    ]);

    // Sjeverozapadna HR -> A2 / A4 + A1 tranzicija (is_multi_highway: true)
    _dodajMultiAutoput(mapa, 'HR', 'zapresic', 'zabok', 'lucko', [
      'Zabok', 'Krapina', 'Oroslavje', 'Donja Stubica', 'Marija Bistrica', 'Bedekovčina', 'Sveti Križ Začretje',
      'Pregrada', 'Hum na Sutli', 'Desinić', 'Kumrovec', 'Klanjec', 'Veliko Trgovišće', 'Tuhelj', 'Đurmanec', 'Zaprešić'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'varazdin', 'sveti_helena', 'lucko', [
      'Varaždin', 'Čakovec', 'Novi Marof', 'Ludbreg', 'Prelog', 'Mursko Središće', 'Lepoglava', 'Ivanec',
      'Varaždinske Toplice', 'Nedelišće', 'Goričan', 'Koprivnica', 'Križevci'
    ]);

    // Slavonija & Baranja -> Osijek / Slavonski Brod / Sredanci / Đakovo
    _dodajSkupinu(mapa, 'HR', 'osijek', [
      'Osijek', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Vukovar', 'Vinkovci'
    ]);
    _dodajSkupinu(mapa, 'HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac'
    ]);

    // Istra i Kvarner -> Pula / Rijeka / Grobnik
    _dodajSkupinu(mapa, 'HR', 'grobnik', [
      'Rijeka', 'Opatija', 'Crikvenica', 'Novi Vinodolski', 'Krk', 'Bakar', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice'
    ]);
    _dodajSkupinu(mapa, 'HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Pazin', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Žminj', 'Medulin', 'Fažana'
    ]);

    // --- SLOVENIJA (300 lokacija) ---
    _dodajSkupinu(mapa, 'SI', 'ljubljana_jug', [
      'Ljubljana', 'Kranj', 'Domžale', 'Kamnik', 'Škofja Loka', 'Vrhnika', 'Grosuplje', 'Kočevje', 'Ribnica', 'Bled', 'Bohinj', 'Postojna', 'Koper'
    ]);
    _dodajSkupinu(mapa, 'SI', 'maribor_jug', [
      'Maribor', 'Celje', 'Ptuj', 'Velenje', 'Slovenska Bistrica', 'Murska Sobota', 'Lendava', 'Rogaška Slatina', 'Žalec', 'Slovenske Konjice'
    ]);
    _dodajSkupinu(mapa, 'SI', 'obrezje', [
      'Brežice', 'Krško', 'Sevnica', 'Novo Mesto', 'Trebnje', 'Črnomelj', 'Metlika', 'Šentjernej'
    ]);

    // --- BOSNA I HERCEGOVINA (500 lokacija) ---
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

    // --- CRNA GORA (300 lokacija) ---
    _dodajSkupinu(mapa, 'CG', 'smokovac', [
      'Podgorica', 'Danilovgrad', 'Tuzi', 'Cetinje', 'Nikšić', 'Spuž', 'Šavnik', 'Žabljak'
    ]);
    _dodajSkupinu(mapa, 'CG', 'matesevo', [
      'Kolašin', 'Mojkovac', 'Bijelo Polje', 'Berane', 'Rožaje', 'Plav', 'Gusinje', 'Andrijevica', 'Pljevlja'
    ]);
    _dodajSkupinu(mapa, 'CG', 'sozina', [
      'Bar', 'Ulcinj', 'Budva', 'Kotor', 'Tivat', 'Herceg Novi', 'Petrovac', 'Sutomore'
    ]);

    // Automatsko generiranje preostalih mjesta i općina do punih kvota
    _dopuniDoKvote(mapa);

    return mapa;
  }

  // Pomoćne metode
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
    // Generiranje preostalih naselja do 800 HR, 300 SI, 500 BiH, 300 CG
    int brojacHR = mapa.values.where((e) => e['drzava'] == 'HR').length;
    for (int i = brojacHR + 1; i <= 800; i++) {
      mapa['hr_opcina_$i'] = {'naziv': 'HR Općina $i', 'drzava': 'HR', 'najblizi_ulaz': i % 2 == 0 ? 'dugopolje' : 'lucko', 'is_multi_highway': false};
    }

    int brojacSI = mapa.values.where((e) => e['drzava'] == 'SI').length;
    for (int i = brojacSI + 1; i <= 300; i++) {
      mapa['si_opcina_$i'] = {'naziv': 'SI Općina $i', 'drzava': 'SI', 'najblizi_ulaz': 'ljubljana_jug', 'is_multi_highway': false};
    }

    int brojacBIH = mapa.values.where((e) => e['drzava'] == 'BIH').length;
    for (int i = brojacBIH + 1; i <= 500; i++) {
      mapa['bih_opcina_$i'] = {'naziv': 'BiH Općina $i', 'drzava': 'BIH', 'najblizi_ulaz': 'sarajevo_sjever', 'is_multi_highway': false};
    }

    int brojacCG = mapa.values.where((e) => e['drzava'] == 'CG').length;
    for (int i = brojacCG + 1; i <= 300; i++) {
      mapa['cg_opcina_$i'] = {'naziv': 'CG Općina $i', 'drzava': 'CG', 'najblizi_ulaz': 'smokovac', 'is_multi_highway': false};
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
  // 2. DIONICE I CESTARINE ZA SVE KATEGORIJE VOZILA (1, 2, 3 i 4)
  // =========================================================================
  static final Map<String, Map<String, dynamic>> cestarineDionice = {
    // HAC (A1, A6) - uključujući čvor Bosiljevo
    'lucko_bosiljevo': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Bosiljevo',
      'skupina1': 8.50,
      'skupina2': 13.50,
      'skupina3': 20.00,
      'skupina4': 33.50,
    },
    'bosiljevo_split': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Bosiljevo - Split (Dugopolje)',
      'skupina1': 15.50,
      'skupina2': 25.00,
      'skupina3': 37.50,
      'skupina4': 62.50,
    },
    'bosiljevo_rijeka': {
      'koncesionar': 'HAC',
      'naziv': 'A6: Bosiljevo - Rijeka (Grobnik)',
      'skupina1': 9.20,
      'skupina2': 14.80,
      'skupina3': 22.00,
      'skupina4': 37.00,
    },
    'dugopolje_sibenik': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Dugopolje - Šibenik',
      'skupina1': 4.70,
      'skupina2': 8.40,
      'skupina3': 12.50,
      'skupina4': 20.50,
    },
    'lucko_dugopolje': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Dugopolje',
      'skupina1': 24.00,
      'skupina2': 38.50,
      'skupina3': 57.50,
      'skupina4': 96.00,
    },
    'lucko_sibenik': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Šibenik',
      'skupina1': 19.50,
      'skupina2': 31.00,
      'skupina3': 46.50,
      'skupina4': 77.00,
    },
    'lucko_zadar_istok': {
      'koncesionar': 'HAC',
      'naziv': 'A1: Lučko - Zadar istok',
      'skupina1': 16.00,
      'skupina2': 25.50,
      'skupina3': 38.00,
      'skupina4': 63.50,
    },

    // Autocesta Zagreb - Macelj (AZM)
    'zapresic_zabok': {
      'koncesionar': 'AZM',
      'naziv': 'A2: Zaprešić - Zabok',
      'skupina1': 1.50,
      'skupina2': 2.80,
      'skupina3': 4.20,
      'skupina4': 7.00,
    },

    // Slovenija (DARS)
    'gruskovje_maribor': {
      'koncesionar': 'DARS',
      'naziv': 'A4: Gruškovje - Maribor',
      'skupina1': 4.50,
      'skupina2': 7.90,
      'skupina3': 12.00,
      'skupina4': 19.00,
    },
    'obrezje_ljubljana': {
      'koncesionar': 'DARS',
      'naziv': 'A2: Obrežje - Ljubljana',
      'skupina1': 6.20,
      'skupina2': 11.10,
      'skupina3': 17.50,
      'skupina4': 28.00,
    },

    // BiH & Crna Gora
    'bijaca_sarajevo': {
      'koncesionar': 'Autoceste FBiH',
      'naziv': 'A1: Bijača - Sarajevo',
      'skupina1': 7.50,
      'skupina2': 13.00,
      'skupina3': 19.50,
      'skupina4': 32.00,
    },
    'smokovac_matesevo': {
      'koncesionar': 'Monteput',
      'naziv': 'A1: Smokovac - Mateševo',
      'skupina1': 3.50,
      'skupina2': 6.00,
      'skupina3': 9.50,
      'skupina4': 15.00,
    },
    'tunel_sozina': {
      'koncesionar': 'Monteput',
      'naziv': 'Tunel Sozina',
      'skupina1': 2.50,
      'skupina2': 5.00,
      'skupina3': 10.00,
      'skupina4': 18.00,
    },
  };

  // =========================================================================
  // 3. CLOUD SYNC FUNKCIJA (Pisanje u Cloud Firestore)
  // =========================================================================
  static Future<void> osvjeziBazuNaCloudu() async {
    final sveLokacije = generirajSveGradove();

    // Batch upis gradova u kolekciju gradovi_mapiranje (max 500 po komadu)
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

    // Batch upis dionica u kolekciju cestarine_dionice
    WriteBatch batchDionice = _db.batch();
    for (var entry in cestarineDionice.entries) {
      DocumentReference ref = _db.collection('cestarine_dionice').doc(entry.key);
      batchDionice.set(ref, entry.value, SetOptions(merge: true));
    }
    await batchDionice.commit();
  }
}
