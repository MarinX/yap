import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yapgp/models/pgp.dart';
import 'package:yapgp/models/signature.dart';

class PGPService {

  static final MethodChannel ch = MethodChannel("com.marinbasic/gopenpgp");

  Future<PGP> generateKey(String name, String email, String pass, String keyType, int keyLength) async {
    String result = await ch.invokeMethod("GenerateKey", {"name": name, "email": email, "passphrase": pass, "keyType": keyType, "keyLength": keyLength});
    return PGP.fromJson(jsonDecode(result));
  }

  Future<String> encrypt(String msg, PGP key, PGP contact) async {
    String result = await ch.invokeMethod("Encrypt", {"pubKey": contact.publicKey,"privKey": key.privateKey,"passphrase": key.passphrase, "message": msg});
    var json = jsonDecode(result);
    return json["message"];
  }

  Future<String> encryptUnsigned(String msg, PGP contact) async {
    String result = await ch.invokeMethod("EncryptUnsigned", {"pubKey": contact.publicKey, "message": msg});
    var json = jsonDecode(result);
    return json["message"];
  }

  Future<String> decrypt(String msg, PGP key) async {
    String result = await ch.invokeMethod("Decrypt", {"message": msg, "passphrase": key.passphrase, "privateKey": key.privateKey});
    var json = jsonDecode(result);
    return json["message"];
  }

  Future<PGP> identity(String pubKey) async {
    String result = await ch.invokeMethod("Identity", {"pubKey": pubKey.trim()});
    PGP ret = PGP.fromJson(jsonDecode(result));
    ret.publicKey = pubKey;
    return ret;
  }

  Future<PGP> import(String privateKey, String password) async {
    String result = await ch.invokeMethod("Import", {"privKey": privateKey.trim(), "passphrase": password});
    PGP ret = PGP.fromJson(jsonDecode(result));
    ret.passphrase = password;
    return ret;
  }

  Future<Signature> verify(String pubKey, String message) async {
    String result = await ch.invokeMethod("Verify", {"pubKey": pubKey.trim(), "message": message});
    Signature ret = Signature.fromJson(jsonDecode(result));
    return ret;
  }

  Future<Signature> signature(String privKey, String password, String message) async {
    String result = await ch.invokeMethod("Signature", {"privKey": privKey.trim(), "passphrase": password, "message": message});
    Signature ret = Signature.fromJson(jsonDecode(result));
    return ret;
  }
}