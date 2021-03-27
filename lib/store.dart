import 'package:mobx/mobx.dart';

part 'store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  double balance = 0.0;
}
