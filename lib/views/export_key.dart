import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class ExportKey extends StatefulWidget {

  PGP exKey;

  ExportKey(this.exKey);

  PGP get ex_key => exKey;

  @override
  ExportKeyState createState() {
    return ExportKeyState();
  }
}

class ExportKeyState extends State<ExportKey> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _controller = TextEditingController();
  bool _confirmed = false;

  PGP _key;
  final UtilsService _utils = new UtilsService();

  @override
  void initState() {
    super.initState();
    _key = widget.exKey;

  }

  Widget _warningWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            OutlineButton.icon(
              padding: EdgeInsets.all(30.0),
              onPressed: () async {
                setState(() {
                  _confirmed = true;
                  _controller.text = _key.privateKey;
                });
              },
              icon: Icon(Icons.warning),
              label: Text("Show me my private key"),
            ),
          ],
        ),
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
        appBar: AppBar(
          title: Text("Export ${_key.name}"),
          actions: <Widget>[
            if(_confirmed) IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                ClipboardManager.copyToClipBoard(_key.privateKey);
                _utils.showSnackbar(builderContext, "Private key copied to clipboard");
              },
            )
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            builderContext = context;
            if(!_confirmed) {
              return _warningWidget();
            }
            return ListView(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  child: Column(children: [
                    FormBuilderTextField(
                      controller: _controller,
                      attribute: "private_key",
                      readOnly: true,
                      minLines: 1,
                      maxLines: null,
                      maxLengthEnforced: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                          labelText: "PGP Private Key",
                          helperText: "Copy this private key somewhere safe!"),
                    ),
                  ]),
                ),
              ],
            );
          },
        ));
  }

}
