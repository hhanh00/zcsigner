import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zc_api/zc_api.dart';

import 'importer.dart';
import 'signer/signed.dart';
import 'signer/signer.dart';
import 'store.dart';
import 'viewer/prepare.dart';
import 'viewer/send.dart';
import 'viewer/viewer.dart';

final appStore = AppStore();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final title = "ZCash Signer";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(title: title),
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            '/send': (context) => SendPage(),
            '/prepare': (context) => PrepareTxPage(settings.arguments),
            '/signed': (context) => SignedPage(settings.arguments),
          };
          return MaterialPageRoute(builder: routes[settings.name]);
        }
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: appStore.init(),
        builder: buildInternal
    );
  }

  Widget buildInternal(BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (!snapshot.hasData)
      return LinearProgressIndicator();

    // App import is locked if we have a key
    hasImport() => appStore.secretKey == null && appStore.viewingKey == null;
    isSigner() => appStore.secretKey != null;

    return Observer(builder: (context) =>
    hasImport() ? Importer() : isSigner() ? Signer() : Viewer());
  }
}

