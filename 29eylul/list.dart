void main() {
  final List<String> aktifMikroservisler = [
    "auth-service:v2.1",
    "gateway-service:v1.9",
    "payment-processor:v3.0",
  ];
  aktifMikroservisler.add("telemetry-collector:v1.0");
  print(
    "aktif servisler: (${aktifMikroservisler.length} adet): $aktifMikroservisler",
  );

  //sabit uzunluktali liste(fixed-length)

  final List<String> cekirdekYukDengeleyiciler = List.filled(
    4,
    "Port-Kapalı",
    growable: false,
  );
  cekirdekYukDengeleyiciler[0] = "LB-NODE-01; 192.168.1.10(Online)";
  cekirdekYukDengeleyiciler[1] = "LB-NODE-02; 192.168.1.11(Online)";

  //cekirdekYukDengeleyiciler.add("LB-NODE-05");
  //Hata fixed-length listeleye elemena eklenemez

  print("Çekirdek Yük Dengeleyici Portları: $cekirdekYukDengeleyiciler");

  //programatik list üretici

  final List<String> kubernetesPodlari = List.generate(
    13,
    (index) => "pod-node-eu-west-${index + 1} [Ram:16 GB,CPU:4 Cores]",
  );

  print("oluşturulun KBs poları: $kubernetesPodlari");

  //degisitirilemez list
  final List<String> guvenlikDuvariPortlari = List.unmodifiable([
    "22/TCP((SSH)",
    "44c/TCP((HTTPS)",
    "6643/TCP((K8s-API)",
  ]);
  // guvenlikDuvariPortlari[0]="80/TCP"; //HATA CANNOT MODİFT AN UNMODİFİABLE LİST
  print("güvenlik duvarı korumalı portlar: $guvenlikDuvariPortlari");
}
