import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Color getColorSubject(SubjectWithUserInfo v) {
  if (v.doingNow == true) return Colors.orange[800]!;

  if (v.tp == true) if (v.grade != null)
    return Color(0xff00AF89);
  else
    return Colors.purple[600]!;
  return Colors.transparent;
}

void notificationMessage(BuildContext context, String text,
    {int timeMili = 2000}) {
  final SnackBar snackBar = SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: timeMili));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


