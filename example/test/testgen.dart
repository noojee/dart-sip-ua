void main() {
  Tester().test();
}

class A {}

class B extends A {}

class C extends A {}

class D {}

class I<T> {}

class Tester {
  void test() {
    on2((B arg) {}, B());
    on2((A arg) {}, B());
    on2((C arg) {}, B());
    on2((C arg) {}, C());
    on2((D arg) {}, C());
  }

  void on2<O extends A, E extends A>(Function(O value) listener, E emit) {
    var t1 = I<O>();
    var t2 = I<E>();
    if (t1.runtimeType == t2.runtimeType) {
      print("$t1 == $t2");
    }
    if (t1.runtimeType.toString().toLowerCase().contains("null")) {
      print("INvalid type $t1");
    }
  }
}
