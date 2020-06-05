import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pgp.dart';

class Store {

  static List<PGP> _keys;
  static List<PGP> _contacts;

  static Future<List<PGP>> getKeys() async {
    if(_keys == null) {
        _keys = await _read("keys");
    }

    return _keys;
  }

  static Future<void> syncKeys(List<PGP> keys) async {
    _keys = keys;
    await _save('keys');
  }

  static Future<PGP> addKey(PGP key) async {
    if(_keys == null) {
      _keys = await _read('keys');
    }
    _keys.add(key);
    await _save('keys');
    return key;
  }

  static Future<List<PGP>> getContacts() async {
    if(_contacts == null) {
      _contacts = await _read("contacts");
    }
    return _contacts;
  }

  static Future<PGP> addContact(PGP contact) async {
    if(_contacts == null) {
      _contacts = await _read('contacts');
    }
    _contacts.add(contact);
    await _save('contacts');
    return contact;
  }

  static Future<void> syncContacts(List<PGP> contacts) async {
    _contacts = contacts;
    await _save("contacts");
  }


  static Future<List<PGP>> _read(String key) async {
    var _results = List<PGP>();
    var _storage = FlutterSecureStorage();
    String value = await _storage.read(key: key);
    if(value == null) {
      return _results;
    }
    final keys = jsonDecode(value);
    for(Map i in keys) {
      _results.add(PGP.fromJson(i));
    }
    return _results;
  }

  static Future<void> _save(String key) async {
    var _storage = FlutterSecureStorage();
    switch(key) {
      case "keys":
        await _storage.write(key: key, value: jsonEncode(_keys));
        break;
      case "contacts":
        await _storage.write(key: key, value: jsonEncode(_contacts));
        break;
    }
  }
}