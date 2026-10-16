mixin YuzmeYetisi {
  void dalisYap() {
    print("Suya daldı.");
  }
}

class Denizci with YuzmeYetisi {}

void main() {
  final denizci = Denizci();

  denizci.dalisYap();
}
