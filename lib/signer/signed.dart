import 'package:flutter/material.dart';
import '../multiqr.dart';

class SignedPage extends StatelessWidget {
  final String rawTx;
  SignedPage(this.rawTx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Signed Transaction'), backgroundColor: Colors.red),
        body: MultiQRCode(data: rawTx)
    );
  }
}