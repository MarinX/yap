import 'dart:convert';

List<PGP> modelUserFromJson(String str) => List<PGP>.from(json.decode(str).map((x) => PGP.fromJson(x)));
String modelUserToJson(List<PGP> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PGP {
  String publicKey;
  String privateKey;
  String name;
  String email;
  String passphrase;
  String fingerprint;
  String hexID;

  PGP({
    this.publicKey,
    this.privateKey,
    this.name,
    this.email,
    this.passphrase,
    this.fingerprint,
    this.hexID
  });

  factory PGP.fromJson(Map<String, dynamic> json) => PGP(
      publicKey: json["publicKey"],
      privateKey: json["privateKey"],
      name: json["name"],
      email: json["email"],
      passphrase: json["passphrase"],
      fingerprint: json["fingerprint"],
      hexID: json["hexID"]
  );

  Map<String, dynamic> toJson() => {
    "publicKey": publicKey,
    "privateKey": privateKey,
    "name": name,
    "email": email,
    "passphrase": passphrase,
    "fingerprint": fingerprint,
    "hexID": hexID,
  };
}