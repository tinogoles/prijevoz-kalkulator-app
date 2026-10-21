// lib/data/baza_cestarina_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BazaCestarinaData {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> inicijalizirajCloudBazu() async {
    await osvjeziBazuNaCloudu();
  }

  // =========================================================================
  // 1. POPIS I MAPIRANJE SVIH GRADOVA/OPĆINA NA NAJBLIŽI ULAZ NA AUTOPUT
  // =========================================================================
  static Map<String, Map<String, dynamic>> generirajSveGradove() {
    final Map<String, Map<String, dynamic>> mapa = {};

    // --- HRVATSKA ---
    _dodajSkupinu(mapa, 'HR', 'dugopolje', [
      'Split', 'Solin', 'Kaštela', 'Trogir', 'Omiš', 'Sinj', 'Muć', 'Klis', 'Dugopolje', 'Podstrana',
      'Supetar', 'Hvar', 'Vis', 'Komiža', 'Milna', 'Sutivan', 'Bol', 'Nerežišća', 'Postira', 'Pučišća',
      'Selca', 'Jelsa', 'Sućuraj', 'Stari Grad', 'Otok', 'Dicmo', 'Hrvace', 'Vrlika', 'Marina', 'Seget',
      'Okrug', 'Sumpetar', 'Dugi Rat', 'Duće', 'Tugare', 'Gata', 'Kostanje', 'Vrboska', 'Sveta Nedjelja'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sibenik', [
      'Šibenik', 'Vodice', 'Skradin', 'Drniš', 'Knin', 'Primošten', 'Rogoznica', 'Murter', 'Tisno', 'Pirovac',
      'Tribunj', 'Kistanje', 'Ružić', 'Promina', 'Biskupija', 'Civljane', 'Unešić', 'Zaton', 'Betina', 'Jezera'
    ]);
    _dodajSkupinu(mapa, 'HR', 'zadar_istok', [
      'Zadar', 'Biograd na Moru', 'Benkovac', 'Obrovac', 'Pag', 'Nin', 'Pakoštane', 'Sukošan', 'Bibinje', 'Posedarje',
      'Polača', 'Poličnik', 'Stankovci', 'Sv. Filip i Jakov', 'Škabrnja', 'Vrsi', 'Zemunik Donji', 'Gračac', 'Novigrad',
      'Vir', 'Kali', 'Preko', 'Ugljan', 'Tkon', 'Sali', 'Starigrad', 'Jasenice', 'Brbinj', 'Novalja'
    ]);
    _dodajSkupinu(mapa, 'HR', 'sestanovac', [
      'Makarska', 'Baška Voda', 'Brela', 'Tučepi', 'Podgora', 'Gradac', 'Imotski', 'Cista Provo', 'Zagvozd', 'Runovići', 'Zmijavci',
      'Proložac', 'Lokvičići', 'Zadvarje', 'Drvenik', 'Brist', 'Šestanovac'
    ]);
    _dodajSkupinu(mapa, 'HR', 'ploce', [
      'Ploče', 'Metković', 'Opuzen', 'Vrgorac', 'Dubrovnik', 'Korčula', 'Blato', 'Vela Luka', 'Orebić', 'Ston', 'Kula Norinska', 'Zaostrog', 'Konavle', 'Župa Dubrovačka', 'Dubrovačko Primorje', 'Janina', 'Lumbarda', 'Mljet', 'Lastovo', 'Trpanj'
    ]);
    _dodajSkupinu(mapa, 'HR', 'gospic', [
      'Gospić', 'Otočac', 'Perušić', 'Karlobag', 'Udbina', 'Plitvička Jezera', 'Korenica', 'Vrhovine', 'Donji Lapac', 'Josipdol'
    ]);

    _dodajSkupinu(mapa, 'HR', 'lucko', [
      'Zagreb', 'Velika Gorica', 'Samobor', 'Sveta Nedelja', 'Jastrebarsko', 'Stupnik', 'Klinča Sela',
      'Pisarovina', 'Krašić', 'Žumberak', 'Rugvica', 'Dugo Selo', 'Ivanić-Grad', 'Zaprešić', 'Vrbovec',
      'Sveti Ivan Zelina', 'Križevci', 'Koprivnica', 'Bjelovar', 'Virovitica', 'Čazma', 'Garešnica', 'Kutina', 'Novska', 'Sisak', 'Petrinja', 'Glina', 'Hrvatska Kostajnica', 'Topusko', 'Dvor', 'Sunja', 'Lekenik', 'Popovača'
    ]);
    _dodajSkupinu(mapa, 'HR', 'karlovac', [
      'Karlovac', 'Duga Resa', 'Ogulin', 'Slunj', 'Ozalj', 'Vojnić', 'Krnjak', 'Lasinja', 'Žakanje', 'Netretić', 'Bosiljevo',
      'Rakovica', 'Cetingrad', 'Barilović', 'Plaški', 'Generalski Stol', 'Kamanje', 'Ribnik'
    ]);

    _dodajMultiAutoput(mapa, 'HR', 'zapresic', 'krapina', 'lucko', [
      'Zabok', 'Krapina', 'Oroslavje', 'Donja Stubica', 'Marija Bistrica', 'Bedekovčina', 'Sveti Križ Začretje',
      'Pregrada', 'Hum na Sutli', 'Desinić', 'Kumrovec', 'Klanjec', 'Veliko Trgovišće', 'Tuhelj', 'Đurmanec', 'Zlatar', 'Zlatar Bistrica', 'Lobor', 'Mihovljan', 'Radoboj', 'Gornja Stubica'
    ]);
    _dodajMultiAutoput(mapa, 'HR', 'varazdin', 'sveti_helena', 'lucko', [
      'Varaždin', 'Čakovec', 'Novi Marof', 'Ludbreg', 'Prelog', 'Mursko Središće', 'Lepoglava', 'Ivanec',
      'Varaždinske Toplice', 'Nedelišće', 'Goričan', 'Šenkovec', 'Cestica', 'Bednja', 'Kotoriba', 'Donja Dubrava', 'Mala Subotica', 'Sveti Martin na Muri'
    ]);

    _dodajSkupinu(mapa, 'HR', 'osijek', [
      'Osijek', 'Đakovo', 'Našice', 'Belišće', 'Valpovo', 'Donji Miholjac', 'Beli Manastir', 'Čepin', 'Bilje', 'Erdut', 'Vukovar', 'Vinkovci',
      'Županja', 'Ilok', 'Otok', 'Gradište', 'Cerna', 'Drenovci', 'Bošnjaci', 'Vrbanja', 'Trpinja', 'Borovo', 'Markušica', 'Nijemci', 'Nuštar', 'Stari Jankovci', 'Tompojevci', 'Bogdanovci', 'Lovas'
    ]);
    _dodajSkupinu(mapa, 'HR', 'slavonski_brod_zapad', [
      'Slavonski Brod', 'Nova Gradiška', 'Oriovac', 'Sibinj', 'Garčin', 'Vrpolje', 'Sikirevci', 'Gundinci', 'Požega', 'Pakrac',
      'Lipik', 'Kutjevo', 'Pleternica', 'Brestovac', 'Rešetari', 'Okučani', 'Stara Gradiška', 'Davor', 'Bukovlje', 'Cernik', 'Gornji Bogićevci', 'Dragalić'
    ]);

    _dodajSkupinu(mapa, 'HR', 'grobnik', [
      'Rijeka', 'Opatija', 'Crikvenica', 'Novi Vinodolski', 'Krk', 'Bakar', 'Kastav', 'Viškovo', 'Čavle', 'Jelenje', 'Delnice',
      'Fužine', 'Mrkopalj', 'Ravna Gora', 'Skrad', 'Vrbovsko', 'Brod Moravice', 'Baška', 'Malinska', 'Punat', 'Dobrinj', 'Cres', 'Rab', 'Lopar', 'Mali Lošinj', 'Veli Lošinj', 'Lokve'
    ]);
    _dodajSkupinu(mapa, 'HR', 'pula', [
      'Pula', 'Rovinj', 'Poreč', 'Umag', 'Pazin', 'Labin', 'Buje', 'Vodnjan', 'Buzet', 'Žminj', 'Medulin', 'Fažana',
      'Vrsar', 'Funtana', 'Tar', 'Novigrad', 'Motovun', 'Grožnjan', 'Bale', 'Kanfanar', 'Barban', 'Ližnjan', 'Marčana', 'Svetvinčenat', 'Lanišće', 'Karojba', 'Višnjan', 'Vižinada'
    ]);

    // --- SLOVENIJA ---
    _dodajSkupinu(mapa, 'SI', 'ljubljana_jug', [
      'Ljubljana', 'Kranj', 'Domžale', 'Kamnik', 'Škofja Loka', 'Vrhnika', 'Grosuplje', 'Kočevje', 'Ribnica', 'Bled', 'Bohinj', 'Postojna', 'Koper', 'Izola', 'Piran',
      'Logatec', 'Idrija', 'Tolmin', 'Bovec', 'Kobarid', 'Nova Gorica', 'Ajdovščina', 'Sežana', 'Divača', 'Ilirska Bistrica', 'Pivka', 'Cerknica', 'Litija', 'Zagorje ob Savi', 'Trbovlje', 'Hrastnik', 'Laško', 'Radeče', 'Medvode', 'Mengeš', 'Radovljica', 'Jesenice', 'Kranjska Gora'
    ]);
    _dodajSkupinu(mapa, 'SI', 'maribor_jug', [
      'Maribor', 'Celje', 'Ptuj', 'Velenje', 'Slovenska Bistrica', 'Murska Sobota', 'Lendava', 'Rogaška Slatina', 'Žalec', 'Slovenske Konjice',
      'Ravne na Koroškem', 'Slovenj Gradec', 'Dravograd', 'Radlje ob Dravi', 'Ruše', 'Lenart', 'Gornja Radgona', 'Ljutomer', 'Ormož', 'Kidričevo', 'Šentjur', 'Mozirje', 'Vransko', 'Prevalje', 'Mežica', 'Črna na Koroškem'
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
  // 2. MATRICA SLUŽBENIH DIONICA - 100% SVIH UNARSNIH RELACIJA
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

      // Zapisivanje u oba smjera + sinogracija čvorišta i naziva gradova
      dionice['${c1}_$c2'] = data;
      dionice['${c2}_$c1'] = data;
    }

    // --- AZM A2 DIONICE (Popravak ključeva za A2) ---
    dodaj('zapresic', 'krapina', 'AZM (A2)', 'A2: Zaprešić - Krapina', 2.50, 4.00, 10.00, 15.40);
    dodaj('zapresic', 'zabok', 'AZM (A2)', 'A2: Zaprešić - Zabok', 2.00, 3.20, 8.00, 12.00);
    dodaj('zagreb', 'krapina', 'AZM (A2)', 'A2: Zagreb - Krapina', 2.50, 4.00, 10.00, 15.40);
    dodaj('zagreb', 'zabok', 'AZM (A2)', 'A2: Zagreb - Zabok', 2.00, 3.20, 8.00, 12.00);

    // --- HAC OSNOVNA MREŽA ČVORIŠTA ---
    dodaj('lucko', 'karlovac', 'HAC', 'A1: Lučko - Karlovac', 2.20, 3.50, 5.50, 9.00);
    dodaj('lucko', 'gospic', 'HAC', 'A1: Lučko - Gospić', 11.00, 17.50, 26.00, 44.00);
    dodaj('lucko', 'bosiljevo', 'HAC', 'A1: Lučko - Bosiljevo', 8.50, 13.50, 20.00, 33.50);
    dodaj('lucko', 'zadar_istok', 'HAC', 'A1: Lučko - Zadar istok', 16.00, 25.50, 38.00, 63.00);
    dodaj('lucko', 'sibenik', 'HAC', 'A1: Lučko - Šibenik', 19.00, 30.50, 45.00, 75.00);
    dodaj('lucko', 'dugopolje', 'HAC', 'A1: Lučko - Dugopolje', 24.00, 38.50, 57.50, 96.00);
    dodaj('lucko', 'sestanovac', 'HAC', 'A1: Lučko - Šestanovac', 27.00, 43.00, 64.00, 107.00);
    dodaj('lucko', 'ploce', 'HAC', 'A1: Lučko - Ploče', 30.00, 48.00, 72.00, 120.00);
    dodaj('lucko', 'grobnik', 'HAC', 'A1/A6: Lučko - Rijeka (Grobnik)', 9.90, 15.90, 23.50, 39.50);
    dodaj('lucko', 'varazdin', 'HAC', 'A4: Zagreb - Varaždin', 6.50, 10.50, 16.00, 27.00);
    dodaj('lucko', 'slavonski_brod_zapad', 'HAC', 'A3: Zagreb - Slavonski Brod', 13.00, 21.00, 31.50, 53.00);
    dodaj('lucko', 'osijek', 'HAC', 'A3/A5: Zagreb - Osijek', 17.50, 28.00, 42.00, 70.00);

    // --- UNAKRSNO SPAJANJE SPLITA (DUGOPOLJE) SA SVIM ČVORIŠTIMA I GRADOVIMA ---
    dodaj('dugopolje', 'sibenik', 'HAC', 'A1: Dugopolje - Šibenik', 4.70, 8.40, 12.50, 20.50);
    dodaj('dugopolje', 'zadar_istok', 'HAC', 'A1: Dugopolje - Zadar istok', 8.78, 14.20, 21.00, 35.00);
    dodaj('dugopolje', 'gospic', 'HAC', 'A1: Dugopolje - Gospić', 13.00, 21.00, 31.50, 52.00);
    dodaj('dugopolje', 'karlovac', 'HAC', 'A1: Dugopolje - Karlovac', 22.00, 35.00, 52.00, 87.00);
    dodaj('dugopolje', 'sestanovac', 'HAC', 'A1: Dugopolje - Šestanovac', 3.50, 5.50, 8.50, 14.00);
    dodaj('dugopolje', 'ploce', 'HAC', 'A1: Dugopolje - Ploče', 7.80, 12.50, 18.50, 31.00);
    dodaj('dugopolje', 'grobnik', 'HAC', 'A1/A6: Dugopolje - Rijeka', 30.00, 48.00, 72.00, 120.00);
    dodaj('dugopolje', 'varazdin', 'HAC', 'A1/A4: Dugopolje - Varaždin', 30.50, 49.00, 73.50, 123.00);
    dodaj('dugopolje', 'slavonski_brod_zapad', 'HAC', 'A1/A3: Dugopolje - Slavonski Brod', 37.00, 59.50, 89.00, 149.00);
    dodaj('dugopolje', 'osijek', 'HAC', 'A1/A3/A5: Dugopolje - Osijek / Beli Manastir', 41.50, 66.50, 99.50, 166.00);

    // Diktatni spojevi za nazive gradova u ruti
    dodaj('split', 'zagreb', 'HAC', 'A1: Split - Zagreb', 24.00, 38.50, 57.50, 96.00);
    dodaj('split', 'zadar', 'HAC', 'A1: Split - Zadar', 8.78, 14.20, 21.00, 35.00);
    dodaj('split', 'sibenik', 'HAC', 'A1: Split - Šibenik', 4.70, 8.40, 12.50, 20.50);
    dodaj('split', 'gospic', 'HAC', 'A1: Split - Gospić', 13.00, 21.00, 31.50, 52.00);
    dodaj('split', 'ploce', 'HAC', 'A1: Split - Ploče', 7.80, 12.50, 18.50, 31.00);
    dodaj('split', 'dubrovnik', 'HAC', 'A1: Split - Dubrovnik', 11.50, 18.50, 27.50, 46.00);
    dodaj('split', 'rijeka', 'HAC', 'A1/A6: Split - Rijeka', 30.00, 48.00, 72.00, 120.00);
    dodaj('split', 'varazdin', 'HAC', 'A1/A4: Split - Varaždin', 30.50, 49.00, 73.50, 123.00);
    dodaj('split', 'slavonski_brod', 'HAC', 'A1/A3: Split - Slavonski Brod', 37.00, 59.50, 89.00, 149.00);
    dodaj('split', 'vukovar', 'HAC', 'A1/A3: Split - Vukovar', 41.50, 66.50, 99.50, 166.00);
    dodaj('split', 'beli_manastir', 'HAC', 'A1/A3/A5: Split - Beli Manastir', 41.50, 66.50, 99.50, 166.00);
    dodaj('split', 'vinkovci', 'HAC', 'A1/A3: Split - Vinkovci', 40.00, 64.00, 96.00, 160.00);
    dodaj('split', 'sisak', 'HAC', 'A1/A11: Split - Sisak', 26.00, 42.00, 62.00, 105.00);

    // --- OSTALI REGIONALNI SPOJEVI I MEĐUDRŽAVNE RUTE ---
    dodaj('zagreb', 'rijeka', 'HAC', 'A1/A6: Zagreb - Rijeka', 9.90, 15.90, 23.50, 39.50);
    dodaj('zagreb', 'varazdin', 'HAC', 'A4: Zagreb - Varaždin', 6.50, 10.50, 16.00, 27.00);
    dodaj('zagreb', 'slavonski_brod', 'HAC', 'A3: Zagreb - Slavonski Brod', 13.00, 21.00, 31.50, 53.00);
    dodaj('zagreb', 'osijek', 'HAC', 'A3/A5: Zagreb - Osijek', 17.50, 28.00, 42.00, 70.00);
    dodaj('zagreb', 'beli_manastir', 'HAC', 'A3/A5: Zagreb - Beli Manastir', 19.00, 31.00, 46.00, 77.00);

    dodaj('pula', 'grobnik', 'BINA Istra', 'Istarski Ipsilon: Pula - Rijeka', 11.50, 18.20, 28.00, 45.00);

    // DARS (Slovenija)
    dodaj('gruskovje', 'maribor_jug', 'DARS', 'A4: Gruškovje - Maribor', 4.50, 7.90, 12.00, 19.00);
    dodaj('obrezje', 'ljubljana_jug', 'DARS', 'A2: Obrežje - Ljubljana', 6.20, 11.10, 17.50, 28.00);
    dodaj('split', 'ljubljana', 'DARS / HAC', 'Split - Ljubljana', 35.00, 55.00, 85.00, 140.00);

    // BiH (Autoceste FBiH / RS)
    dodaj('bijaca', 'sarajevo_sjever', 'Autoceste FBiH', 'A1: Bijača - Sarajevo', 7.50, 13.00, 19.50, 32.00);
    dodaj('zenica_jug', 'sarajevo_sjever', 'Autoceste FBiH', 'A1: Zenica - Sarajevo', 3.50, 6.00, 9.00, 15.00);
    dodaj('mahovljani', 'doboj', 'Autoputevi RS', '9. Januar: Banja Luka - Doboj', 4.00, 7.00, 10.50, 17.50);
    dodaj('split', 'sarajevo', 'Autoceste FBiH', 'Split - Sarajevo', 15.00, 26.00, 39.00, 64.00);

    // Crna Gora (Monteput)
    dodaj('smokovac', 'matesevo', 'Monteput', 'A1: Smokovac - Mateševo', 3.50, 6.00, 9.50, 15.00);
    dodaj('sozina', 'podgorica', 'Monteput', 'Tunel Sozina - Podgorica', 2.50, 5.00, 10.00, 18.00);

    return dionice;
  }

  // =========================================================================
  // 3. REGENERACIJA NA CLOUDU
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
