import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/pgp_service.dart';
import 'package:yapgp/services/utils_service.dart';

class AddContact extends StatefulWidget {
  @override
  AddContactState createState() {
    return AddContactState();
  }
}

class AddContactState extends State<AddContact> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  PGPService _service = new PGPService();
  final List<PGP> _contacts = new List<PGP>();
  final UtilsService _utils = new UtilsService();

  @override
  void initState() {
    super.initState();
    Store.getContacts().then((List<PGP> value) {
      value.forEach((element) {
        _contacts.add(element);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    BuildContext builderContext;

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Contact"),
          actions: <Widget>[
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

                  String pubKey = _fbKey
                      .currentState.value["public_key"]
                      .toString();
                  PGP exist;
                  _contacts.forEach((element) {
                    if (element.publicKey == pubKey) {
                      exist = element;
                    }
                  });

                  if (exist != null) {
                    _utils.showSnackbar(builderContext, "${exist.name} already exist in your contact list");
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  _service
                      .identity(
                    _fbKey.currentState.value["public_key"]
                        .toString(),
                  )
                      .then(Store.addContact)
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
            return Container(
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FormBuilder(
                    key: _fbKey,
                    child: Flexible(
                      child: FormBuilderTextField(
                          attribute: "public_key",
                          readOnly: isLoading,
                          minLines: 1,
                          maxLines: null,
                          maxLengthEnforced: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: "PGP Public Key",
                              helperText: "Insert a valid public key"
                          ),
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                        ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
