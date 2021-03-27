import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zc_api/zc_api.dart';
import '../multiqr.dart';

import '../main.dart';

class Viewer extends StatefulWidget {
  @override
  ViewerState createState() => ViewerState();
}

class ViewerState extends State<Viewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ZCash Signer'), actions: [
          IconButton(icon: Icon(MdiIcons.upload), onPressed: onBroadcast),
        ]),
        body: Observer(
            builder: (context) => Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                    child: Column(children: [
                  QrImage(data: appStore.address, size: 300),
                  Text(appStore.address),
                  Text("${appStore.balance}",
                      style: Theme.of(context).textTheme.headline2),
                  IconButton(
                      icon: appStore.syncing
                          ? Icon(Icons.stop)
                          : Icon(Icons.refresh),
                      onPressed: onRefresh)
                ])))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/send');
          },
          child: Icon(Icons.send),
        ));
  }

  onRefresh() {
    appStore.toggleSync();
  }

  onBroadcast() async {
    final rawTx = await MultiQRCode.read();
    final result = ZcApi.broadcast(rawTx);
    Alert(context: context, title: 'Tx Submission', desc: result, buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () { Navigator.of(context).pop(); },
      )
    ]).show();
  }
}
