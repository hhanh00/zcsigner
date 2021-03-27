import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zc_api/zc_api.dart';
import '../multiqr.dart';

import '../main.dart';

class Signer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ZCash Signer'), backgroundColor: Colors.red),
        body: Center(
          child:
            ElevatedButton(child: Text('SCAN TRANSACTION'), onPressed: onScan(context))
        )
    );
  }

  onScan(BuildContext context) {
    return () async {
      final tx = await MultiQRCode.read();
      final secretKey = appStore.secretKey;
      final r = ZcApi.sign(secretKey, tx,
          appStore.spendParams, appStore.outputParams);
      Navigator.of(context).pushNamed('/signed', arguments: r);
    };
  }
}
