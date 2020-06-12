import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/utils_service.dart';
import 'package:yapgp/views/add_contact.dart';
import 'package:yapgp/views/encrypt.dart';
import 'package:yapgp/views/verify_sign.dart';

class Contacts extends StatefulWidget {
  @override
  ContactsState createState() {
    return ContactsState();
  }
}

class ContactsState extends State<Contacts> {
  final UtilsService _utils = new UtilsService();
  final List<PGP> _contacts = new List<PGP>();

  @override
  void initState() {
    super.initState();
    Store.getContacts().then((List<PGP> value) {
      value.forEach((element) {
        setState(() {
          _contacts.add(element);
        });
      });
    });
  }

  void addContact(PGP contact) {
    setState(() {
      _contacts.add(contact);
    });
  }

  void removeContact(PGP contact) {
    setState(() {
      _contacts.removeAt(_contacts.indexOf(contact));
    });
    Store.syncContacts(_contacts);
  }

  Widget _emptyState() {
    return _utils.getEmptyState("No contacts", "Click + to start adding contacts", Icons.contacts);
  }


  @override
  Widget build(BuildContext context) {
    ExpansionTile makeListTile(int _index) {
      final PGP contact = _contacts.elementAt(_index);
      return ExpansionTile(
        title: Text(
          _contacts.elementAt(_index).name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_contacts.elementAt(_index).email),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _utils.showSnackbar(context,
                      "${contact.name} public key copied to clipboard");
                  ClipboardManager.copyToClipBoard(contact.publicKey);
                },
                icon: Icon(Icons.content_copy),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Encrypt(contact)),
                  );
                },
                icon: Icon(Icons.message),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VerifySignature(contact)),
                  );
                },
                icon: Icon(Icons.verified_user),
              ),
              IconButton(
                color: Colors.redAccent,
                icon: Icon(Icons.delete),
                onPressed: () {
                  _utils.confirmationDialog(context, "Delete contact",
                      "Are you sure you want to remove ${contact.name}?", () {
                    removeContact(contact);
                    Navigator.of(context).pop();
                  }, () {
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

    Card makeCard(int _index) => Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            child: makeListTile(_index),
          ),
        );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            PGP contact = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddContact()),
            );
            if (contact != null) {
              addContact(contact);
            }
          },
          child: Icon(Icons.add)),
      body: _contacts.length == 0 ? _emptyState() : Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  return makeCard(_contacts.length - 1 - index);
                },
              ),
            ),
    );
  }
}
