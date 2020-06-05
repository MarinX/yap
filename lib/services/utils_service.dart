import 'package:flutter/material.dart';

class UtilsService {

  void showSnackbar(BuildContext context, String title) {
    final snackBar = SnackBar(
        content: Text(title));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void confirmationDialog(BuildContext context, String title, String desc, VoidCallback onYes, VoidCallback onNo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(desc),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: onNo,
              ),
              FlatButton(
                child: Text("Yes"),
                onPressed: onYes,
              )
            ],
          );
        }
    );
  }

  Widget getEmptyState(String title, String subtitle, IconData icon) {
    return SizedBox.expand(
      child: Center(
          child: Opacity(
            opacity: 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon),
                SizedBox(height: 5),
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(subtitle)
              ],
            ),
          )),
    );
  }
}