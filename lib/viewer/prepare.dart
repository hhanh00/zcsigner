import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../multiqr.dart';

class PrepareTxPage extends StatelessWidget {
  final String tx;
  PrepareTxPage(this.tx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('UNSIGNED Transaction')),
        body: MultiQRCode(data: tx)
    );
  }
}

