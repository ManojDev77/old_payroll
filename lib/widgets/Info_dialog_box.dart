import 'package:flutter/material.dart';

void showDialogTemplate(BuildContext context, String title, String subtitle,
    String gif, Color color, String buttonText) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 40,
        child: AlertDialog(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                gif,
                width: 175,
              ),
              Text(subtitle, style: const TextStyle(color: Colors.white60)),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
