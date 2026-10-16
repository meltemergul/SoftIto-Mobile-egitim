abstract class LoncaUyesi {
  final String rumuz;

  LoncaUyesi({required this.rumuz});

  //soyut metot abstract method
  void ozelYetenekKullan();

  void loncaSelamVer() {
    print("$rumuz lonca bayrağını selamladı:'Onur ve Zafer için'");
  }
}

class Sovalye extends LoncaUyesi {
  Sovalye({required super.rumuz});

  @override
  void ozelYetenekKullan() {
    print("$rumuz Demir kalkanı kaldırdı ve savunma duvarı ördü");
  }
}

class Sifaci extends LoncaUyesi {
  Sifaci({required super.rumuz});

  @override
  void ozelYetenekKullan() {
    print("$rumuz Kutsal ışık büyüsüyle tüm takımın canını tazeledi");
  }
}

void savasAlanindaKomutVer(List<LoncaUyesi> takim) {
  print("Liderin emriyle takım yetenekleri devreye girsin");
  for (var t in takim) {
    t.loncaSelamVer();
    //herkes kendi özel yeteneğini kullansın
    t.ozelYetenekKullan();
  }
}

void main() {
  print("Lonca Takımı:");
  final List<LoncaUyesi> loncaBirligi = [
    Sovalye(rumuz: "Kızıl Şovalye Adil"),
    Sifaci(rumuz: "Orman Perisi Shad"),
    Sovalye(rumuz: "Gümüş Muhafız Eren"),
  ];

  //hepsini tek bir emir ile çalıştıryoruz
  savasAlanindaKomutVer(loncaBirligi);
}
