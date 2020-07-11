import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapgp/models/config.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';
import 'package:yapgp/views/import_key.dart';


class CreateKey extends StatefulWidget {

  @override
  CreateKeyState createState() {
    return CreateKeyState();
  }
}

class CreateKeyState extends State<CreateKey> {
  final UtilsService _utils = new UtilsService();

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _keyType = Config.DEFAULT_KEY_TYPE;
  int _keyLength = Config.DEFAULT_KEY_LENGTH;

  final PGPService _service = PGPService();



  @override
  void initState() {
    super.initState();
    _prefs.then((prefs){
      _keyType = prefs.getString("keyType");
      _keyLength = prefs.getInt("keyLength");
    });
  }


  @override
  Widget build(BuildContext context) {
    BuildContext buildContext;
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Key"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_fbKey.currentState.saveAndValidate()) {
                setState(() {
                  isLoading = true;
                });
                String name = _fbKey.currentState.value["name"].toString();
                String email = _fbKey.currentState.value["email"].toString();
                String password = _fbKey.currentState.value["password"].toString();

                _service.generateKey(
                  name,
                  email,
                  password,
                  _keyType,
                  _keyLength,
                ).then(Store.addKey).then((key){
                  Navigator.pop(buildContext, key);
                }).catchError((err){
                  setState(() {
                    isLoading = false;
                  });
                  _utils.showSnackbar(buildContext, err.message);
                });

              }
            },
          )
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          buildContext = context;
          return isLoading ? Center(child: CircularProgressIndicator()) : Container(
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "name",
                        decoration: InputDecoration(labelText: "Name"),
                        maxLines: 1,
                        readOnly: isLoading,
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                      FormBuilderTextField(
                        attribute: "email",
                        decoration: InputDecoration(labelText: "Email"),
                        maxLines: 1,
                        readOnly: isLoading,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ],
                      ),
                      FormBuilderTextField(
                        attribute: "password",
                        maxLines: 1,
                        readOnly: isLoading,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Password"),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                      FormBuilderTextField(
                        attribute: "password_confirm",
                        maxLines: 1,
                        readOnly: isLoading,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Confirm password"),
                        validators: [
                          FormBuilderValidators.required(),
                          (val) {
                            String password = _fbKey.currentState.value["password"].toString();
                            if(val != password) {
                              return "Passwords does not match";
                            }
                            return null;
                          }
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(30.0),
                      ),
                      FlatButton.icon(
                          onPressed: () async {
                            PGP key = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ImportKey()),
                            );
                            if(key != null) {
                              Navigator.pop(context, key);
                            }
                          },
                          icon: Icon(Icons.help_outline),
                          label: Text("Need to import key? Click here"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      )
    );
  }
}
