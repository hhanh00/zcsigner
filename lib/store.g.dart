// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  final _$balanceAtom = Atom(name: '_AppStore.balance');

  @override
  double get balance {
    _$balanceAtom.reportRead();
    return super.balance;
  }

  @override
  set balance(double value) {
    _$balanceAtom.reportWrite(value, super.balance, () {
      super.balance = value;
    });
  }

  final _$secretKeyAtom = Atom(name: '_AppStore.secretKey');

  @override
  String get secretKey {
    _$secretKeyAtom.reportRead();
    return super.secretKey;
  }

  @override
  set secretKey(String value) {
    _$secretKeyAtom.reportWrite(value, super.secretKey, () {
      super.secretKey = value;
    });
  }

  final _$viewingKeyAtom = Atom(name: '_AppStore.viewingKey');

  @override
  String get viewingKey {
    _$viewingKeyAtom.reportRead();
    return super.viewingKey;
  }

  @override
  set viewingKey(String value) {
    _$viewingKeyAtom.reportWrite(value, super.viewingKey, () {
      super.viewingKey = value;
    });
  }

  final _$addressAtom = Atom(name: '_AppStore.address');

  @override
  String get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  final _$syncingAtom = Atom(name: '_AppStore.syncing');

  @override
  bool get syncing {
    _$syncingAtom.reportRead();
    return super.syncing;
  }

  @override
  set syncing(bool value) {
    _$syncingAtom.reportWrite(value, super.syncing, () {
      super.syncing = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_AppStore.init');

  @override
  Future<bool> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$setKeyAsyncAction = AsyncAction('_AppStore.setKey');

  @override
  Future<void> setKey(String keyType, String key, int height) {
    return _$setKeyAsyncAction.run(() => super.setKey(keyType, key, height));
  }

  final _$syncAsyncAction = AsyncAction('_AppStore.sync');

  @override
  Future<void> sync() {
    return _$syncAsyncAction.run(() => super.sync());
  }

  final _$_AppStoreActionController = ActionController(name: '_AppStore');

  @override
  void toggleSync() {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.toggleSync');
    try {
      return super.toggleSync();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
balance: ${balance},
secretKey: ${secretKey},
viewingKey: ${viewingKey},
address: ${address},
syncing: ${syncing}
    ''';
  }
}
