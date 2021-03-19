import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//Links importantes para cada carrera. Ej: cubawiki para computacion.

/*class _LinkTextSpan extends TextSpan {

  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  _LinkTextSpan({ TextStyle style, String url, String text }) : super(
    style: style,
    text: text ?? url,
    recognizer: TapGestureRecognizer()..onTap = () {
      launch(url, forceSafariVC: false);
    }
  );
}*/


class ImportantLinks extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return 
    Padding(
      padding: EdgeInsets.all(20),
      child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Links",
              style: TextStyle(
                fontSize: 22,
                fontWeight : FontWeight.bold,
              )
            ),
            InkWell(
              child: 

                Text(
                  'CubaWiki',
                  style: TextStyle(
                  fontSize:18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline, 
                  color: Colors.blue
                  )
                ),
              onTap: () => _launchURL('https://www.cubawiki.com.ar')
            ),
          ],
        )
    );
    
  }
}

_launchURL(String url) async {
  //const url = 'https://www.cubawiki.com.ar';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}