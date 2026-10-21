// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. PROŠIRENO OPĆINSKO MAPIRANJE: Obuhvat svih naselja i regija
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveGradove() {
    final Map<String, Map<String, dynamic>> mapa = {};

    void mapirajNaselja(String drzava, String cvorUlaza, List<String> naselja) {
      for (var n in naselja) {
        String kljuc = _normalizirajKljuc(n);
        mapa[kljuc] = {
          'naziv': n,
          'drzava': drzava,
          'najblizi_ulaz': cvorUlaza,
          'is_multi_highway': false,
        };
      }
    }

    // --- SLAVONIJA I ISTOČNI KORIDOR (Uključujući Borovo Naselje i Vukovar) ---
    mapirajNaselja('HR', 'osijek', [
      'Osijek', 'Borovo Naselje', 'Vukovar', 'Vinkovci', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 
      'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Županja', 'Ilok', 'Otok', 
      'Gradište', 'Cerna', 'Drenovci', 'Bošnjaci', 'Vrbanja', 'Trpinja', 'Borovo', 'Markušica', 
      'Nijemci', 'Nuštar', 'Stari Jankovci', 'Tompojevci', 'Bogdanovci', 'Lovas'
    ]);

    // --- SJEVEROZADNJA HRVATSKA / ZAGORJE (Ivanec, Klanjec, Kumrovec...) ---
    mapirajNaselja('HR', 'zapresic', [
      'Zaprešić', 'Klanjec', 'Kumrovec', 'Desinić', 'Veliko Trgovišće', 'Tuhelj', 'Kraljevec na Sutli', 'Bistra', 'Pušća'
    ]);
    
    mapirajNaselja('HR', 'krapina', [
      'Krapina', 'Ivanec', 'Zabok', 'Oroslavje', 'Donja Stubica', 'Marija Bistrica', 'Bedekovčina', 
      'Sveti Križ Začretje', 'Pregrada', 'Hum na Sutli', 'Đurmanec', 'Zlatar', 'Zlatar Bistrica', 
      'Lobor', 'Mihovljan', 'Radoboj', 'Gornja Stubica', 'Lepoglava'
    ]);

    // --- LIKA I GORSKI KOTAR (Josipdol, Platak, Senj...) ---
    mapirajNaselja('HR', 'josipdol', [
      'Josipdol', 'Plaški', 'Oštarije'
    ]);

    mapirajNaselja('HR', 'grobnik', [
      'Rijeka', 'Platak', 'Opatija', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice', 'Fužine', 
      'Mrkopalj', 'Ravna Gora', 'Skrad', 'Vrbovsko', 'Brod Moravice', 'Lokve'
    ]);

    mapirajNaselja('HR', 'zuta_lokva', [
      'Senj', 'Baške Oštarije', 'Otočac', 'Brinje', 'Perušić'
    ]);

    // --- ISTRA (Pazin i okolica) ---
    mapirajNaselja('HR', 'pazin', [
      'Pazin', 'Žminj', 'Kanfanar', 'Barban', 'Svetvinčenat', 'Karojba', 'Tinjan', 'Gračišće', 'Pićan'
    ]);

    mapirajNaselja('HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Medulin', 'Fažana',
      'Vrsar', 'Funtana', 'Tar', 'Novigrad', 'Motovun', 'Grožnjan', 'Bale', 'Ližnjan', 'Marčana', 'Višnjan', 'Vižinada'
    ]);

    // --- DALMACIJA ---
    mapirajNaselja('HR', 'dugopolje', [
      'Split', 'Solin', 'Kaštela', 'Trogir', 'Omiš', 'Sinj', 'Muć', 'Klis', 'Dugopolje', 'Podstrana',
      'Supetar', 'Hvar', 'Vis', 'Komiža', 'Milna', 'Sutivan', 'Bol', 'Nerežišća', 'Postira', 'Pučišća',
      'Selca', 'Jelsa', 'Sućuraj', 'Stari Grad', 'Otok', 'Dicmo', 'Hrvace', 'Vrlika', 'Marina', 'Seget',
      'Okrug', 'Sumpetar', 'Dugi Rat', 'Duće', 'Tugare', 'Gata', 'Kostanje', 'Vrboska', 'Sveta Nedjelja'
    ]);

    mapirajNaselja('HR', 'sibenik', [
      'Šibenik', 'Vodice', 'Skradin', 'Drniš', 'Knin', 'Primošten', 'Rogoznica', 'Murter', 'Tisno', 'Pirovac',
      'Tribunj', 'Kistanje', 'Ružić', 'Promina', 'Biskupija', 'Civljane', 'Unešić', 'Zaton', 'Betina', 'Jezera'
    ]);

    mapirajNaselja('HR', 'zadar_istok', [
      'Zadar', 'Biograd na Moru', 'Benkovac', 'Obrovac', 'Pag', 'Nin', 'Pakoštane', 'Sukošan', 'Bibinje', 'Posedarje',
      'Polača', 'Poličnik', 'Stankovci', 'Sv. Filip i Jakov', 'Škabrnja', 'Vrsi', 'Zemunik Donji', 'Gračac', 'Novigrad',
      'Vir', 'Kali', 'Preko', 'Ugljan', 'Tkon', 'Sali', 'Starigrad', 'Jasenice', 'Brbinj', 'Novalja'
    ]);

    mapirajNaselja('HR', 'sestanovac', [
      'Makarska', 'Baška Voda', 'Brela', 'Tučepi', 'Podgora', 'Gradac', 'Imotski', 'Cista Provo', 'Zagvozd', 
      'Runovići', 'Zmijavci', 'Proložac', 'Lokvičići', 'Zadvarje', 'Drvenik', 'Brist', 'Šestanovac'
    ]);

    mapirajNaselja('HR', 'ploce', [
      'Ploče', 'Metković', 'Opuzen', 'Vrgorac', 'Dubrovnik', 'Korčula', 'Blato', 'Vela Luka', 'Orebić', 
      'Ston', 'Kula Norinska', 'Zaostrog', 'Konavle', 'Župa Dubrovačka', 'Dubrovačko Primorje', 'Janina', 'Lumbarda', 'Mljet', 'Lastovo', 'Trpanj'
    ]);

    mapirajNaselja('HR', 'gospic', [
      'Gospić', 'Udbina', 'Plitvička Jezera', 'Korenica', 'Vrhovine', 'Donji Lapac'
    ]);

    mapirajNaselja('HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo', 'Ivanić-Grad', 'Vrbovec',
      'Sveti Ivan Zelina', 'Križevci', 'Koprivnica', 'Bjelovar', 'Virovitica', 'Čazma', 'Garešnica', 'Kutina', 'Novska', 'Sisak', 'Petrinja', 'Glina', 'Hrvatska Kostajnica', 'Topusko', 'Dvor', 'Sunja', 'Lekenik', 'Popovača'
    ]);

    mapirajNaselja('HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo',
      'Rakovica', 'Cetingrad', 'Barilović', 'Generalski Stol', 'Kamanje', 'Ribnik'
    ]);

    mapirajNaselja('HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac',
      'Lipik', 'Kutjevo', 'Pleternica', 'Brestovac', 'Rešetari', 'Okučani', 'Stara Gradiška', 'Davor', 'Bukovlje', 'Cernik', 'Gornji Bogićevci', 'Dragalić'
    ]);

    // --- SLOVENIJA ---
    mapirajNaselja('SI', 'ljubljana_jug', [
      'Ljubljana', 'Kranj', 'Domžale', 'Kamnik', 'Škofja Loka', 'Vrhnika', 'Grosuplje', 'Kočevje', 'Ribnica', 'Bled', 'Bohinj', 'Postojna', 'Koper', 'Izola', 'Piran',
      'Logatec', 'Idrija', 'Tolmin', 'Bovec', 'Kobarid', 'Nova Gorica', 'Ajdovščina', 'Sežana', 'Divača', 'Ilirska Bistrica', 'Pivka', 'Cerknica', 'Litija', 'Zagorje ob Savi', 'Trbovlje', 'Hrastnik', 'Laško', 'Radeče', 'Medvode', 'Mengeš', 'Radovljica', 'Jesenice', 'Kranjska Gora'
    ]);

    mapirajNaselja('SI', 'maribor_jug', [
      'Maribor', 'Celje', 'Ptuj', 'Velenje', 'Slovenska Bistrica', 'Murska Sobota', 'Lendava', 'Rogaška Slatina', 'Žalec', 'Slovenske Konjice',
      'Ravne na Koroškem', 'Slovenj Gradec', 'Dravograd', 'Radlje ob Dravi', 'Ruše', 'Lenart', 'Gornja Radgona', 'Ljutomer', 'Ormož', 'Kidričevo', 'Šentjur', 'Mozirje', 'Vransko', 'Prevalje', 'Mežica', 'Črna na Koroškem'
    ]);

    mapirajNaselja('SI', 'obrezje', [
      'Brežice', 'Krško', 'Sevnica', 'Novo Mesto', 'Trebnje', 'Črnomelj', 'Metlika', 'Šentjernej',
      'Žužemberk', 'Ivančna Gorica', 'Šmarje pri Jelšah', 'Podčetrtek', 'Kozje', 'Bistrica ob Sotli'
    ]);

    // --- BOSNA I HERCEGOVINA ---
    mapirajNaselja('BIH', 'sarajevo_sjever', [
      'Sarajevo', 'Visoko', 'Kakanj', 'Ilijaš', 'Vogošća', 'Hadžići', 'Konjic', 'Jablanica', 'Breza', 'Vareš', 'Pale', 'Sokolac',
      'Olovo', 'Kladanj', 'Han Pijesak', 'Foča', 'Goražde', 'Čajniče', 'Rudo', 'Trnovo', 'Kiseljak', 'Fojnica', 'Kreševo', 'Busovača'
    ]);

    mapirajNaselja('BIH', 'zenica_jug', [
      'Zenica', 'Travnik', 'Vitez', 'Novi Travnik', 'Novi Šeher', 'Žepče', 'Maglaj', 'Tešanj', 'Zavidovići', 'Bugojno', 'Jajce',
      'Donji Vakuf', 'Gornji Vakuf-Uskoplje', 'Prozor-Rama', 'Livno', 'Tomislavgrad', 'Kupres', 'Glamoč', 'Bosansko Grahovo', 'Drvar', 'Ključ', 'Sanski Most', 'Bosanska Krupa', 'Cazin', 'Velika Kladuša', 'Bihać', 'Tuzla', 'Lukavac', 'Živinice', 'Banovići', 'Kalesija', 'Srebrenica', 'Bratunac', 'Zvornik', 'Šekovići', 'Vlasenica', 'Milići'
    ]);

    mapirajNaselja('BIH', 'bijaca', [
      'Mostar', 'Ljubuški', 'Čapljina', 'Široki Brijeg', 'Grude', 'Posušje', 'Čitluk', 'Neum', 'Stolac', 'Trebinje',
      'Gacko', 'Nevesinje', 'Bileća', 'Ravno', 'Berkovići', 'Međugorje'
    ]);

    mapirajNaselja('BIH', 'mahovljani', [
      'Banja Luka', 'Laktaši', 'Gradiška', 'Prijedor', 'Prnjavor', 'Derventa', 'Doboj', 'Novi Grad', 'Kozarska Dubica', 'Bijeljina',
      'Modriča', 'Bosanski Šamac', 'Orašje', 'Brčko', 'Gradačac', 'Srebrenik', 'Pelagićevo', 'Donji Žabar', 'Vukosavlje', 'Petrova', 'Čelinac', 'Kotor Varoš', 'Kneževo', 'Mrkonjić Grad', 'Šipovo', 'Ribnik', 'Teslić'
    ]);

    // --- CRNA GORA ---
    mapirajNaselja('CG', 'smokovac', [
      'Podgorica', 'Danilovgrad', 'Tuzi', 'Cetinje', 'Nikšić', 'Spuž', 'Šavnik', 'Žabljak', 'Plužine', 'Gusinje'
    ]);

    mapirajNaselja('CG', 'matesevo', [
      'Kolašin', 'Mojkovac', 'Bijelo Polje', 'Berane', 'Rožaje', 'Plav', 'Andrijevica', 'Pljevlja', 'Petnjica'
    ]);

    mapirajNaselja('CG', 'sozina', [
      'Bar', 'Ulcinj', 'Budva', 'Kotor', 'Tivat', 'Herceg Novi', 'Petrovac', 'Sutomore', 'Perast', 'Risan', 'Bečići', 'Prčanj', 'Dobrota', 'Igalo'
    ]);

    return mapa;
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
  // 2. MATRICA ČVORIŠTA SA CIJENAMA ZA SVE 4 KATEGORIJE
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

    // Dodani čvorovi za Josipdol, Pazin, Zaprešić itd.
    dodaj('lucko', 'josipdol', 'HAC', 'A1: Lučko - Josipdol', 6.50, 10.50, 15.50, 26.00);
    dodaj('lucko', 'zuta_lokva', 'HAC', 'A1: Lučko - Žuta Lokva', 9.50, 15.00, 22.50, 37.50);
    dodaj('lucko', 'grobnik', 'HAC / ARZ', 'A1/A6: Lučko - Rijeka (Grobnik)', 9.90, 15.90, 23.50, 39.50);
    dodaj('lucko', 'dugopolje', 'HAC', 'A1: Lučko - Dugopolje', 24.00, 38.50, 57.50, 96.00);
    dodaj('lucko', 'osijek', 'HAC', 'A3/A5: Zagreb - Osijek', 17.50, 28.00, 42.00, 70.00);
    dodaj('lucko', 'zapresic', 'AZM (A2)', 'A2: Zagreb - Zaprešić', 1.50, 2.50, 5.00, 8.00);
    dodaj('lucko', 'krapina', 'AZM (A2)', 'A2: Zagreb - Krapina', 2.50, 4.00, 10.00, 15.40);

    // Unakrsni spojevi iz Splita prema novim čvorovima
    dodaj('dugopolje', 'josipdol', 'HAC', 'A1: Dugopolje - Josipdol', 17.50, 28.00, 42.00, 70.00);
    dodaj('dugopolje', 'zuta_lokva', 'HAC', 'A1: Dugopolje - Žuta Lokva', 14.50, 23.00, 34.50, 58.00);
    dodaj('dugopolje', 'grobnik', 'HAC', 'A1: Dugopolje - Grobnik', 30.00, 48.00, 72.00, 120.00);
    dodaj('dugopolje', 'osijek', 'HAC', 'A1/A3/A5: Dugopolje - Osijek', 41.50, 66.50, 99.50, 166.00);
    dodaj('dugopolje', 'zapresic', 'A1/A2', 'Split - Zaprešić', 25.50, 41.00, 62.50, 104.00);
    dodaj('dugopolje', 'krapina', 'A1/A2', 'Split - Krapina', 26.50, 42.50, 67.50, 111.40);
    dodaj('dugopolje', 'pazin', 'A1/A8', 'Split - Pazin', 33.00, 53.00, 80.00, 132.00);

    return dionice;
  }

  // =========================================================================
  // 3. CLOUD SYNC
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
