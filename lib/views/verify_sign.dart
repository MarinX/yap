import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/signature.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class VerifySignature extends StatefulWidget {

  PGP contact;

  VerifySignature(this.contact);

  @override
  VerifySignatureState createState() {
    return VerifySignatureState();
  }
}

class VerifySignatureState extends State<VerifySignature> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _controller = TextEditingController();
  final UtilsService _utils = new UtilsService();
  final PGPService _service =  PGPService();
  bool isLoading = false;
  PGP _key;
  Signature sig;

  @override
  void initState() {
    super.initState();
    _key = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
        appBar: AppBar(
          title: Text("Verify signature"),
          actions: <Widget>[
            sig != null ? IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  sig = null;
                  _controller.clear();
                });
              },
            ) :
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

                  _service.verify(_key.publicKey, message).then((Signature value) {
                    setState(() {
                      isLoading = false;
                      sig = value;
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
                  sig != null ? Column(
                    children: <Widget>[
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Signature OK', style: TextStyle(color: Colors.green),),
                              subtitle: Text(sig.message),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text('Signed at'),
                              subtitle: Text(sig.datetime.toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ) :
                  FormBuilder(
                    key: _fbKey,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          attribute: "for",
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Verify signature for",
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
                          controller: _controller,
                          maxLengthEnforced: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: "Signature Message",
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