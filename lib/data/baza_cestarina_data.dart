/// Podaci za inicijalno punjenje Firebase Cloud Firestore baze cestarina.
/// Obuhvaća 230+ gradova, naselja, otoka i trajektnih pristaništa u Hrvatskoj (HR),
/// te ključne tranzitne čvorove u Sloveniji (SI) i Bosni i Hercegovini (BA).

class BazaCestarinaData {
  /// 1. Sveobuhvatno mapiranje gradova, naselja i otoka na naplatne postaje i koncesionare
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
    // Istra & Kvarner
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

    // Otoci sjevernog Jadrana & trajektna pristaništa
    'krk': {'grad': 'Krk (Grad)', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'baška': {'grad': 'Baška', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'malinska': {'grad': 'Malinska', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'punat': {'grad': 'Punat', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'njivice': {'grad': 'Njivice', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'omisalj': {'grad': 'Omišalj', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'valbiska': {'grad': 'Valbiska (Luka)', 'postaja': 'Krk (Most)', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'brestova': {'grad': 'Brestova (Luka)', 'postaja': 'Lupoglav', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'cres': {'grad': 'Cres', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'mali_losinj': {'grad': 'Mali Lošinj', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'velik_losinj': {'grad': 'Veli Lošinj', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'osor': {'grad': 'Osor', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'rab': {'grad': 'Rab (Grad)', 'postaja': 'Stinica', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'lopar': {'grad': 'Lopar', 'postaja': 'Stinica', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'stinica': {'grad': 'Stinica (Luka)', 'postaja': 'Žuta Lokva', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // Dalmacija - Zadar, Šibenik, Split, Makarska
    'starigrad_paklenica': {'grad': 'Starigrad Paklenica', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'posedarje': {'grad': 'Posedarje', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nin': {'grad': 'Nin', 'postaja': 'Zadar zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'privlaka': {'grad': 'Privlaka', 'postaja': 'Zadar zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vir': {'grad': 'Vir', 'postaja': 'Zadar zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pakoštane': {'grad': 'Pakoštane', 'postaja': 'Pirovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'biograd': {'grad': 'Biograd na Moru', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sukosan': {'grad': 'Sukošan', 'postaja': 'Zadar istok', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pirovac': {'grad': 'Pirovac', 'postaja': 'Pirovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vodice': {'grad': 'Vodice', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'skradin': {'grad': 'Skradin', 'postaja': 'Skradin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'primosten': {'grad': 'Primošten', 'postaja': 'Vrpolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'rogoznica': {'grad': 'Rogoznica', 'postaja': 'Vrpolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'trogir': {'grad': 'Trogir', 'postaja': 'Prgomet', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'seget': {'grad': 'Seget Donji', 'postaja': 'Prgomet', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'kaštela': {'grad': 'Kaštela', 'postaja': 'Vučevica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'solin': {'grad': 'Solin', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dugopolje': {'grad': 'Dugopolje', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'stobrec': {'grad': 'Stobreč', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'podstrana': {'grad': 'Podstrana', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'omis': {'grad': 'Omiš', 'postaja': 'Blato na Cetini', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'brela': {'grad': 'Brela', 'postaja': 'Šestanovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'baska_voda': {'grad': 'Baška Voda', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'makarska': {'grad': 'Makarska', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'tucepi': {'grad': 'Tučepi', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'podgora': {'grad': 'Podgora', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'drvenik': {'grad': 'Drvenik (Luka)', 'postaja': 'Ravča', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'gradac': {'grad': 'Gradac', 'postaja': 'Ravča', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ploce': {'grad': 'Ploče', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'metkovic': {'grad': 'Metković', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'opuzen': {'grad': 'Opuzen', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ston': {'grad': 'Ston', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'orebic': {'grad': 'Orebić', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slano': {'grad': 'Slano', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cavtat': {'grad': 'Cavtat', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'konavle': {'grad': 'Konavle / Gruda', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // Otoci srednje i južne Dalmacije
    'pag': {'grad': 'Pag (Grad)', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novalja': {'grad': 'Novalja', 'postaja': 'Prizna / Žigljen', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'prizna': {'grad': 'Prizna (Luka)', 'postaja': 'Žuta Lokva', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'supetar': {'grad': 'Supetar (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'bol': {'grad': 'Bol (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'postira': {'grad': 'Postira (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'sumartin': {'grad': 'Sumartin (Brač)', 'postaja': 'Makarska (Zagvozd)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'hvar': {'grad': 'Hvar (Grad)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'stari_grad': {'grad': 'Stari Grad (Hvar)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'jelsa': {'grad': 'Jelsa (Hvar)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'sucuraj': {'grad': 'Sućuraj (Hvar)', 'postaja': 'Drvenik (Ravča)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'vis': {'grad': 'Vis (Grad)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'komiza': {'grad': 'Komiža (Vis)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'korcula': {'grad': 'Korčula (Grad)', 'postaja': 'Ploče / Orebić', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'vela_luka': {'grad': 'Vela Luka', 'postaja': 'Split / Ploče', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'blato': {'grad': 'Blato (Korčula)', 'postaja': 'Split / Ploče', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'lumbarda': {'grad': 'Lumbarda', 'postaja': 'Ploče / Orebić', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'lastovo': {'grad': 'Lastovo', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},

    // ==============================================================
    // --- HRVATSKA: KONTINENTALNA I KULTURNO-POVIJESNA SREDIŠTA ---
    // ==============================================================
    'samobor': {'grad': 'Samobor', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zapresic': {'grad': 'Zaprešić', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'jastrebarsko': {'grad': 'Jastrebarsko', 'postaja': 'Jastrebarsko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'krapina': {'grad': 'Krapina', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zabok': {'grad': 'Zabok', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'stubicke_toplice': {'grad': 'Stubičke Toplice', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'kumrovec': {'grad': 'Kumrovec', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'marija_bistrica': {'grad': 'Marija Bistrica', 'postaja': 'Popovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'varazdinske_toplice': {'grad': 'Varaždinske Toplice', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'prelog': {'grad': 'Prelog', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ludbreg': {'grad': 'Ludbreg', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novska': {'grad': 'Novska', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'kutina': {'grad': 'Kutina', 'postaja': 'Kutina', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'popovaca': {'grad': 'Popovača', 'postaja': 'Popovača', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ivanic_grad': {'grad': 'Ivanić-Grad', 'postaja': 'Ivanić-Grad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'dugo_selo': {'grad': 'Dugo Selo', 'postaja': 'Rugvica', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrbovec': {'grad': 'Vrbovec', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'krizevci': {'grad': 'Križevci', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'daruvar': {'grad': 'Daruvar', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pakrac': {'grad': 'Pakrac', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lipik': {'grad': 'Lipik', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nova_gradiska': {'grad': 'Nova Gradiška', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zupanja': {'grad': 'Županja', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nasice': {'grad': 'Našice', 'postaja': 'Đakovo', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'valpovo': {'grad': 'Valpovo', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'belisce': {'grad': 'Belišće', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'donji_miholjac': {'grad': 'Donji Miholjac', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'orahovica': {'grad': 'Orahovica', 'postaja': 'Đakovo', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slatina': {'grad': 'Slatina', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'virovitica': {'grad': 'Virovitica', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pleternica': {'grad': 'Pleternica', 'postaja': 'Nova Gradiška', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ilok': {'grad': 'Ilok', 'postaja': 'Županja', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'beli_manastir': {'grad': 'Beli Manastir', 'postaja': 'Beli Manastir', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // Lika, Gorski Kotar & Unutrašnjost
    'otocac': {'grad': 'Otočac', 'postaja': 'Otočac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'gospic': {'grad': 'Gospić', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'slunj': {'grad': 'Slunj', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'plitvice': {'grad': 'Plitvička Jezera', 'postaja': 'Karlovac / Otočac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ogulin': {'grad': 'Ogulin', 'postaja': 'Ogulin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'delnice': {'grad': 'Delnice', 'postaja': 'Delnice', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'fuzine': {'grad': 'Fužine', 'postaja': 'Vrata / Fužine', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrbovsko': {'grad': 'Vrbovsko', 'postaja': 'Vrbovsko', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ravna_gora': {'grad': 'Ravna Gora', 'postaja': 'Ravna Gora', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'knin': {'grad': 'Knin', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'drnis': {'grad': 'Drniš', 'postaja': 'Šibenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'imotski': {'grad': 'Imotski', 'postaja': 'Šestanovac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrgorac': {'grad': 'Vrgorac', 'postaja': 'Vrgorac', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'sinj': {'grad': 'Sinj', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'trilj': {'grad': 'Trilj', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrlika': {'grad': 'Vrlika', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ozalj': {'grad': 'Ozalj', 'postaja': 'Karlovac', 'koncesionar': 'HAC', 'drzava': 'HR'},

    // ==============================================================
    // --- DODATNIH 50+ GRADOVA, OPĆINA I NASELJA U HRVATSKOJ ---
    // ==============================================================
    'biograd_na_moru': {'grad': 'Biograd na Moru', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'cazma': {'grad': 'Čazma', 'postaja': 'Ivanić-Grad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'daruvarski_brestovac': {'grad': 'Daruvarski Brestovac', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'delnice_centar': {'grad': 'Delnice Centar', 'postaja': 'Delnice', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'donja_stubica': {'grad': 'Donja Stubica', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'dugopolje_centar': {'grad': 'Dugopolje Centar', 'postaja': 'Dugopolje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'Đurđevac': {'grad': 'Đurđevac', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'grubisno_polje': {'grad': 'Grubišno Polje', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'hlebine': {'grad': 'Hlebine', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'hrvatska_kostajnica': {'grad': 'Hrvatska Kostajnica', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'hum_na_sutli': {'grad': 'Hum na Sutli', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'ivanec': {'grad': 'Ivanec', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'klanjec': {'grad': 'Klanjec', 'postaja': 'Zaprešić', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'koprivnicki_ivanec': {'grad': 'Koprivnički Ivanec', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'korčula_grad': {'grad': 'Korčula Grad', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'krapinske_toplice': {'grad': 'Krapinske Toplice', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'križ': {'grad': 'Križ', 'postaja': 'Ivanić-Grad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'labin_centar': {'grad': 'Labin Centar', 'postaja': 'Pula', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'lepcangrad': {'grad': 'Lepoglava', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lipovljani': {'grad': 'Lipovljani', 'postaja': 'Novska', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'lovinac': {'grad': 'Lovinac', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'ludbreg_centar': {'grad': 'Ludbreg Centar', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'makarska_rivijera': {'grad': 'Makarska Rivijera', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'mali_stón': {'grad': 'Mali Ston', 'postaja': 'Karamatići', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'matulji': {'grad': 'Matulji', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'mihovljan': {'grad': 'Mihovljan', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'mursko_sredisce': {'grad': 'Mursko Središće', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'nedelisce': {'grad': 'Nedelišće', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'novi_marof': {'grad': 'Novi Marof', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'obrovac': {'grad': 'Obrovac', 'postaja': 'Posedarje', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'opatija_centar': {'grad': 'Opatija Centar', 'postaja': 'Matulji', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'otok_cres': {'grad': 'Otok Cres', 'postaja': 'Brestova / Valbiska', 'koncesionar': 'Trajekt', 'drzava': 'HR'},
    'otok_korcula': {'grad': 'Otok Korčula', 'postaja': 'Ploče / Orebić', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'otok_mljet': {'grad': 'Otok Mljet', 'postaja': 'Karamatići', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'otok_rab': {'grad': 'Otok Rab', 'postaja': 'Stinica', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'otok_vir': {'grad': 'Otok Vir', 'postaja': 'Zadar zapad', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'perusic': {'grad': 'Perušić', 'postaja': 'Gospić', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'petrinja': {'grad': 'Petrinja', 'postaja': 'Lekenik', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pićan': {'grad': 'Pićan', 'postaja': 'Pazin', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'podgora_centar': {'grad': 'Podgora Centar', 'postaja': 'Zagvozd', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'pregrada': {'grad': 'Pregrada', 'postaja': 'Krapina', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'pučišća': {'grad': 'Pučišća (Brač)', 'postaja': 'Split (Dugopolje)', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'rab_grad': {'grad': 'Rab Grad', 'postaja': 'Stinica', 'koncesionar': 'HAC / Trajekt', 'drzava': 'HR'},
    'rovinj_centar': {'grad': 'Rovinj Centar', 'postaja': 'Kanfanar', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'senj_centar': {'grad': 'Senj Centar', 'postaja': 'Žuta Lokva', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'stubicke_toplice_centar': {'grad': 'Stubičke Toplice Centar', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'svet_ivan_zelina': {'grad': 'Sveti Ivan Zelina', 'postaja': 'Popovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'tvrtkovac': {'grad': 'Trnovec Bartolovečki', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'umag_centar': {'grad': 'Umag Centar', 'postaja': 'Umag', 'koncesionar': 'Bina-Istra', 'drzava': 'HR'},
    'valpovo_centar': {'grad': 'Valpovo Centar', 'postaja': 'Osijek', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'varazdin_centar': {'grad': 'Varaždin Centar', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'velika_ludina': {'grad': 'Velika Ludina', 'postaja': 'Popovača', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vidovec': {'grad': 'Vidovec', 'postaja': 'Varaždin', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'vrbovec_centar': {'grad': 'Vrbovec Centar', 'postaja': 'Vrbovec', 'koncesionar': 'HAC', 'drzava': 'HR'},
    'zabok_centar': {'grad': 'Zabok Centar', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},
    'zlatar': {'grad': 'Zlatar', 'postaja': 'Zabok', 'koncesionar': 'AZM', 'drzava': 'HR'},

    // ==========================================
    // --- SLOVENIJA (DARS / Vinjeta & DarsGo) ---
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
    'gruškovje': {'grad': 'Gruškovje (GP)', 'postaja': 'Gruškovje', 'koncesionar': 'DARS', 'drzava': 'SI'},

    // ==========================================
    // --- BOSNA I HERCEGOVINA (FBiH / RS) ------
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
  };

  /// 2. Glavne dionice cestarina s točnim cijenama po kategorijama vozila (€)
  static final List<Map<String, dynamic>> dioniceCestarina = [
    // HAC (Hrvatska - A1 Autocesta Dalmatina)
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
      'id': 'blato_na_cetini_zadar_istok',
      'ulaz': 'Blato na Cetini',
      'izlaz': 'Zadar istok',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 11.20,
        'Mini bus <20': 17.50,
        'Midi bus 35': 25.80,
        'Veliki autobus 50': 39.10,
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
      'id': 'dugopolje_sibenik',
      'ulaz': 'Dugopolje',
      'izlaz': 'Šibenik',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 4.20,
        'Mini bus <20': 6.80,
        'Midi bus 35': 9.90,
        'Veliki autobus 50': 15.10,
      }
    },
    {
      'id': 'lucko_karamatići',
      'ulaz': 'Lučko',
      'izlaz': 'Karamatići',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 30.10,
        'Mini bus <20': 47.00,
        'Midi bus 35': 69.10,
        'Veliki autobus 50': 105.00,
      }
    },
    {
      'id': 'dugopolje_karamatići',
      'ulaz': 'Dugopolje',
      'izlaz': 'Karamatići',
      'koncesionar': 'HAC (A1)',
      'cijene': {
        'Kombi 8+1': 6.10,
        'Mini bus <20': 9.40,
        'Midi bus 35': 13.90,
        'Veliki autobus 50': 21.30,
      }
    },

    // HAC (Hrvatska - A3 Bregana - Zagreb - Lipovac)
    {
      'id': 'lucko_zupanja',
      'ulaz': 'Lučko',
      'izlaz': 'Županja',
      'koncesionar': 'HAC (A3)',
      'cijene': {
        'Kombi 8+1': 16.10,
        'Mini bus <20': 25.20,
        'Midi bus 35': 37.00,
        'Veliki autobus 50': 56.10,
      }
    },
    {
      'id': 'lucko_osijek',
      'ulaz': 'Lučko',
      'izlaz': 'Osijek',
      'koncesionar': 'HAC (A3/A5)',
      'cijene': {
        'Kombi 8+1': 17.50,
        'Mini bus <20': 27.40,
        'Midi bus 35': 40.20,
        'Veliki autobus 50': 61.00,
      }
    },
    {
      'id': 'lucko_slavonski_brod',
      'ulaz': 'Lučko',
      'izlaz': 'Slavonski Brod zapad',
      'koncesionar': 'HAC (A3)',
      'cijene': {
        'Kombi 8+1': 11.80,
        'Mini bus <20': 18.50,
        'Midi bus 35': 27.20,
        'Veliki autobus 50': 41.30,
      }
    },

    // HAC (Hrvatska - A6 Rijeka - Zagreb)
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

    // HAC (Hrvatska - A4 Zagreb - Goričan)
    {
      'id': 'lucko_varazdin',
      'ulaz': 'Lučko',
      'izlaz': 'Varaždin',
      'koncesionar': 'HAC (A4)',
      'cijene': {
        'Kombi 8+1': 5.20,
        'Mini bus <20': 8.10,
        'Midi bus 35': 11.90,
        'Veliki autobus 50': 18.10,
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

    // Bina-Istra (Istarski Ipsilon - A8/A9)
    {
      'id': 'pula_kanfanar',
      'ulaz': 'Pula',
      'izlaz': 'Kanfanar',
      'koncesionar': 'Bina-Istra',
      'cijene': {
        'Kombi 8+1': 2.30,
        'Mini bus <20': 3.80,
        'Midi bus 35': 5.60,
        'Veliki autobus 50': 8.50,
      }
    },
    {
      'id': 'pula_umag',
      'ulaz': 'Pula',
      'izlaz': 'Umag',
      'koncesionar': 'Bina-Istra',
      'cijene': {
        'Kombi 8+1': 6.80,
        'Mini bus <20': 11.20,
        'Midi bus 35': 16.50,
        'Veliki autobus 50': 25.10,
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
    {
      'id': 'gruskovje_maribor',
      'ulaz': 'Gruškovje',
      'izlaz': 'Maribor',
      'koncesionar': 'DARS (SI)',
      'cijene': {
        'Kombi 8+1': 16.00,
        'Mini bus <20': 18.00,
        'Midi bus 35': 28.00,
        'Veliki autobus 50': 40.00,
      }
    },

    // Autoceste FBiH & Autoputevi RS (BiH)
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
    {
      'id': 'gradiska_banja_luka',
      'ulaz': 'Gradiška',
      'izlaz': 'Jakupovci',
      'koncesionar': 'Autoputevi RS',
      'cijene': {
        'Kombi 8+1': 2.50,
        'Mini bus <20': 4.50,
        'Midi bus 35': 7.00,
        'Veliki autobus 50': 10.50,
      }
    },
  ];
}
