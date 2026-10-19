// lib/models/prijevoznik_model.dart

class PrijevoznikModel {
  String naziv;
  String vlasnik;
  String adresa;
  String grad;
  String oib;
  String telefon;
  String email;
  String banka;
  String iban;
  bool uSustavuPdv;

  PrijevoznikModel({
    this.naziv = '',
    this.vlasnik = '',
    this.adresa = '',
    this.grad = '',
    this.oib = '',
    this.telefon = '',
    this.email = '',
    this.banka = '',
    this.iban = '',
    this.uSustavuPdv = true,
  });

  PrijevoznikModel copyWith({
    String? naziv,
    String? vlasnik,
    String? adresa,
    String? grad,
    String? oib,
    String? telefon,
    String? email,
    String? banka,
    String? iban,
    bool? uSustavuPdv,
  }) {
    return PrijevoznikModel(
      naziv: naziv ?? this.naziv,
      vlasnik: vlasnik ?? this.vlasnik,
      adresa: adresa ?? this.adresa,
      grad: grad ?? this.grad,
      oib: oib ?? this.oib,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      banka: banka ?? this.banka,
      iban: iban ?? this.iban,
      uSustavuPdv: uSustavuPdv ?? this.uSustavuPdv,
    );
  }

  Map<String, dynamic> toJson() => {
        'naziv': naziv,
        'vlasnik': vlasnik,
        'adresa': adresa,
        'grad': grad,
        'oib': oib,
        'telefon': telefon,
        'email': email,
        'banka': banka,
        'iban': iban,
        'uSustavuPdv': uSustavuPdv,
      };

  factory PrijevoznikModel.fromJson(Map<String, dynamic> json) => PrijevoznikModel(
        naziv: json['naziv']?.toString() ?? '',
        vlasnik: json['vlasnik']?.toString() ?? '',
        adresa: json['adresa']?.toString() ?? '',
        grad: json['grad']?.toString() ?? '',
        oib: json['oib']?.toString() ?? '',
        telefon: json['telefon']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        banka: json['banka']?.toString() ?? '',
        iban: json['iban']?.toString() ?? '',
        uSustavuPdv: json['uSustavuPdv'] is bool
            ? json['uSustavuPdv']
            : (json['uSustavuPdv']?.toString().toLowerCase() == 'true'),
      );
}
