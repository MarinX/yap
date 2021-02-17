import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapgp/main.dart';
import 'package:yapgp/models/config.dart';
import 'package:flutter_screen_lock/lock_screen.dart';

class Settings extends StatefulWidget {

  @override
  SettingsState createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool useLightTheme = false;
  String _keyType = Config.DEFAULT_KEY_TYPE;
  int _keyLength = Config.DEFAULT_KEY_LENGTH;
  String _pinLock = "";

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs){
      setState(() {
        useLightTheme = (prefs.getInt("light_mode") != null) as bool;
        _keyLength = prefs.getInt("keyLength");
        _keyType = prefs.getString("keyType");
        _pinLock = prefs.getString("pinlock");
        if(_pinLock == null) {
          _pinLock = "";
        }
      });
    });
  }

  Future<void> _useLightMode(bool value) async {
    final SharedPreferences prefs = await _prefs;
    if(value) {
      prefs.setInt("light_mode", 1);
      MyApp.setTheme(context, ThemeData.light());
    }else {
      prefs.remove("light_mode");
      MyApp.setTheme(context, ThemeData.dark());
    }
    setState(() {
      useLightTheme = value;
    });
  }

  void _changeKeyTypeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String _selectedKeyType = _keyType;
          return AlertDialog(
            title: Text("Change key type"),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  child: DropdownButton(
                    isExpanded: true,
                    value: _selectedKeyType,
                    items: Config.keyTypes.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKeyType = value;
                      });

                    },
                  ),
                );
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  _prefs.then((prefs){
                    prefs.setString("keyType", _selectedKeyType);
                    setState(() {
                      _keyType = _selectedKeyType;
                    });
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        }
    );
  }

  void _changeKeyLengthDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int _selectedKeyLength = _keyLength;
          return AlertDialog(
            title: Text("Change RSA key length"),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  child: DropdownButton(
                    isExpanded: true,
                    value: _selectedKeyLength,
                    items: Config.keyLengths.map((int value) {
                      return new DropdownMenuItem<int>(
                        value: value,
                        child: new Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKeyLength = value;
                      });

                    },
                  ),
                );
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  _prefs.then((prefs){
                    prefs.setInt("keyLength", _selectedKeyLength);
                    setState(() {
                      _keyLength = _selectedKeyLength;
                    });
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          );
        }
    );
  }

  Future<void>  _changePinLock(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    if(_pinLock.isEmpty) {
      showConfirmPasscode(
        context: context,
        backgroundColor: Colors.grey.shade900,
        backgroundColorOpacity: 1,
        confirmTitle: 'Confirm the passcode.',
        onCompleted: (context, verifyCode) {
          setState(() {
            _pinLock = verifyCode;
          });
          // Please close yourself
          Navigator.of(context).maybePop();
          prefs.setString("pinlock", _pinLock);
        },
      );
      return;
    }
    setState(() {
      _pinLock = "";
    });
    prefs.remove("pinlock");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[
             Padding(
               padding: const EdgeInsets.all(16),
               child: Text(
                 "Theme",
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
             ),

             SwitchListTile(
               title: Text("Light Mode"),
               value: useLightTheme,
               onChanged: (bool change) => {_useLightMode(change)}
             ),
             Padding(
               padding: const EdgeInsets.all(16),
               child: Text(
                 "Key Generate",
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
             ),
             ListTile(
               title: Text("Key type"),
               subtitle: Text(_keyType),
               onTap: () {
                 _changeKeyTypeDialog(context);
               },
             ),
             ListTile(
               title: Text("RSA length"),
               subtitle: Text(_keyLength.toString()),
               onTap: () {
                 _changeKeyLengthDialog(context);
               },
             ),
             ListTile(
               title: Text("PIN Lock"),
               subtitle: Text(_pinLock.isEmpty ? "Not set" : _pinLock),
               onTap: () {
                 _changePinLock(context);
               },
             ),
        ],
      )
    );
  }
}