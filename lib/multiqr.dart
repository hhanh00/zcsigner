import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiver/iterables.dart';
import 'package:sprintf/sprintf.dart';
import 'package:string_splitter/string_splitter.dart';

class MultiQRCode extends StatelessWidget {
  final String data;
  MultiQRCode({this.data});

  @override
  Widget build(BuildContext context) {
    final chunks = StringSplitter.chunk(data, 500);
    final len = chunks.length;
    return CarouselSlider(
        options: CarouselOptions(height: 400),
        items: enumerate(chunks)
            .map((iv) => Builder(builder: (context) {
                  final bytes = utf8.encode(iv.value);
                  final checksum = sha256.convert(bytes);
                  final checksumStr =
                      HEX.encode(checksum.bytes).substring(0, 8);
                  return QrImage(
                      data: sprintf("%02d%02d%s%s",
                          [iv.index, len, checksumStr, iv.value]));
                }))
            .toList());
  }

  static Future<String> read() async {
    final Map<int, String> chunks = {};
    while (true) {
      final code = await BarcodeScanner.scan();
      final data = code.rawContent;
      print(data);
      if (data.length < 12) continue;
      final index = int.parse(data.substring(0, 2));
      final len = int.parse(data.substring(2, 4));
      final checksumStr = data.substring(4, 12);
      final chunk = data.substring(12);
      final bytes = utf8.encode(chunk);
      final checksum = sha256.convert(bytes);
      final checksumStr2 = HEX.encode(checksum.bytes).substring(0, 8);
      if (checksumStr != checksumStr2) continue;
      chunks[index] = chunk;
      print("Got $index out of $len");
      if (len == chunks.length) break;
      await Future.delayed(Duration(seconds: 2));
    }
    final data =
        Iterable<int>.generate(chunks.length).map((i) => chunks[i]).join();
    return data;
  }
}
