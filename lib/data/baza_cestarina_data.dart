/// Podaci za inicijalno punjenje Firebase Cloud Firestore baze cestarina.
/// Podržava Hrvatsku (HR), Sloveniju (SI), Bosnu i Hercegovinu (BA) i Crnu Goru (ME).

class BazaCestarinaData {
  /// 1. Mapiranje gradova na naplatne postaje i koncesionare
  static final Map<String, Map<String, String>> gradoviMapiranje = {
    // --- HRVATSKA ---
    'split': {'grad': 'Split', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zagreb': {'grad': 'Zagreb', 'postaja': 'Lučko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lucko': {'grad': 'Lučko', 'postaja': 'Lučko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zapresic': {'grad': 'Zaprešić', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'krapina': {'grad': 'Krapina', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zadar': {'grad': 'Zadar', 'postaja': 'Zadar istok', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'karlovac': {'grad': 'Karlovac', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'rijeka': {'grad': 'Rijeka', 'postaja': 'Grobnik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sibenik': {'grad': 'Šibenik', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'osijek': {'grad': 'Osijek', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pula': {'grad': 'Pula', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'dubrovnik': {'grad': 'Dubrovnik', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'varazdin': {'grad': 'Varaždin', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slavonski_brod': {'grad': 'Slavonski Brod', 'postaja': 'Slavonski Brod zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // --- SLOVENIJA ---
    'ljubljana': {'grad': 'Ljubljana', 'postaja': 'Ljubljana čvor', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'maribor': {'grad': 'Maribor', 'postaja': 'Pesnica / Gruškovje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'novo_mesto': {'grad': 'Novo Mesto', 'postaja': 'Obrežje', 'koncesionar': 'DARS', 'drzava': 'SI'},
    'koper': {'grad': 'Koper', 'postaja': 'Koper', 'koncesionar': 'DARS', 'drzava': 'SI'},

    // --- BOSNA I HERCEGOVINA ---
    'sarajevo': {'grad': 'Sarajevo', 'postaja': 'Sarajevo sjever', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'banja_luka': {'grad': 'Banja Luka', 'postaja': 'Jakupovci', 'koncesionar': 'Autoputevi RS', 'drzava': 'BA'},
    'mostar': {'grad': 'Mostar', 'postaja': 'Bijača', 'koncesionar': 'Autoceste FBiH', 'drzava': 'BA'},
    'bihac': {'grad': 'Bihać', 'postaja': 'Bihać (regionalno)', 'koncesionar': 'Nema autoceste', 'drzava': 'BA'},

    // --- CRNA GORA ---
    'podgorica': {'grad': 'Podgorica', 'postaja': 'Smokovac', 'koncesionar': 'Monteput', 'drzava': 'ME'},
    'niksic': {'grad': 'Nikšić', 'postaja': 'Nikšić (magistrala)', 'koncesionar': 'Nema autoceste', 'drzava': 'ME'},
    'bar': {'grad': 'Bar', 'postaja': 'Tunel Sozina', 'koncesionar': 'Monteput', 'drzava': 'ME'},
  };

  /// 2. Dionice cestarina s cijenama po kategorijama vozila (€)
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

    // AZM (Hrvatska - A2 Zagreb - Macelj)
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

    // DARS (Slovenija - Tranzit / DarsGo procjene po vožnji)
    {
      'id': 'obrezje_ljubljana',
      'ulaz': 'Obrežje',
      'izlaz': 'Ljubljana čvor',
      'koncesionar': 'DARS (SI)',
      'cijene': {
        'Kombi 8+1': 16.00, // Tjedna/mjesečna vinjeta ili dionica
        'Mini bus <20': 22.00,
        'Midi bus 35': 35.00,
        'Veliki autobus 50': 52.00,
      }
    },
    {
      'id': 'gruskovje_maribor',
      'ulaz': 'Pesnica / Gruškovje',
      'izlaz': 'Maribor',
      'koncesionar': 'DARS (SI)',
      'cijene': {
        'Kombi 8+1': 16.00,
        'Mini bus <20': 18.00,
        'Midi bus 35': 28.00,
        'Veliki autobus 50': 40.00,
      }
    },

    // Autoceste FBiH / RS (Bosna i Hercegovina)
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

    // Monteput (Crna Gora)
    {
      'id': 'smokovac_matesevo',
      'ulaz': 'Smokovac',
      'izlaz': 'Mateševo',
      'koncesionar': 'Monteput (A1 ME)',
      'cijene': {
        'Kombi 8+1': 3.50,
        'Mini bus <20': 6.00,
        'Midi bus 35': 10.50,
        'Veliki autobus 50': 17.00,
      }
    },
    {
      'id': 'tunel_sozina',
      'ulaz': 'Podgorica (Sozina)',
      'izlaz': 'Bar',
      'koncesionar': 'Monteput',
      'cijene': {
        'Kombi 8+1': 2.50,
        'Mini bus <20': 5.00,
        'Midi bus 35': 8.00,
        'Veliki autobus 50': 12.00,
      }
    },
  ];
}
