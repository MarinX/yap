class Signature {
  String message;

  Signature({this.message});

  Signature.fromJson(Map<String, dynamic> json) {
    message = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.message;
    return data;
  }
}
