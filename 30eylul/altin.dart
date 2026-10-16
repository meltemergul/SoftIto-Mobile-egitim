class AltinKasasi {
  final String oyuncuAdi;
  int _altin = 0;

  AltinKasasi({required this.oyuncuAdi});

  int get altin {
    return _altin;
  }

  set altin(int yeniAltin) {
    if (yeniAltin < 0) {
      print("$oyuncuAdi sahte altın!");
    } else if (yeniAltin == 0) {
      print("$oyuncuAdi için altın eklenmedi.");
    } else {
      _altin += yeniAltin;
      print("$oyuncuAdi için $yeniAltin altın eklendi.");
    }
  }
}

void main() {
  final kasa = AltinKasasi(oyuncuAdi: "Meltem");
  print("Başlangıç: ${kasa.altin}");

  kasa.altin = 100;
  print("Mevcut altın: ${kasa.altin}");

  kasa.altin = 50;
  print("Mevcut altın: ${kasa.altin}");

  kasa.altin = -20;
  print("Mevcut altın: ${kasa.altin}");
}
