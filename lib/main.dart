import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapgp/models/config.dart';
import 'package:yapgp/views/home.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  static void setTheme(BuildContext context, ThemeData data) async {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    state.changeTheme(data);
  }

  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  ThemeData theme = ThemeData.dark();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  changeTheme(ThemeData data) {
    setState(() {
      theme = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs){
      var isLight = (prefs.getInt("light_mode") != null);
      if(isLight) {
        setState(() {
          theme = ThemeData.light();
        });
      }

      if(!prefs.containsKey("keyType")) {
        prefs.setString("keyType", Config.DEFAULT_KEY_TYPE);
      }
      if(!prefs.containsKey("keyLength")) {
        prefs.setInt("keyLength", Config.DEFAULT_KEY_LENGTH);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }

}