import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:zc_api/zc_api.dart';
import '../multiqr.dart';

import '../main.dart';

class Signer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text('ZCash Signer'), backgroundColor: Colors.red),
        body: Container(
            padding: EdgeInsets.all(32),
            child: Center(
                child: Column(children: [
              Observer(
                  builder: (context) => Text(appStore.address,
                      style: Theme.of(context).textTheme.headline6)),
              Padding(padding: EdgeInsets.symmetric(vertical: 30)),
              ElevatedButton(
                  child: Text('SCAN TRANSACTION'), onPressed: onScan(context))
            ]))));
  }

  onScan(BuildContext context) {
    return () async {
      final tx = await MultiQRCode.read();
      final secretKey = appStore.secretKey;
      final r = ZcApi.sign(
          secretKey, tx, appStore.spendParams, appStore.outputParams);
      Navigator.of(context).pushNamed('/signed', arguments: r);
    };
  }
}
