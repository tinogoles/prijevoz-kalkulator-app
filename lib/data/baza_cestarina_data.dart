// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. MAPIRANJE SVIH GRADOVA NA NJIHOV NAJBLIŽI ULAZ S AUTOCESTE
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
      'Sveti Ivan Zelina', 'Križevci', 'Koprivnica', 'Bjelovar', 'Virovitica', 'Čazma', 'Garešnica', 'Kutina', 'Novska', 'Sisak', 'Petrinja'
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
      'Gacko', 'Nevesinje', 'Bileća', 'Ravno', 'Berkovići', 'Međugorje'
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
  // 2. MATRICA TOČNIH SLUŽBENIH DIONICA IZMEĐU ČVORIŠTA
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveDionice() {
    final Map<String, Map<String, dynamic>> dionice = {};

    // Pomoćna funkcija za obostrano upisivanje (A->B i B->A) kako bi pretraga uvijek našla dionicu bez obzira na smjer
    void dodajDionicu(String cvor1, String cvor2, String koncesionar, String naziv, double c1, double c2, double c3, double c4) {
      final data = {
        'koncesionar': koncesionar,
        'naziv': naziv,
        'I. Skupina (Osobna vozila / motocikli)': c1,
        'II. Skupina (Vozila do 3.5t / kombi)': c2,
        'III. Skupina (Vozila preko 3.5t / midi bus)': c3,
        'IV. Skupina (Vozila preko 3.5t / veliki autobus)': c4,
      };
      dionice['${cvor1}_$cvor2'] = data;
      dionice['${cvor2}_$cvor1'] = data;
    }

    // --- SLUŽBENE RELACIJE ---
    dodajDionicu('lucko', 'bosiljevo', 'HAC', 'A1: Lučko - Bosiljevo', 8.50, 13.50, 20.00, 33.50);
    dodajDionicu('bosiljevo', 'dugopolje', 'HAC', 'A1: Bosiljevo - Split (Dugopolje)', 15.50, 25.00, 37.50, 62.50);
    dodajDionicu('lucko', 'dugopolje', 'HAC', 'A1: Lučko - Dugopolje', 24.00, 38.50, 57.50, 96.00);
    dodajDionicu('dugopolje', 'ploce', 'HAC', 'A1: Dugopolje - Ploče', 7.80, 12.50, 18.50, 31.00);
    dodajDionicu('dugopolje', 'zadar_istok', 'HAC', 'A1: Dugopolje - Zadar istok', 8.78, 14.20, 21.00, 35.00);
    dodajDionicu('dugopolje', 'sibenik', 'HAC', 'A1: Dugopolje - Šibenik', 4.70, 8.40, 12.50, 20.50);
    dodajDionicu('bosiljevo', 'grobnik', 'HAC', 'A6: Bosiljevo - Rijeka (Grobnik)', 9.20, 14.80, 22.00, 37.00);
    dodajDionicu('lucko', 'grobnik', 'HAC', 'A1/A6: Lučko - Rijeka (Grobnik)', 9.90, 15.90, 23.50, 39.50);
    dodajDionicu('lucko', 'varazdin', 'HAC', 'A4: Zagreb - Varaždin', 6.50, 10.50, 16.00, 27.00);
    dodajDionicu('lucko', 'slavonski_brod_zapad', 'HAC', 'A3: Zagreb - Slavonski Brod', 13.00, 21.00, 31.50, 53.00);
    dodajDionicu('lucko', 'osijek', 'HAC', 'A3/A5: Zagreb - Osijek', 17.50, 28.00, 42.00, 70.00);
    dodajDionicu('lucko', 'karlovac', 'HAC', 'A1: Lučko - Karlovac', 2.20, 3.50, 5.50, 9.00);
    
    // Dodatne unutarnje i regionalne relacije da pokrijemo sve kombinacije
    dodajDionicu('zapresic', 'krapina', 'AZM (A2)', 'A2: Zaprešić - Krapina', 2.50, 4.00, 10.00, 15.40);
    dodajDionicu('gruskovje', 'maribor', 'DARS', 'A4: Gruškovje - Maribor', 4.50, 7.90, 12.00, 19.00);
    dodajDionicu('obrezje', 'ljubljana_jug', 'DARS', 'A2: Obrežje - Ljubljana', 6.20, 11.10, 17.50, 28.00);
    dodajDionicu('bijaca', 'sarajevo_sjever', 'Autoceste FBiH', 'A1: Bijača - Sarajevo', 7.50, 13.00, 19.50, 32.00);
    dodajDionicu('smokovac', 'matesevo', 'Monteput', 'A1: Smokovac - Mateševo', 3.50, 6.00, 9.50, 15.00);
    dodajDionicu('sozina', 'podgorica', 'Monteput', 'Tunel Sozina', 2.50, 5.00, 10.00, 18.00);

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
