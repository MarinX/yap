import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class Encrypt extends StatefulWidget {
  PGP contact;

  Encrypt(this.contact);

  @override
  State<StatefulWidget> createState() {
    return EncryptState(this.contact);
  }
}

class EncryptState extends State<Encrypt> {

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  PGP contact;
  final PGPService _service =  PGPService();
  final List<PGP> _keys = List<PGP>();
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String result;
  final UtilsService _utils = new UtilsService();
  bool showWarning = false;

  EncryptState(this.contact);

  @override
  void initState() {
    super.initState();
    Store.getKeys().then((List<PGP> value){
      value.forEach((element) {
        setState(() {
          _keys.add(element);
        });
      });

      // add additional
     setState(() {
       _keys.add(PGP(publicKey: "", privateKey: "-1", name: "Don't use my key for signing", email: "⚠"));
     });

    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
      appBar: AppBar(
        title: Text("Encrypt message"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              ClipboardManager.copyToClipBoard(_controller.text);
              _utils.showSnackbar(builderContext, "Message copied to clipboard");
            },
          ),
          IconButton(
            icon: Icon(Icons.lock),
            onPressed: (){
              if (isLoading) {
                return;
              }
              if (_fbKey.currentState.saveAndValidate()) {
                setState(() {
                  isLoading = true;
                  showWarning = false;
                });
                String privKey = _fbKey
                    .currentState.value["key"]
                    .toString();
                String message = _fbKey
                    .currentState.value["message"]
                    .toString();
                PGP mykey  = _keys.where((element) => element.privateKey == privKey).first;

                if(mykey.privateKey == "-1") {
                  // use unsigned encryption
                  _service.encryptUnsigned(message, contact).then((value) {
                    setState(() {
                      isLoading = false;
                      _controller.text = value;
                    });

                  }).catchError((e){
                    setState(() {
                      isLoading = false;
                    });
                    _utils.showSnackbar(builderContext, e.message);
                  });
                  return;
                }

                _service.encrypt(message, mykey, contact).then((value) {
                  setState(() {
                    isLoading = false;
                    _controller.text = value;
                  });

                }).catchError((e){
                  setState(() {
                    isLoading = false;
                  });
                  _utils.showSnackbar(builderContext, e.message);
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
                        attribute: "for",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Encrypt for",
                        ),
                        initialValue: "${contact.name}(${contact.email})",
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                      FormBuilderDropdown(
                        attribute: "key",
                        decoration: InputDecoration(labelText: "My key"),
                        hint: Text('Select Key'),
                        validators: [FormBuilderValidators.required()],
                        onChanged: (val){
                          if(val == "-1" && !showWarning) {
                            setState(() {
                              showWarning = true;
                            });
                          }else if(val != "-1" && showWarning) {
                            setState(() {
                              showWarning = false;
                            });
                          }

                        },
                        items: _keys
                            .map((key) => DropdownMenuItem(
                            value: key.privateKey,
                            child: Text("${key.name}(${key.email})")
                        )).toList(),
                      ),
                      FormBuilderTextField(
                        attribute: "message",
                        readOnly: isLoading,
                        minLines: 1,
                        maxLines: null,
                        controller: _controller,
                        maxLengthEnforced: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: "Message",
                        ),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showWarning,
                    child: Container(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                              child: new Text("⚠\nIn most cases, PGP software will fail to decrypt this message as they look for signed message.\nProceed with caution.", textAlign: TextAlign.center,))
                        ],
                      ),
                    )
                ),
              ]
          );
        },
      )
    );
  }
}