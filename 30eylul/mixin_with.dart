//mixin and with

import 'dart:io';

mixin UcmaYetisi {
  int ucusIrtifasiMetre = 100;

  void gogeYuksel() {
    print(
      "ucuş yetisi:kanatlarını açtı ve $ucusIrtifasiMetre metreye yükseldi",
    );
  }
}

mixin GorunmezlikYetisi {
  void peleriniOrt() {
    print("Görünmezlik: Düşmanların gözünden tamamen kayboldu");
  }
}
mixin AtesGucuYetisi {
  void alevSaldirisi() {
    print("Ateş Gücü:Kılıcını alevlendirdi ve alanı yaktı:");
  }
}

class TemelKarakter {
  final String ad;
  TemelKarakter({required this.ad});
}

class EfsaneviEjderBinicisi extends TemelKarakter
    with UcmaYetisi, AtesGucuYetisi {
  final String ejderhaAdi;

  EfsaneviEjderBinicisi({required this.ejderhaAdi, required super.ad});

  void HucumEt() {
    print("$ad ve ejderhasi $ejderhaAdi savaşa atılıyor");
    gogeYuksel();
    alevSaldirisi();
  }
}

class GolgeSuikastci extends TemelKarakter with GorunmezlikYetisi {
  GolgeSuikastci({required super.ad});

  void suikastYap() {
    print("$ad hedefe sessizçe yaklaşıyor");
    peleriniOrt();
    print("kritik bir darbe vurdu");
  }
}

void main() {
  print("süper güçler başlatılıyor");
  final birinci = EfsaneviEjderBinicisi(ejderhaAdi: "Aslıhan", ad: "Gencer");
  birinci.HucumEt();
  final ikinci = GolgeSuikastci(ad: "Adilmurat");
  ikinci.suikastYap();
}
