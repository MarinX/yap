import 'package:flutter/material.dart';
import 'package:yapgp/models/config.dart';
import 'package:yapgp/views/decrypt.dart';
import 'package:yapgp/views/settings.dart';

import 'contacts.dart';
import 'keys.dart';

class Home extends StatefulWidget {
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.lock_open),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Decrypt()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
            )
          ],
          title: Text(Config.APP_NAME),
          bottom: TabBar(
            tabs: [Tab(text: "Contacts"), Tab(text: "Keys")],
          ),
        ),
        body: TabBarView(
          children: <Widget>[Contacts(), Keys()],
        ),
      ),
    );
  }

}