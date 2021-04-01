import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zc_api/zc_api.dart';

part 'store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  ByteData spendParams;
  ByteData outputParams;

  @observable
  double balance = 0.0;

  @observable
  String secretKey;

  @observable
  String viewingKey;

  @observable
  String address = "";

  @observable
  bool syncing = false;

  @observable
  int height = 0;

  @action
  Future<bool> init() async {
    spendParams = await rootBundle.load('assets/sapling-spend.params');
    outputParams = await rootBundle.load('assets/sapling-output.params');

    final prefs = await SharedPreferences.getInstance();
    secretKey = prefs.get('secret');
    viewingKey = prefs.get('viewing');
    if (viewingKey != null)
      address = ZcApi.getAddress(viewingKey);
    return true;
  }

  @action
  Future<void> setKey(String keyType, String key, int height) async {
    final databasePath = await getDatabasesPath();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(keyType, key);
    if (keyType == 'viewing') {
      viewingKey = key;
      address = ZcApi.getAddress(key);
      ZcApi.initialize(databasePath);
      ZcApi.initAccountWithViewKey(databasePath, key, height);
    }
    else {
      final viewingKey = ZcApi.getViewingKey(key);
      address = ZcApi.getAddress(viewingKey);
      secretKey = key;
    }
  }

  @action
  void toggleSync() {
    syncing = !syncing;
    if (syncing) {
      sync();
    }
  }

  @action
  Future<void> sync() async {
    int n = 0;
    final databasePath = await getDatabasesPath();
    do {
      n = await compute(syncOne, databasePath);
      balance = ZcApi.getBalance(databasePath) / 100000000.0;
      height = ZcApi.getHeight(databasePath);
    } while (n > 0);
    syncing = false;
  }
}

int syncOne(String databasePath) {
  int n = ZcApi.sync(databasePath, 1000);
  return n;
}
