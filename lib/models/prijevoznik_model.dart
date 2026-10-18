class PrijevoznikModel {
  String naziv, vlasnik, adresa, grad, oib, telefon, email, banka, iban;
  bool uSustavuPdv;

  PrijevoznikModel({
    this.naziv = '"Klanac" obrt za prijevoz',
    this.vlasnik = '',
    this.adresa = '',
    this.grad = '',
    this.oib = '52556102683',
    this.telefon = '',
    this.email = '',
    this.banka = '',
    this.iban = '',
    this.uSustavuPdv = true,
  });

  Map<String, dynamic> toJson() => {
    'naziv': naziv, 'vlasnik': vlasnik, 'adresa': adresa, 'grad': grad,
    'oib': oib, 'telefon': telefon, 'email': email, 'banka': banka, 'iban': iban, 'uSustavuPdv': uSustavuPdv,
  };

  factory PrijevoznikModel.fromJson(Map<String, dynamic> json) => PrijevoznikModel(
    naziv: json['naziv'] ?? '"Klanac" obrt za prijevoz',
    vlasnik: json['vlasnik'] ?? '',
    adresa: json['adresa'] ?? '',
    grad: json['grad'] ?? '',
    oib: json['oib'] ?? '52556102683',
    telefon: json['telefon'] ?? '',
    email: json['email'] ?? '',
    banka: json['banka'] ?? '',
    iban: json['iban'] ?? '',
    uSustavuPdv: json['uSustavuPdv'] ?? true,
  );
}
