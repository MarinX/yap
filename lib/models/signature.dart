class Signature {
  String message;
  DateTime datetime;

  Signature({this.message, this.datetime});

  Signature.fromJson(Map<String, dynamic> json) {
    message = json['msg'];
    datetime = new DateTime.fromMillisecondsSinceEpoch(json['time'] * 1000);
    print(json['time']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.message;
    data['time'] = this.datetime;
    return data;
  }
}
