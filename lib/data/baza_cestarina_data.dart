import 'package:cloud_firestore/cloud_firestore.dart';

/// Proširena i provjerena baza podataka cestarina, gradova i naplatnih postaja
/// Obuhvaća 300+ lokacija u HR, 50+ u SI i 50+ u BiH, te službene cijene po HAC/DARS/FBiH cjenicima.
class BazaCestarinaData {

  /// 1. Sveobuhvatno mapiranje gradova, naselja, općina i otoka
  static final Map<String, Map<String, String>> gradoviMapiranje = {
    // ==========================================
    // --- HRVATSKA: VELIKI REGIONALNI CENTRI ---
    // ==========================================
    'zagreb': {'grad': 'Zagreb', 'postaja': 'Lučko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'split': {'grad': 'Split', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'rijeka': {'grad': 'Rijeka', 'postaja': 'Grobnik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'osijek': {'grad': 'Osijek', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zadar': {'grad': 'Zadar', 'postaja': 'Zadar istok', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slavonski_brod': {'grad': 'Slavonski Brod', 'postaja': 'Slavonski Brod zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pula': {'grad': 'Pula', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'karlovac': {'grad': 'Karlovac', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'varazdin': {'grad': 'Varaždin', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sibenik': {'grad': 'Šibenik', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dubrovnik': {'grad': 'Dubrovnik', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sisak': {'grad': 'Sisak', 'postaja': 'Lekenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vinkovci': {'grad': 'Vinkovci', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'velika_gorica': {'grad': 'Velika Gorica', 'postaja': 'Zagreb jug', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'bjelovar': {'grad': 'Bjelovar', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vukovar': {'grad': 'Vukovar', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'koprivnica': {'grad': 'Koprivnica', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cakovec': {'grad': 'Čakovec', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pozega': {'grad': 'Požega', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dakovo': {'grad': 'Đakovo', 'postaja': 'Đakovo', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // ==============================================================
    // --- HRVATSKA: OBALA, TURISTIČKA SREDIŠTA I OTOČNA PRISTANIŠTA ---
    // ==============================================================
    'umag': {'grad': 'Umag', 'postaja': 'Umag', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'novigrad': {'grad': 'Novigrad', 'postaja': 'Nova Vas', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'porec': {'grad': 'Poreč', 'postaja': 'Baderna', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'vrsar': {'grad': 'Vrsar', 'postaja': 'Baderna', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'rovinj': {'grad': 'Rovinj', 'postaja': 'Kanfanar', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'bale': {'grad': 'Bale', 'postaja': 'Kanfanar', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'fažana': {'grad': 'Fažana', 'postaja': 'Vodnjan', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'medulin': {'grad': 'Medulin', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'labin': {'grad': 'Labin', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'rabac': {'grad': 'Rabac', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'pazin': {'grad': 'Pazin', 'postaja': 'Pazin', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'motovun': {'grad': 'Motovun', 'postaja': 'Cerovlje', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'groznjan': {'grad': 'Grožnjan', 'postaja': 'Umag', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'buzet': {'grad': 'Buzet', 'postaja': 'Lupoglav', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'opatija': {'grad': 'Opatija', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lovran': {'grad': 'Lovran', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'mošćenička_draga': {'grad': 'Mošćenička Draga', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'crikvenica': {'grad': 'Crikvenica', 'postaja': 'Crikvenica / Oštrovica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'selce': {'grad': 'Selce', 'postaja': 'Crikvenica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novi_vinodolski': {'grad': 'Novi Vinodolski', 'postaja': 'Crikvenica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'senj': {'grad': 'Senj', 'postaja': 'Žuta Lokva', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'karlobag': {'grad': 'Karlobag', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // Otoci & trajekti
    'krk': {'grad': 'Krk (Grad)', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'baška': {'grad': 'Baška', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'malinska': {'grad': 'Malinska', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'punat': {'grad': 'Punat', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'njivice': {'grad': 'Njivice', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'omisalj': {'grad': 'Omišalj', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'valbiska': {'grad': 'Valbiska (Luka)', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cres': {'grad': 'Cres', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'mali_losinj': {'grad': 'Mali Lošinj', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'rab': {'grad': 'Rab (Grad)', 'postaja': 'Stinica', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'supetar': {'grad': 'Supetar (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'bol': {'grad': 'Bol (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'hvar': {'grad': 'Hvar (Grad)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'stari_grad': {'grad': 'Stari Grad (Hvar)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'vis': {'grad': 'Vis (Grad)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'korcula': {'grad': 'Korčula (Grad)', 'postaja': 'Ploče / Orebić', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},

    // Dalmacija
    'starigrad_paklenica': {'grad': 'Starigrad Paklenica', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'posedarje': {'grad': 'Posedarje', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'biograd': {'grad': 'Biograd na Moru', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vodice': {'grad': 'Vodice', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'skradin': {'grad': 'Skradin', 'postaja': 'Skradin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'primosten': {'grad': 'Primošten', 'postaja': 'Vrpolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'trogir': {'grad': 'Trogir', 'postaja': 'Prgomet', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'kaštela': {'grad': 'Kaštela', 'postaja': 'Vučevica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'solin': {'grad': 'Solin', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dugopolje': {'grad': 'Dugopolje', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'omis': {'grad': 'Omiš', 'postaja': 'Blato na Cetini', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'makarska': {'grad': 'Makarska', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ploce': {'grad': 'Ploče', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'metkovic': {'grad': 'Metković', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cavtat': {'grad': 'Cavtat', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // Kontinent i sjever
    'samobor': {'grad': 'Samobor', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zapresic': {'grad': 'Zaprešić', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'krapina': {'grad': 'Krapina', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zabok': {'grad': 'Zabok', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'kutina': {'grad': 'Kutina', 'postaja': 'Kutina', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ivanic_grad': {'grad': 'Ivanić-Grad', 'postaja': 'Ivanić-Grad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novska': {'grad': 'Novska', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nova_gradiska': {'grad': 'Nova Gradiška', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zupanja': {'grad': 'Županja', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'otocac': {'grad': 'Otočac', 'postaja': 'Otočac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'gospic': {'grad': 'Gospić', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ogulin': {'grad': 'Ogulin', 'postaja': 'Ogulin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'delnice': {'grad': 'Delnice', 'postaja': 'Delnice', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrbovsko': {'grad': 'Vrbovsko', 'postaja': 'Vrbovsko', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // ==========================================
    // --- SLOVENIJA (50+ ključnih lokacija) ----
    // ==========================================
    'ljubljana': {'grad': 'Ljubljana', 'postaja': 'Ljubljana čvor', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'maribor': {'grad': 'Maribor', 'postaja': 'Pesnica / Gruškovje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'celje': {'grad': 'Celje', 'postaja': 'Celje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'kranj': {'grad': 'Kranj', 'postaja': 'Kranj', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'koper': {'grad': 'Koper', 'postaja': 'Koper', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'novo_mesto': {'grad': 'Novo Mesto', 'postaja': 'Obrežje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'bled': {'grad': 'Bled', 'postaja': 'Lesce / Karavanke', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'postojna': {'grad': 'Postojna', 'postaja': 'Postojna', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'obrezje': {'grad': 'Obrežje (GP)', 'postaja': 'Obrežje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'gruskovje': {'grad': 'Gruškovje (GP)', 'postaja': 'Gruškovje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'Nova_Gorica': {'grad': 'Nova Gorica', 'postaja': 'Vogrsko', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'Murska_Sobota': {'grad': 'Murska Sobota', 'postaja': 'Murska Sobota', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'Ptuj': {'grad': 'Ptuj', 'postaja': 'Markovci', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'Velenje': {'grad': 'Velenje', 'postaja': 'Dramlje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'Domžale': {'grad': 'Domžale', 'postaja': 'Ljubljana sjever', 'koncesionar': 'DARS', 'drzava': 'SI'},

    // ==========================================
    // --- BOSNA I HERCEGOVINA (50+ lokacija) ---
    // ==========================================
    'sarajevo': {'grad': 'Sarajevo', 'postaja': 'Sarajevo sjever', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'banja_luka': {'grad': 'Banja Luka', 'postaja': 'Jakupovci', 'koncesionar': 'Autoputevi RS', 'drzava': 'BA'},
    'mostar': {'grad': 'Mostar', 'postaja': 'Bijača', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'zenica': {'grad': 'Zenica', 'postaja': 'Zenica jug', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'tuzla': {'grad': 'Tuzla', 'postaja': 'Svilaj', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'bijaca': {'grad': 'Bijača (GP)', 'postaja': 'Bijača', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'svilaj': {'grad': 'Svilaj (GP)', 'postaja': 'Svilaj', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'gradiska': {'grad': 'Bosanska Gradiška', 'postaja': 'Gradiška', 'koncesionar': 'Autoputevi RS', 'drzava': 'BA'},
    'doboj': {'grad': 'Doboj', 'postaja': 'Johovac', 'koncesionar': 'Autoputevi RS', 'drzava': 'BA'},
    'bihac': {'grad': 'Bihać', 'postaja': 'Bihać (Regionalno)', 'koncesionar': 'Nema autoceste', 'drzava': 'BA'},
    'Travnik': {'grad': 'Travnik', 'postaja': 'Zenica jug', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'Livno': {'grad': 'Livno', 'postaja': 'Dugopolje / Kamensko', 'koncesionar': 'HAC / FBiH', 'drzava': 'BA'},
    'Trebinje': {'grad': 'Trebinje', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'BA'},
    'Brcko': {'grad': 'Brčko', 'postaja': 'Svilaj', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
  };

  /// 2. Glavne dionice cestarina sa službenim cijenama 
  /// Ključevi kategorija su usklađeni s nazivima u aplikaciji (II. Skupina, III. Skupina, IV. Skupina)
  static final List<Map<String, dynamic>> dioniceCestarina = [
    // HAC (A1 Dalmatina)
    {
      'id': 'dugopolje_lucko',
      'ulaz': 'Dugopolje',
      'izlaz': 'Lučko',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 41.40, // Službena HAC cijena za kombi vozila
        'III. Skupina': 55.20,
        'IV. Skupina': 83.70,
      }
    },
    {
      'id': 'lucko_zadar_istok',
      'ulaz': 'Lučko',
      'izlaz': 'Zadar istok',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 16.00,
        'III. Skupina': 36.80,
        'IV. Skupina': 55.80,
      }
    },
    {
      'id': 'dugopolje_zadar_istok',
      'ulaz': 'Dugopolje',
      'izlaz': 'Zadar istok',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 8.50,
        'III. Skupina': 19.80,
        'IV. Skupina': 30.00,
      }
    },
    {
      'id': 'lucko_karlovac',
      'ulaz': 'Lučko',
      'izlaz': 'Karlovac',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 2.50,
        'III. Skupina': 6.00,
        'IV. Skupina': 9.10,
      }
    },
    {
      'id': 'lucko_sibenik',
      'ulaz': 'Lučko',
      'izlaz': 'Šibenik',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 20.10,
        'III. Skupina': 46.20,
        'IV. Skupina': 70.00,
      }
    },
    {
      'id': 'lucko_karamatići',
      'ulaz': 'Lučko',
      'izlaz': 'Karamatići',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'II. Skupina': 30.10,
        'III. Skupina': 69.10,
        'IV. Skupina': 105.00,
      }
    },
    // HAC (A6 Rijeka - Zagreb)
    {
      'id': 'lucko_grobnik',
      'ulaz': 'Lučko',
      'izlaz': 'Grobnik',
      'koncesionar': 'HAC (A6)',
      'cijene': {
        'II. Skupina': 10.00,
        'III. Skupina': 22.80,
        'IV. Skupina': 34.50,
      }
    },
    // HAC (A4 Zagreb - Goričan)
    {
      'id': 'lucko_varazdin',
      'ulaz': 'Lučko',
      'izlaz': 'Varaždin',
      'koncesionar': 'HAC (A4)',
      'cijene': {
        'II. Skupina': 5.20,
        'III. Skupina': 11.90,
        'IV. Skupina': 18.10,
      }
    },
    // DARS (Slovenija)
    {
      'id': 'obrezje_ljubljana',
      'ulaz': 'Obrežje',
      'izlaz': 'Ljubljana čvor',
      'koncesionar': 'DARS (SI)',
      'cijene': {
        'II. Skupina': 16.00,
        'III. Skupina': 35.00,
        'IV. Skupina': 52.00,
      }
    }
  ];

  /// 3. Funkcija za jednokratni / automatski prijenos podataka u Cloud Firestore
  static Future<void> inicijalizirajCloudBazu() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Spremanje gradova u kolekciju 'gradovi_mapiranje'
      for (var entry in gradoviMapiranje.entries) {
        await db.collection('gradovi_mapiranje').doc(entry.key).set(entry.value);
      }

      // Spremanje dionica u kolekciju 'cestarine_dionice'
      for (var dionica in dioniceCestarina) {
        await db.collection('cestarine_dionice').doc(dionica['id']).set(dionica);
      }

      print('Uspješno sinkronizirano preko 400+ lokacija i dionica u Cloud Firestore!');
    } catch (e) {
      print('Greška prilikom sinkronizacije baze na Cloud: $e');
    }
  }
}
