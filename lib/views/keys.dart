import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/store.dart';
import 'package:yapgp/services/utils_service.dart';
import 'package:yapgp/views/create_sign.dart';
import 'package:yapgp/views/export_key.dart';

import 'create_key.dart';

class Keys extends StatefulWidget {
  @override
  KeysState createState() {
    return KeysState();
  }
}

class KeysState extends State<Keys> {
  List<PGP> _keys = new List<PGP>();
  final UtilsService _utils = new UtilsService();

  @override
  void initState() {
    super.initState();
    _keys.clear();
    Store.getKeys().then((List<PGP> value) {
      value.forEach((element) {
        setState(() {
          _keys.add(element);
        });
      });
    });
  }

  void addKey(PGP key) {
    setState(() {
      _keys.add(key);
    });
    Store.syncKeys(_keys);
  }

  void removeKey(PGP key) {
    setState(() {
      _keys.removeAt(_keys.indexOf(key));
    });
    Store.syncKeys(_keys);
  }

  Widget _emptyState() {
    return _utils.getEmptyState(
        "No keys", "Click + to create a new key", Icons.lock);
  }

  @override
  Widget build(BuildContext context) {
    ExpansionTile makeListTile(int _index) {
      PGP key = _keys.elementAt(_index);
      return ExpansionTile(
        title: Text(
          key.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(key.email),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _utils.showSnackbar(context,
                      "${key.name} public key copied to clipboard");
                  ClipboardManager.copyToClipBoard(key.publicKey);
                },
                icon: Icon(Icons.content_copy),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExportKey(key)),
                  );
                },
                icon: Icon(Icons.import_export),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateSignature(key)),
                  );
                },
                icon: Icon(Icons.assignment),
              ),
              IconButton(
                color: Colors.redAccent,
                icon: Icon(Icons.delete),
                onPressed: () {
                  _utils.confirmationDialog(context, "Delete key",
                      "Are you sure you want to remove ${_keys
                          .elementAt(_index)
                          .name}?",
                          () {
                        removeKey(_keys.elementAt(_index));
                        Navigator.of(context).pop();
                      }, () {
                        Navigator.of(context).pop();
                      });
                },
              )
            ],
          )
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
            PGP key = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateKey()),
            );
            if (key != null) {
              addKey(key);
            }
          },
          child: Icon(Icons.add)),
      body: _keys.length == 0
          ? _emptyState()
          : Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _keys.length,
                itemBuilder: (BuildContext context, int index) {
                  return makeCard(_keys.length - 1 - index);
                },
              ),
            ),
    );
  }
}
