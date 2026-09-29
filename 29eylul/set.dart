void main() {
  print("Beyaz Liste ve Küme Analizi");
  final Set<String> istanbulVeriMerkezTipleri = {
    "10.0.1.10",
    "10.0.1.11",
    "10.0.1.12",
    "10.0.1.13",
    "10.0.1.10", //çift kayıt olarak görür ama tek hale getirir.
  };
  print("İstanbul IPleri: $istanbulVeriMerkezTipleri");

  final Set<String> frankfurttVeriMerkezTipleri = {
    "10.0.1.13",
    "10.0.1.30",
    "10.0.1.45",
  };
  print("Frankfurt IPleri: $frankfurttVeriMerkezTipleri");

  final ortakKopruIpler = istanbulVeriMerkezTipleri.intersection(
    frankfurttVeriMerkezTipleri,
  );
  print("Ortak Ağ İpleri(keşişim:) $ortakKopruIpler");

  final tumGlobalIpler = istanbulVeriMerkezTipleri.union(
    frankfurttVeriMerkezTipleri,
  );
  print("Toplam Global IPler(birleşim): $tumGlobalIpler");

  final sadeceIstanbul = istanbulVeriMerkezTipleri.difference(
    frankfurttVeriMerkezTipleri,
  );
  print("sadece istanbul: $sadeceIstanbul");
}
