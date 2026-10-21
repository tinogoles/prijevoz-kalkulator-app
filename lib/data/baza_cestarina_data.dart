// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. SVEUKUPNO MAPIRANJE: Svi gradovi, općine i naselja u 4 države
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

    // --- HRVATSKA (Sve županije, gradovi i naselja) ---
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

    mapirajNaselja('HR', 'zuta_lokva', [
      'Senj', 'Baške Oštarije', 'Otočac', 'Brinje', 'Perušić', 'Jasenovac'
    ]);

    mapirajNaselja('HR', 'krizisce', [
      'Novi Vinodolski', 'Crikvenica', 'Bakar', 'Krk', 'Baška', 'Malinska', 'Punat', 'Dobrinj', 'Kraljevica'
    ]);

    mapirajNaselja('HR', 'grobnik', [
      'Rijeka', 'Opatija', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice', 'Fužine', 'Mrkopalj', 
      'Ravna Gora', 'Skrad', 'Vrbovsko', 'Brod Moravice', 'Cres', 'Rab', 'Lopar', 'Mali Lošinj', 'Veli Lošinj', 'Lokve'
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
      'Gospić', 'Udbina', 'Plitvička Jezera', 'Korenica', 'Vrhovine', 'Donji Lapac', 'Josipdol'
    ]);

    mapirajNaselja('HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo', 'Ivanić-Grad', 'Zaprešić', 'Vrbovec',
      'Sveti Ivan Zelina', 'Križevci', 'Koprivnica', 'Bjelovar', 'Virovitica', 'Čazma', 'Garešnica', 'Kutina', 'Novska', 'Sisak', 'Petrinja', 'Glina', 'Hrvatska Kostajnica', 'Topusko', 'Dvor', 'Sunja', 'Lekenik', 'Popovača'
    ]);

    mapirajNaselja('HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo',
      'Rakovica', 'Cetingrad', 'Barilović', 'Plaški', 'Generalski Stol', 'Kamanje', 'Ribnik'
    ]);

    mapirajNaselja('HR', 'osijek', [
      'Osijek', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Vukovar', 'Vinkovci',
      'Županja', 'Ilok', 'Otok', 'Gradište', 'Cerna', 'Drenovci', 'Bošnjaci', 'Vrbanja', 'Trpinja', 'Borovo', 'Markušica', 'Nijemci', 'Nuštar', 'Stari Jankovci', 'Tompojevci', 'Bogdanovci', 'Lovas'
    ]);

    mapirajNaselja('HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac',
      'Lipik', 'Kutjevo', 'Pleternica', 'Brestovac', 'Rešetari', 'Okučani', 'Stara Gradiška', 'Davor', 'Bukovlje', 'Cernik', 'Gornji Bogićevci', 'Dragalić'
    ]);

    mapirajNaselja('HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Pazin', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Žminj', 'Medulin', 'Fažana',
      'Vrsar', 'Funtana', 'Tar', 'Novigrad', 'Motovun', 'Grožnjan', 'Bale', 'Kanfanar', 'Barban', 'Ližnjan', 'Marčana', 'Svetvinčenat', 'Lanišće', 'Karojba', 'Višnjan', 'Vižinada'
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
  // 2. MATRICA ČVORIŠTA S CIJENAMA ZA SVE 4 KATEGORIJE VOZILA
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

    // Službeni cjenici između glavnih čvorišta za sve 4 kategorije
    dodaj('lucko', 'karlovac', 'HAC', 'A1: Lučko - Karlovac', 2.20, 3.50, 5.50, 9.00);
    dodaj('lucko', 'gospic', 'HAC', 'A1: Lučko - Gospić', 11.00, 17.50, 26.00, 44.00);
    dodaj('lucko', 'zuta_lokva', 'HAC', 'A1: Lučko - Žuta Lokva', 9.50, 15.00, 22.50, 37.50);
    dodaj('lucko', 'krizisce', 'HAC / ARZ', 'A1/A6: Lučko - Križišće', 9.90, 15.90, 23.50, 39.50);
    dodaj('lucko', 'grobnik', 'HAC / ARZ', 'A1/A6: Lučko - Rijeka (Grobnik)', 9.90, 15.90, 23.50, 39.50);
    dodaj('lucko', 'dugopolje', 'HAC', 'A1: Lučko - Dugopolje', 24.00, 38.50, 57.50, 96.00);
    dodaj('lucko', 'ploce', 'HAC', 'A1: Lučko - Ploče', 30.00, 48.00, 72.00, 120.00);
    
    dodaj('dugopolje', 'zuta_lokva', 'HAC', 'A1: Dugopolje - Žuta Lokva', 14.50, 23.00, 34.50, 58.00);
    dodaj('dugopolje', 'krizisce', 'HAC', 'A1: Dugopolje - Križišće', 15.00, 24.00, 36.00, 60.00);
    dodaj('dugopolje', 'grobnik', 'HAC', 'A1: Dugopolje - Grobnik', 30.00, 48.00, 72.00, 120.00);
    dodaj('dugopolje', 'sibenik', 'HAC', 'A1: Dugopolje - Šibenik', 4.70, 8.40, 12.50, 20.50);
    dodaj('dugopolje', 'zadar_istok', 'HAC', 'A1: Dugopolje - Zadar istok', 8.78, 14.20, 21.00, 35.00);
    dodaj('dugopolje', 'bijaca', 'HAC', 'A1: Dugopolje - Bijača', 7.80, 12.50, 18.50, 31.00);

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
