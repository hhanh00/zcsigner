import 'package:flutter/material.dart';
import 'package:zc_api/zc_api.dart';

import 'store.dart';

final appStore = AppStore();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final title = "ZCash Signer";
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: title),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    assert(!ZcApi.checkAddress("address"));
    assert(ZcApi.checkAddress("ztestsapling1fwgpn6j4w658s0p8nvh55musrqn4hzd3u39xpnqpzywukqpu5f2sr0942g7vrjvcnyszufueh8m"));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column()
      ),
    );
  }
}
