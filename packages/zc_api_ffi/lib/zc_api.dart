
import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'ffi.dart' as zc_ffi;

class KeyPackage {
  String phrase = "";
  String spendingKey = "";
  String address = "";

  KeyPackage(this.phrase, this.spendingKey, this.address);
}

class ZcApiException implements Exception {
  final String message;
  ZcApiException([this.message]);
  String toString() { return this.message ?? "Exception"; }
}

class ZcApi {
  static const MethodChannel _channel =
  const MethodChannel('zc_api');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static bool initialize(String databasePath) {
    return zc_ffi.initialize(Utf8.toUtf8(databasePath)) != 0;
  }

  static KeyPackage initAccount(String databasePath) {
    final keys = zc_ffi.init_account(Utf8.toUtf8(databasePath));
    return KeyPackage(
        Utf8.fromUtf8(keys.phrase),
        Utf8.fromUtf8(keys.spending_key),
        Utf8.fromUtf8(keys.address));
  }

  static KeyPackage initAccountWithViewKey(String databasePath, String viewingKey, int height) {
    zc_ffi.init_account_with_viewing_key(Utf8.toUtf8(databasePath), Utf8.toUtf8(viewingKey), height);
  }

  static int sync(String databasePath, int maxBlocks) {
    final n = zc_ffi.sync(Utf8.toUtf8(databasePath), maxBlocks);
    return n;
  }

  static int getBalance(String databasePath) {
    final n = zc_ffi.get_balance(Utf8.toUtf8(databasePath));
    return n;
  }

  static void send(String databasePath, String address, double amount,
      String spendingKey,
      ByteData sendParams, ByteData outputParams) {
    final sats = (amount * 100000000).round();
    final sendP = castParams(sendParams);
    final outputP = castParams(outputParams);
    zc_ffi.send_tx(
        Utf8.toUtf8(databasePath),
        Utf8.toUtf8(address),
        sats,
        Utf8.toUtf8(spendingKey),
        sendP,
        sendParams.lengthInBytes,
        outputP,
        outputParams.lengthInBytes);
    free(sendP);
    free(outputP);
  }

  static Pointer<Utf8> castParams(ByteData params) {
    final bb = params.buffer;
    final Pointer<Uint8> result = allocate<Uint8>(count: bb.lengthInBytes);
    final nativeParams = result.asTypedList(bb.lengthInBytes);
    nativeParams.setAll(0, bb.asUint8List());
    return result.cast();
  }

  static bool checkAddress(String address) {
    return zc_ffi.check_address(Utf8.toUtf8(address)) != 0;
  }

  static String getAddress(String viewingKey) {
    final address =  zc_ffi.get_address(Utf8.toUtf8(viewingKey));
    return Utf8.fromUtf8(address);
  }

  static String getKeyType(String key) {
    final type = zc_ffi.get_key_type(Utf8.toUtf8(key));
    return Utf8.fromUtf8(type);
  }

  static String prepareTx(String databasePath, String address, double amount) {
    final sats = (amount * 100000000).round();
    final tx = zc_ffi.prepare_tx(Utf8.toUtf8(databasePath), Utf8.toUtf8(address), sats);
    if (tx.err != null)
      throw ZcApiException(Utf8.fromUtf8(tx.err));
    return Utf8.fromUtf8(tx.ok);
  }

  static String sign(String secretKey, String tx, ByteData sendParams, ByteData outputParams) {
    final sendP = castParams(sendParams);
    final outputP = castParams(outputParams);
    final rawTx = zc_ffi.sign_tx(Utf8.toUtf8(secretKey), Utf8.toUtf8(tx),
        sendP,
        sendParams.lengthInBytes,
        outputP,
        outputParams.lengthInBytes);
    if (rawTx.err != null)
      throw ZcApiException(Utf8.fromUtf8(rawTx.err));
    return Utf8.fromUtf8(rawTx.ok);
  }

  static String broadcast(String rawTx) {
    final result = zc_ffi.broadcast(Utf8.toUtf8(rawTx));
    if (result.err != null)
      throw ZcApiException(Utf8.fromUtf8(result.err));
    return Utf8.fromUtf8(result.ok);
  }

  static int getHeight(String databasePath) {
    return zc_ffi.get_height(Utf8.toUtf8(databasePath));
  }
}
