class CanSistemi {
  final String karakterAdi;
  double _canPuani = 100; //başındaki alt tire bu değişkeni gizli olarak kodlar.

  CanSistemi({required this.karakterAdi});

  //getter ile caan puanı güvenli dışarıya okutma
  double get canPuani {
    return _canPuani;
  }

  //setter ile can değeri değşiriken oyun kurallarını denetleyelim
  set canPuani(double yeniCan) {
    if (yeniCan <= 0.0) {
      _canPuani = 0.0;
      print("$karakterAdi canı tükendi ve yere yığıldı");
    } else if (yeniCan >= 100.0) {
      _canPuani = 100;
      print("Can Dolu(Maksimum 100 HP)");
    } else {
      _canPuani = yeniCan;
    }
  }

  bool get hayattaMi {
    return _canPuani > 0.0;
  }
}

void main() {
  print("Can Barı Güvenlik Sistemi:");

  final savasciCani = CanSistemi(karakterAdi: "Meltem Taşkıran");
  print("Başlangıç Canı                   :HP ${savasciCani.canPuani}");
  print("35 hasar alındı");
  savasciCani.canPuani = 65.0;
  print("Kalan Can:                       :HP ${savasciCani.canPuani}");
  print("200 can veren iksir içildi");
  savasciCani.canPuani = 200.0;
  print("Sabitlenen Can                   : HP ${savasciCani.canPuani}");
  print("Ölümcül darbe aldı");
  savasciCani.canPuani = -50;
  print("Nihai Can                        : HP ${savasciCani.canPuani}");
  print(
    "Savaşcı Hayatta mı?                 : ${savasciCani.hayattaMi ? 'Evet' : 'Hayır(Öldü)'}",
  );
}
