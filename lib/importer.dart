import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zc_api/zc_api.dart';

import 'main.dart';

class Importer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ZCash Signer')),
      body: Center(
          child: ElevatedButton(
              onPressed: onImport(context),
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.headline5),
              child: Text('Scan Key'))),
    );
  }

  onImport(BuildContext context) {
    return () async {
      final code = await BarcodeScanner.scan();
      String keyType = ZcApi.getKeyType(code.rawContent);
      if (keyType != '') {
        if (keyType == 'viewing') {
          final heightController = TextEditingController();
          Alert(
              context: context,
              title: "STARTING HEIGHT",
              content: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Block Height',
                    ),
                    keyboardType: TextInputType.number,
                    controller: heightController,
                  ),
                ],
              ),
              buttons: [
                DialogButton(
                  onPressed: () {
                    var height = int.parse(heightController.value.text);
                    appStore.setKey(keyType, code.rawContent, height);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
        } else {
          appStore.setKey(keyType, code.rawContent, 0);
        }
      }
    };
  }
}
