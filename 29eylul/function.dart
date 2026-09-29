typedef MetrikUyarKurali = bool Function(double deger);

void metrikDenetle({
  required String metrikAdi,
  required double mevcutDeger,
  required MetrikUyarKurali kural,
  required void Function(String mesaj) alertTetikleyici,
}) {
  if (kural(mevcutDeger)) {
    alertTetikleyici(
      "Uyarı: $metrikAdi eşik değerini açtı."
      "Mevcut: $mevcutDeger",
    );
  } else {
    print("$metrikAdi ormal sınırlar içinde ($mevcutDeger)");
  }
}

void main() {
  print("Metrik Uyarıları");
  final MetrikUyarKurali yuksekCpu = (deger) => deger >= 85.0; //%85 ve üstü
  final MetrikUyarKurali yuksekRam = (deger) => deger >= 90.0; //%90 ve üstü

  metrikDenetle(
    metrikAdi: "CPU",
    mevcutDeger: 92.4,
    kural: yuksekCpu,
    alertTetikleyici: (msg) => print("Bildirim gönderildi - $msg"),
  );

  metrikDenetle(
    metrikAdi: "RAM",
    mevcutDeger: 64.0,
    kural: yuksekRam,
    alertTetikleyici: (msg) => print("Bildirim gönderildi - $msg"),
  );
}
