import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class Decrypt extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return DecryptState();
  }
}

class DecryptState extends State<Decrypt> {

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final PGPService _service =  PGPService();
  final List<PGP> _keys = List<PGP>();
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String result;
  final UtilsService _utils = new UtilsService();


  @override
  void initState() {
    super.initState();
    Store.getKeys().then((List<PGP> value){
      value.forEach((element) {
        setState(() {
          _keys.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
      appBar: AppBar(
        title: Text("Decrypt message"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              ClipboardManager.copyToClipBoard(_controller.text);
              _utils.showSnackbar(builderContext, "Message copied to clipboard");
            },
          ),
          IconButton(
            icon: Icon(Icons.lock_open),
            onPressed: () async {
              if (isLoading) {
                return;
              }
              if (_fbKey.currentState.saveAndValidate()) {
                setState(() {
                  isLoading = true;
                });
                
                String message = _fbKey
                    .currentState.value["message"]
                    .toString();

                String result;
                for(int i = 0; i < _keys.length; i++)  {
                  try{
                    result = await _service.decrypt(message, _keys.elementAt(i));
                    if(result != null) {
                      break;
                    }
                  }catch(e) {
                    if(e.code == "logic_error") {
                      _utils.showSnackbar(builderContext, e.message);
                      break;
                    }
                  }
                }

                if(result == null) {
                  _utils.showSnackbar(builderContext, "Cannot decrypt. Contacts keys does not match this message");
                  return;
                }

                setState(() {
                  isLoading = false;
                  _controller.text = result;
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
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              children: [
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "message",
                        readOnly: isLoading,
                        minLines: 1,
                        maxLines: null,
                        controller: _controller,
                        maxLengthEnforced: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: "PGP message",
                        ),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ],
                  ),
                ),
              ]
          );
        },
      )
    );
  }
}