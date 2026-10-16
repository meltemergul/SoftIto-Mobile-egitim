abstract class Canavar {
  void kukre();
}

class Kurt extends Canavar {
  @override
  void kukre() {
    print("AUUUUUUUUU");
  }
}

class Ejderha extends Canavar {
  @override
  void kukre() {
    print("GRRRRRRR");
  }
}

void canavarSesVer(List<Canavar> canavarlar) {
  for (var canavar in canavarlar) {
    canavar.kukre();
  }
}

void main() {
  final List<Canavar> canavarTakimi = [Kurt(), Ejderha()];

  canavarSesVer(canavarTakimi);
}
