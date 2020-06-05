import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class ImportKey extends StatefulWidget {
  @override
  ImportKeyState createState() {
    return ImportKeyState();
  }
}

class ImportKeyState extends State<ImportKey> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  PGPService _service = new PGPService();
  final List<PGP> _keys = new List<PGP>();
  final UtilsService _utils = new UtilsService();

  @override
  void initState() {
    super.initState();
    Store.getKeys().then((List<PGP> value) {
      value.forEach((element) {
        _keys.add(element);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
        appBar: AppBar(
          title: Text("Import key"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (isLoading) {
                  return;
                }

                if (_fbKey.currentState.saveAndValidate()) {
                  setState(() {
                    isLoading = true;
                  });

                  String privKey =
                      _fbKey.currentState.value["private_key"].toString();
                  PGP exist;
                  _keys.forEach((element) {
                    if (element.privateKey == privKey) {
                      exist = element;
                    }
                  });

                  if (exist != null) {
                    _utils.showSnackbar(builderContext,
                        "${exist.name} already exist in your key list");
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  _service
                      .import(
                        privKey,
                        _fbKey.currentState.value["password"].toString(),
                      )
                      .then((value) {
                    Navigator.pop(context, value);
                  }).catchError((e) {
                    _utils.showSnackbar(builderContext, e.message);
                    setState(() {
                      isLoading = false;
                    });
                  });
                }
              },
            )
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            builderContext = context;
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  child: Column(children: [
                    FormBuilderTextField(
                      attribute: "password",
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                      maxLines: 1,
                      obscureText: true,
                      readOnly: isLoading,
                    ),
                    FormBuilderTextField(
                      attribute: "private_key",
                      readOnly: isLoading,
                      minLines: 1,
                      maxLengthEnforced: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText: "PGP Private Key",
                          helperText: "Insert a valid private key"),
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                    ),
                  ]),
                ),
              ],
            );
          },
        ));
  }
}
