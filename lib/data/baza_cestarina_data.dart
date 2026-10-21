// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. STVARNI GRADOVI, OPĆINE I OTOČNA NASELJA (HR, SI, BIH, CG)
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveGradove() {
    final Map<String, Map<String, dynamic>> mapa = {};

    // --- HRVATSKA ---
    _dodajSkupinu(mapa, 'HR', 'dugopolje', [
      'Split', 'Solin', 'Kaštela', 'Trogir', 'Omiš', 'Sinj', 'Muć', 'Klis', 'Dugopolje', 'Podstrana',
      'Supetar', 'Hvar', 'Vis', 'Komiža', 'Milna', 'Sutivan', 'Bol', 'Nerežišća', 'Postira', 'Pučišća',
      'Selca', 'Jelsa', 'Sućuraj', 'Stari Grad', 'Otok', 'Dicmo', 'Hrvace', 'Vrlika', 'Marina', 'Seget',
      'Okrug', 'Sumpetar', 'Dugi Rat', 'Duće', 'Tugare', 'Gata', 'Kostanje', 'Šestanovac',
      'Vrboska', 'Sveta Nedjelja', 'Brbinj', 'Krk', 'Cres', 'Mali Lošinj', 'Veli Lošinj', 'Rab', 'Pag', 'Novalja'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sibenik', [
      'Šibenik', 'Vodice', 'Skradin', 'Drniš', 'Knin', 'Primošten', 'Rogoznica', 'Murter', 'Tisno', 'Pirovac',
      'Tribunj', 'Kistanje', 'Ružić', 'Promina', 'Biskupija', 'Civljane', 'Unešić', 'Zaton', 'Betina', 'Jezera'
    ]);
    _dodajSkupinu(mapa, 'HR', 'zadar_istok', [
      'Zadar', 'Biograd na Moru', 'Benkovac', 'Obrovac', 'Pag', 'Nin', 'Pakoštane', 'Sukošan', 'Bibinje', 'Posedarje',
      'Polača', 'Poličnik', 'Stankovci', 'Sv. Filip i Jakov', 'Škabrnja', 'Vrsi', 'Zemunik Donji', 'Gračac', 'Novigrad',
      'Vir', 'Kali', 'Preko', 'Ugljan', 'Tkon', 'Sali', 'Starigrad', 'Jasenhice'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sestanovac', [
      'Makarska', 'Baška Voda', 'Brela', 'Tučepi', 'Podgora', 'Gradac', 'Imotski', 'Cista Provo', 'Zagvozd', 'Runovići', 'Zmijavci',
      'Proložac', 'Lokvičići', 'Zadvarje', 'Drvenik', 'Brist'
    ]);
    _dodajSkupinu(mapa, 'HR', 'ploce', [
      'Ploče', 'Metković', 'Opuzen', 'Vrgorac', 'Dubrovnik', 'Korčula', 'Blato', 'Vela Luka', 'Orebić', 'Ston', 'Kula Norinska', 'Zaostrog'
    ]);
    _dodajSkupinu(mapa, 'HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo', 'Ivanić-Grad', 'Zaprešić', 'Vrbovec',
      'Sveti Ivan Zelina', 'Križevci', 'Koprivnica', 'Bjelovar', 'Virovitica', 'Čazma', 'Garešnica', 'Kutina', 'Novska'
    ]);
    _dodajSkupinu(mapa, 'HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo',
      'Rakovica', 'Cetingrad', 'Josipdol', 'Tounj', 'Barilović', 'Plaški'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'zapresic', 'zabok', 'lucko', [
      'Zabok', 'Krapina', 'Oroslavje', 'Donja Stubica', 'Marija Bistrica', 'Bedekovčina', 'Sveti Križ Začretje',
      'Pregrada', 'Hum na Sutli', 'Desinić', 'Kumrovec', 'Klanjec', 'Veliko Trgovišće', 'Tuhelj', 'Đurmanec', 'Zlatar', 'Zlatar Bistrica'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'varazdin', 'sveti_helena', 'lucko', [
      'Varaždin', 'Čakovec', 'Novi Marof', 'Ludbreg', 'Prelog', 'Mursko Središće', 'Lepoglava', 'Ivanec',
      'Varaždinske Toplice', 'Nedelišće', 'Goričan', 'Koprivnica', 'Križevci', 'Šenkovec', 'Cestica', 'Bednja'
    ]);
    _dodajSkupinu(mapa, 'HR', 'osijek', [
      'Osijek', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Vukovar', 'Vinkovci',
      'Županja', 'Ilok', 'Otok', 'Gradište', 'Cerna', 'Drenovci', 'Bošnjaci', 'Vrbanja', 'Trpinja', 'Borovo', 'Markušica'
    ]);
    _dodajSkupinu(mapa, 'HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac',
      'Lipik', 'Kutjevo', 'Pleternica', 'Brestovac', 'Rešetari', 'Okučani', 'Stara Gradiška', 'Davor', 'Bukovlje'
    ]);
    _dodajSkupinu(mapa, 'HR', 'grobnik', [
      'Rijeka', 'Opatija', 'Crikvenica', 'Novi Vinodolski', 'Krk', 'Bakar', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice',
      'Fužine', 'Mrkopalj', 'Ravna Gora', 'Skrad', 'Vrbovsko', 'Brod Moravice', 'Baška', 'Malinska', 'Punat', 'Dobrinj', 'Cres', 'Rab', 'Lopar'
    ]);
    _dodajSkupinu(mapa, 'HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Pazin', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Žminj', 'Medulin', 'Fažana',
      'Vrsar', 'Funtana', 'Tar', 'Novigrad', 'Motovun', 'Grožnjan', 'Bale', 'Kanfanar', 'Barban', 'Ližnjan', 'Marčana', 'Svetvinčenat'
    ]);

    // --- SLOVENIJA ---
    _dodajSkupinu(mapa, 'SI', 'ljubljana_jug', [
      'Ljubljana', 'Kranj', 'Domžale', 'Kamnik', 'Škofja Loka', 'Vrhnika', 'Grosuplje', 'Kočevje', 'Ribnica', 'Bled', 'Bohinj', 'Postojna', 'Koper', 'Izola', 'Piran',
      'Logatec', 'Idrija', 'Tolmin', 'Bovec', 'Kobarid', 'Nova Gorica', 'Ajdovščina', 'Sežana', 'Divača', 'Ilirska Bistrica', 'Pivka', 'Cerknica', 'Litija', 'Zagorje ob Savi', 'Trbovlje', 'Hrastnik', 'Laško', 'Radeče'
    ]);
    _dodajSkupinu(mapa, 'SI', 'maribor_jug', [
      'Maribor', 'Celje', 'Ptuj', 'Velenje', 'Slovenska Bistrica', 'Murska Sobota', 'Lendava', 'Rogaška Slatina', 'Žalec', 'Slovenske Konjice',
      'Ravne na Koroškem', 'Slovenj Gradec', 'Dravograd', 'Radlje ob Dravi', 'Ruše', 'Lenart', 'Gornja Radgona', 'Ljutomer', 'Ormož', 'Kidričevo', 'Šentjur', 'Mozirje', 'Vransko'
    ]);
    _dodajSkupinu(mapa, 'SI', 'obrezje', [
      'Brežice', 'Krško', 'Sevnica', 'Novo Mesto', 'Trebnje', 'Črnomelj', 'Metlika', 'Šentjernej',
      'Žužemberk', 'Ivančna Gorica', 'Šmarje pri Jelšah', 'Podčetrtek', 'Kozje', 'Bistrica ob Sotli'
    ]);

    // --- BOSNA I HERCEGOVINA ---
    _dodajSkupinu(mapa, 'BIH', 'sarajevo_sjever', [
      'Sarajevo', 'Visoko', 'Kakanj', 'Ilijaš', 'Vogošća', 'Hadžići', 'Konjic', 'Jablanica', 'Breza', 'Vareš', 'Pale', 'Sokolac',
      'Olovo', 'Kladanj', 'Han Pijesak', 'Foča', 'Goražde', 'Čajniče', 'Rudo', 'Trnovo', 'Kiseljak', 'Fojnica', 'Kreševo', 'Busovača'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'zenica_jug', [
      'Zenica', 'Travnik', 'Vitez', 'Novi Travnik', 'Novi Šeher', 'Žepče', 'Maglaj', 'Tešanj', 'Zavidovići', 'Bugojno', 'Jajce',
      'Donji Vakuf', 'Gornji Vakuf-Uskoplje', 'Prozor-Rama', 'Livno', 'Tomislavgrad', 'Kupres', 'Glamoč', 'Bosansko Grahovo', 'Drvar', 'Ključ', 'Sanski Most', 'Bosanska Krupa', 'Cazin', 'Velika Kladuša', 'Bihać', 'Tuzla', 'Lukavac', 'Živinice', 'Banovići', 'Kalesija', 'Srebrenica', 'Bratunac', 'Zvornik', 'Šekovići', 'Vlasenica', 'Milići'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'bijaca', [
      'Mostar', 'Ljubuški', 'Čapljina', 'Široki Brijeg', 'Grude', 'Posušje', 'Čitluk', 'Neum', 'Stolac', 'Trebinje',
      'Gacko', 'Nevesinje', 'Bileća', 'Ravno', 'Berkovići'
    ]);
    _dodajSkupinu(mapa, 'BIH', 'mahovljani', [
      'Banja Luka', 'Laktaši', 'Gradiška', 'Prijedor', 'Prnjavor', 'Derventa', 'Doboj', 'Novi Grad', 'Kozarska Dubica', 'Bijeljina',
      'Modriča', 'Bosanski Šamac', 'Orašje', 'Brčko', 'Gradačac', 'Srebrenik', 'Pelagićevo', 'Donji Žabar', 'Vukosavlje', 'Petrova', 'Čelinac', 'Kotor Varoš', 'Kneževo', 'Mrkonjić Grad', 'Šipovo', 'Ribnik', 'Teslić'
    ]);

    // --- CRNA GORA ---
    _dodajSkupinu(mapa, 'CG', 'smokovac', [
      'Podgorica', 'Danilovgrad', 'Tuzi', 'Cetinje', 'Nikšić', 'Spuž', 'Šavnik', 'Žabljak',
      'Plužine', 'Gusinje'
    ]);
    _dodajSkupinu(mapa, 'CG', 'matesevo', [
      'Kolašin', 'Mojkovac', 'Bijelo Polje', 'Berane', 'Rožaje', 'Plav', 'Andrijevica', 'Pljevlja',
      'Petnjica'
    ]);
    _dodajSkupinu(mapa, 'CG', 'sozina', [
      'Bar', 'Ulcinj', 'Budva', 'Kotor', 'Tivat', 'Herceg Novi', 'Petrovac', 'Sutomore',
      'Perast', 'Risan', 'Bečići', 'Prčanj', 'Dobrota', 'Igalo'
    ]);

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
  // 2. MATRICA TOČNIH SLUŽBENIH DIONICA (BEZ PROCJENA I FORMULA)
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveDionice() {
    final Map<String, Map<String, dynamic>> dionice = {};

    // Službene tarife i provjerene relacije (II. skupina i ostale)
    dionice['lucko_bosiljevo'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Lučko - Bosiljevo',
      'I. Skupina (Osobna vozila / motocikli)': 8.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 13.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 20.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 33.50,
    };
    dionice['bosiljevo_split'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Bosiljevo - Split (Dugopolje)',
      'I. Skupina (Osobna vozila / motocikli)': 15.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 25.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 37.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 62.50,
    };
    dionice['lucko_dugopolje'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Lučko - Dugopolje',
      'I. Skupina (Osobna vozila / motocikli)': 24.00,
      'II. Skupina (Vozila do 3.5t / kombi)': 38.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 57.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 96.00,
    };
    dionice['dugopolje_ploce'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Dugopolje - Ploče',
      'I. Skupina (Osobna vozila / motocikli)': 7.80,
      'II. Skupina (Vozila do 3.5t / kombi)': 12.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 18.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 31.00,
    };
    dionice['dugopolje_zadar_istok'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Dugopolje - Zadar istok',
      'I. Skupina (Osobna vozila / motocikli)': 8.78,
      'II. Skupina (Vozila do 3.5t / kombi)': 14.20,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 21.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 35.00,
    };
    dionice['dugopolje_sibenik'] = {
      'koncesionar': 'HAC', 'naziv': 'A1: Dugopolje - Šibenik',
      'I. Skupina (Osobna vozila / motocikli)': 4.70,
      'II. Skupina (Vozila do 3.5t / kombi)': 8.40,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 12.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 20.50,
    };
    dionice['bosiljevo_rijeka'] = {
      'koncesionar': 'HAC', 'naziv': 'A6: Bosiljevo - Rijeka (Grobnik)',
      'I. Skupina (Osobna vozila / motocikli)': 9.20,
      'II. Skupina (Vozila do 3.5t / kombi)': 14.80,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 22.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 37.00,
    };
    dionice['lucko_grobnik'] = {
      'koncesionar': 'HAC', 'naziv': 'A1/A6: Lučko - Rijeka (Grobnik)',
      'I. Skupina (Osobna vozila / motocikli)': 9.90,
      'II. Skupina (Vozila do 3.5t / kombi)': 15.90,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 23.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 39.50,
    };
    dionice['lucko_varazdin'] = {
      'koncesionar': 'HAC', 'naziv': 'A4: Zagreb - Varaždin',
      'I. Skupina (Osobna vozila / motocikli)': 6.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 10.50,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 16.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 27.00,
    };
    dionice['lucko_slavonski_brod_zapad'] = {
      'koncesionar': 'HAC', 'naziv': 'A3: Zagreb - Slavonski Brod',
      'I. Skupina (Osobna vozila / motocikli)': 13.00,
      'II. Skupina (Vozila do 3.5t / kombi)': 21.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 31.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 53.00,
    };
    dionice['lucko_osijek'] = {
      'koncesionar': 'HAC', 'naziv': 'A3/A5: Zagreb - Osijek',
      'I. Skupina (Osobna vozila / motocikli)': 17.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 28.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 42.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 70.00,
    };
    dionice['zapresic_krapina'] = {
      'koncesionar': 'AZM (A2)', 'naziv': 'A2: Zaprešić - Krapina',
      'I. Skupina (Osobna vozila / motocikli)': 2.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 4.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 10.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 15.40,
    };
    dionice['gruskovje_maribor'] = {
      'koncesionar': 'DARS', 'naziv': 'A4: Gruškovje - Maribor',
      'I. Skupina (Osobna vozila / motocikli)': 4.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 7.90,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 12.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 19.00,
    };
    dionice['obrezje_ljubljana'] = {
      'koncesionar': 'DARS', 'naziv': 'A2: Obrežje - Ljubljana',
      'I. Skupina (Osobna vozila / motocikli)': 6.20,
      'II. Skupina (Vozila do 3.5t / kombi)': 11.10,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 17.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 28.00,
    };
    dionice['bijaca_sarajevo'] = {
      'koncesionar': 'Autoceste FBiH', 'naziv': 'A1: Bijača - Sarajevo',
      'I. Skupina (Osobna vozila / motocikli)': 7.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 13.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 19.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 32.00,
    };
    dionice['smokovac_matesevo'] = {
      'koncesionar': 'Monteput', 'naziv': 'A1: Smokovac - Mateševo',
      'I. Skupina (Osobna vozila / motocikli)': 3.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 6.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 9.50,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 15.00,
    };
    dionice['tunel_sozina'] = {
      'koncesionar': 'Monteput', 'naziv': 'Tunel Sozina',
      'I. Skupina (Osobna vozila / motocikli)': 2.50,
      'II. Skupina (Vozila do 3.5t / kombi)': 5.00,
      'III. Skupina (Vozila preko 3.5t / midi bus)': 10.00,
      'IV. Skupina (Vozila preko 3.5t / veliki autobus)': 18.00,
    };

    return dionice;
  }

  // =========================================================================
  // 3. PISANJE I REGENERACIJA NA CLOUDU
  // =========================================================================
  static Future<void> osvjeziBazuNaCloudu() async {
    final sveLokacije = generirajSveGradove();
    final sveDionice = generirajSveDionice();

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
