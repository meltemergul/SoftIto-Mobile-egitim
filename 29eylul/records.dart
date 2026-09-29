//dart record ve api durum kontrolü

//pozisyonel record-sıralama önemli-en güvenli olan
({String nodeAdi, int statusCode, double latencyMs, bool baglantiBasarili})
sunucuPingAt({required String hedefIp}) {
  final double gecikme = 24.8;
  final int kod = 200;

  return (
    nodeAdi: "edge-router-ist-$hedefIp",
    statusCode: kod,
    latencyMs: gecikme,
    baglantiBasarili: kod == 200,
  );
}

void main() {
  print("Dart Record Kayıtları");
  final probeSunucu = sunucuPingAt(hedefIp: "10.0.1.50");
  print("IP Adı                           :${probeSunucu.nodeAdi}");
  print("HTTP Kodu                        :${probeSunucu.statusCode}");
  print("Gecikme Süresi                   :${probeSunucu.latencyMs}");
  print(
    "Ağ Durumu                        :${probeSunucu.baglantiBasarili ? "Stabil" : "Kopuk"}",
  );

  //tek hamlede değişkenleri parçalama;
  final (:nodeAdi, :statusCode, :latencyMs, :baglantiBasarili) = probeSunucu;
  print("Değişkenler-> $nodeAdi [Kod: $statusCode, Gecikme: ${latencyMs}ms]");

  final (String podId, int cpuCores, double ramGb) = ("k8s-pod-77x", 8, 32.0);

  print("Pod Özeti: $podId | Çekirdek : $cpuCores | Ram: ${ramGb}GB");
}
