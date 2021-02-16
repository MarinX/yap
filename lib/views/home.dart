import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapgp/models/config.dart';
import 'package:yapgp/views/decrypt.dart';
import 'package:yapgp/views/settings.dart';
import 'package:flutter_screen_lock/lock_screen.dart';
import 'package:local_auth/local_auth.dart';

import 'contacts.dart';
import 'keys.dart';

class Home extends StatefulWidget {
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs){
      String isLocked = prefs.getString("pinlock");
      if(isLocked != null && isLocked.isNotEmpty) {
        Future.delayed(Duration.zero, (){
          showLockScreen(
              context: context,
              correctString: isLocked,
              canBiometric: true,
              showBiometricFirst: true,
              biometricAuthenticate: (context) async {
                final localAuth = LocalAuthentication();
                final didAuthenticate =
                await localAuth.authenticateWithBiometrics(
                    localizedReason: 'Please authenticate');
                if (didAuthenticate) {
                  return true;
                }
                return false;
              },
              onUnlocked: () => {},
              canCancel: false
          );
        });
      }
    });

  }

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