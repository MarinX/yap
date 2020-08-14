import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/signature.dart' as PGPSig;
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class CreateSignature extends StatefulWidget {

  PGP mykey;

  CreateSignature(this.mykey);

  @override
  CreateSignatureState createState() {
    return CreateSignatureState();
  }
}

class CreateSignatureState extends State<CreateSignature> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _controller = TextEditingController();
  final UtilsService _utils = new UtilsService();
  final PGPService _service =  PGPService();
  bool isLoading = false;
  PGP _key;

  @override
  void initState() {
    super.initState();
    _key = widget.mykey;
  }

  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
        appBar: AppBar(
          title: Text("Create signature"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                ClipboardManager.copyToClipBoard(_controller.text);
                _utils.showSnackbar(builderContext, "Message copied to clipboard");
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
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

                  _service.signature(_key.privateKey,_key.passphrase, message).then((PGPSig.Signature value) {
                    setState(() {
                      isLoading = false;
                      _controller.text = value.message;
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
                            labelText: "Create signature using",
                          ),
                          initialValue: "${_key.name}(${_key.email})",
                          validators: [
                            FormBuilderValidators.required(),
                          ],
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
                ]
            );
          },
        )
    );
  }

}