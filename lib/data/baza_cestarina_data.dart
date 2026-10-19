/// Podaci za inicijalno punjenje Firebase Cloud Firestore baze cestarina.
/// Obuhvaća 100 ključnih gradova, turističkih i kulturnih središta u Hrvatskoj, Sloveniji i BiH.

class BazaCestarinaData {
  /// 1. Mapiranje 100 gradova i mjesta na naplatne postaje i koncesionare
  static final Map<String, Map<String, String>> gradoviMapiranje = {
    // --- VELIKI REGIONALNI CENTRI (1-20) ---
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

    // --- TURISTIČKI GRADOVI NA OBALI I OTOCIMA (21-60) ---
    'rovinj': {'grad': 'Rovinj', 'postaja': 'Kanfanar', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'porec': {'grad': 'Poreč', 'postaja': 'Baderna', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'umag': {'grad': 'Umag', 'postaja': 'Umag', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'opatija': {'grad': 'Opatija', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'crikvenica': {'grad': 'Crikvenica', 'postaja': 'Crikvenica / Oštrovica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'krk': {'grad': 'Krk', 'postaja': 'Krk (Most)', 'koncesionar': 'Autotrolej / HAC', 'drzava': 'HR'},
    'cres': {'grad': 'Cres', 'postaja': 'Brestova (Trajekt)', 'koncesionar': 'Jadrolinija', 'drzava': 'HR'},
    'mali_losinj': {'grad': 'Mali Lošinj', 'postaja': 'Brestova (Trajekt)', 'koncesionar': 'Jadrolinija', 'drzava': 'HR'},
    'rab': {'grad': 'Rab', 'postaja': 'Stinica (Trajekt)', 'koncesionar': 'Jadrolinija', 'drzava': 'HR'},
    'novalja': {'grad': 'Novalja', 'postaja': 'Prizna / Žigljen', 'koncesionar': 'Jadrolinija', 'drzava': 'HR'},
    'pag': {'grad': 'Pag', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'biograd': {'grad': 'Biograd na Moru', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vodice': {'grad': 'Vodice', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'trogir': {'grad': 'Trogir', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'omis': {'grad': 'Omiš', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'makarska': {'grad': 'Makarska', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'metkovic': {'grad': 'Metković', 'postaja': 'Vrgorac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ploce': {'grad': 'Ploče', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'korcula': {'grad': 'Korčula', 'postaja': 'Karamatići (Trajekt)', 'koncesionar': 'HAC / Jadrolinija', 'drzava': 'HR'},
    'hvar': {'grad': 'Hvar', 'postaja': 'Dugopolje (Trajekt Split)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'bol': {'grad': 'Bol', 'postaja': 'Dugopolje (Trajekt Split)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'supetar': {'grad': 'Supetar', 'postaja': 'Dugopolje (Trajekt Split)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vis': {'grad': 'Vis', 'postaja': 'Dugopolje (Trajekt Split)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cavtat': {'grad': 'Cavtat', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'skradin': {'grad': 'Skradin', 'postaja': 'Skradin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nin': {'grad': 'Nin', 'postaja': 'Zadar zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novigrad': {'grad': 'Novigrad', 'postaja': 'Nova Vas', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'labin': {'grad': 'Labin', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'medulin': {'grad': 'Medulin', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'vrsar': {'grad': 'Vrsar', 'postaja': 'Kanfanar', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'motovun': {'grad': 'Motovun', 'postaja': 'Cerovlje', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'groznjan': {'grad':j Grožnjan = 'Grožnjan', 'postaja': 'Umag', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'starigrad': {'grad': 'Starigrad Paklenica', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'senj': {'grad': 'Senj', 'postaja': 'Žuta Lokva', 'Koncesionar': 'HAC', 'drzava': 'HR'},
    'baska': {'grad': 'Baška', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'malinska': {'grad': 'Malinska', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'crikvenica': {'grad': 'Crikvenica', 'postaja': 'Crikvenica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ognjica': {'grad': 'Ozalj', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dugopolje': {'grad': 'Dugopolje', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lucko': {'grad': 'Lučko', 'postaja': 'Lučko', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // --- KULTURNO-POVIJESNA I KONTINENTALNA SREDIŠTA (61-100) ---
    'samobor': {'grad': 'Samobor', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'jastrebarsko': {'grad': 'Jastrebarsko', 'postaja': 'Jastrebarsko / Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'krapina': {'grad': 'Krapina', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zabok': {'grad': 'Zabok', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'kumrovec': {'grad': 'Kumrovec', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'varazdinske_toplice': {'grad': 'Varaždinske Toplice', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'prelog': {'grad': 'Prelog', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ludbreg': {'grad': 'Ludbreg', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'daruvar': {'grad': 'Daruvar', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pakrac': {'grad': 'Pakrac', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lipik': {'grad': 'Lipik', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'kutina': {'grad': 'Kutina', 'postaja': 'Kutina', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novska': {'grad': 'Novska', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zupanja': {'grad': 'Županja', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nasice': {'grad': 'Našice', 'postaja': 'Đakovo', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'valpovo': {'grad': 'Valpovo', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'belisce': {'grad': 'Belišće', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'donji_miholjac': {'grad': 'Donji Miholjac', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'orahovica': {'grad': 'Orahovica', 'postaja': 'Orahovica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slatina': {'grad': 'Slatina', 'postaja': 'Kruševlje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pleternica': {'grad': 'Pleternica', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'otocac': {'grad': 'Otočac', 'postaja': 'Otočac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'gospić': {'grad': 'Gospić', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slunj': {'grad': 'Slunj', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'plitvice': {'grad': 'Plitvička Jezera', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ogulin': {'grad': 'Ogulin', 'postaja': 'Ogulin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'delnice': {'grad': 'Delnice', 'postaja': 'Delnice', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cabar': {'grad': 'Čabar', 'postaja': 'Delnice', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'fuzine': {'grad': 'Fužine', 'postaja': 'Fužine', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrbovsko': {'grad': 'Vrbovsko', 'postaja': 'Vrbovsko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'knin': {'grad': 'Knin', 'postaja': 'Šibenik / Zadar', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'imotski': {'grad': 'Imotski', 'postaja': 'Šestanovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrgorac': {'grad': 'Vrgorac', 'postaja': 'Vrgorac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sinj': {'grad': 'Sinj', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'trilj': {'grad': 'Trilj', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zapresic': {'grad': 'Zaprešić', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'ilok': {'grad': 'Ilok', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // --- SLOVENIJA I BIH (Ključna tranzitna središta) ---
    'ljubljana': {'grad': 'Ljubljana', 'postaja': 'Ljubljana čvor', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'maribor': {'grad': 'Maribor', 'postaja': 'Pesnica / Gruškovje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'sarajevo': {'grad': 'Sarajevo', 'postaja': 'Sarajevo sjever', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'banja_luka': {'grad': 'Banja Luka', 'postaja': 'Jakupovci', 'koncesionar': 'Autoputevi RS', 'drzava': 'BA'},
  };

  /// 2. Glavne dionice cestarina s cijenama po kategorijama vozila (€)
  static final List<Map<String, dynamic>> dioniceCestarina = [
    // HAC (Hrvatska - A1 / A6 / A4)
    {
      'id': 'dugopolje_lucko',
      'ulaz': 'Dugopolje',
      'izlaz': 'Lučko',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 24.00,
        'Mini bus <20': 37.60,
        'Midi bus 35': 55.20,
        'Veliki autobus 50': 83.70,
      }
    },
    {
      'id': 'dugopolje_karlovac',
      'ulaz': 'Dugopolje',
      'izlaz': 'Karlovac',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 21.50,
        'Mini bus <20': 33.50,
        'Midi bus 35': 49.20,
        'Veliki autobus 50': 74.60,
      }
    },
    {
      'id': 'lucko_karlovac',
      'ulaz': 'Lučko',
      'izlaz': 'Karlovac',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 2.50,
        'Mini bus <20': 4.10,
        'Midi bus 35': 6.00,
        'Veliki autobus 50': 9.10,
      }
    },
    {
      'id': 'lucko_zadar_istok',
      'ulaz': 'Lučko',
      'izlaz': 'Zadar istok',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 16.00,
        'Mini bus <20': 25.10,
        'Midi bus 35': 36.80,
        'Veliki autobus 50': 55.80,
      }
    },
    {
      'id': 'dugopolje_zadar_istok',
      'ulaz': 'Dugopolje',
      'izlaz': 'Zadar istok',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 8.50,
        'Mini bus <20': 13.50,
        'Midi bus 35': 19.80,
        'Veliki autobus 50': 30.00,
      }
    },
    {
      'id': 'lucko_sibenik',
      'ulaz': 'Lučko',
      'izlaz': 'Šibenik',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 20.10,
        'Mini bus <20': 31.50,
        'Midi bus 35': 46.20,
        'Veliki autobus 50': 70.00,
      }
    },
    {
      'id': 'lucko_grobnik',
      'ulaz': 'Lučko',
      'izlaz': 'Grobnik',
      'koncesionar': 'HAC (A6)',
      'cijene': {
        'Kombi 8+1': 10.00,
        'Mini bus <20': 15.50,
        'Midi bus 35': 22.80,
        'Veliki autobus 50': 34.50,
      }
    },
    // AZM (A2 Zagreb - Macelj)
    {
      'id': 'zapresic_krapina',
      'ulaz': 'Zaprešić',
      'izlaz': 'Krapina',
      'koncesionar': 'AZM (A2)',
      'cijene': {
        'Kombi 8+1': 4.00,
        'Mini bus <20': 6.70,
        'Midi bus 35': 10.00,
        'Veliki autobus 50': 15.40,
      }
    },
    // DARS (Slovenija)
    {
      'id': 'obrezje_ljubljana',
      'ulaz': 'Obrežje',
      'izlaz': 'Ljubljana čvor',
      'koncesionar': 'DARS (SI)',
      'cijene': {
        'Kombi 8+1': 16.00,
        'Mini bus <20': 22.00,
        'Midi bus 35': 35.00,
        'Veliki autobus 50': 52.00,
      }
    },
    // FBiH (BiH)
    {
      'id': 'bijaca_sarajevo',
      'ulaz': 'Bijača',
      'izlaz': 'Sarajevo sjever',
      'koncesionar': 'Autoceste FBiH',
      'cijene': {
        'Kombi 8+1': 6.00,
        'Mini bus <20': 11.00,
        'Midi bus 35': 18.00,
        'Veliki autobus 50': 27.00,
      }
    },
  ];
}
