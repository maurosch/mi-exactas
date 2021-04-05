import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_estudios/screens/Settings/notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'change_degree.dart';
import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Configuración')),
        body: Builder(
            builder: (ctx) => Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CambioDeCarrera(context, ctx),
                      Divider(),
                      Notificaciones(context, ctx),
                      Divider(),
                      Valoranos(),
                      Divider(),
                      Sugerencias(context),
                      Divider(),
                    ]))));
  }
}

void showSnackBar(context, degreeName) {
  final SnackBar snackBar = SnackBar(
      content: Text("Carrera cambiada a $degreeName"),
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: 2000));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> alertSuggestion(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => AlertDialog(
      title: Text("Hola :)"),
      content: Text(
          "Esta aplicación es de código abierto, si sabes programar podes hacer pull request. También me podes dejar un mail con la sugerencia."),
      actions: [
        TextButton(
          child: Text("Link Repo"),
          onPressed: () => _launchURL('https://github.com/maurosch/mi-exactas'),
        ),
        TextButton(
          child: Text("Mandar mail"),
          onPressed: () => _launchURL(
              'mailto:mschiavinato@dc.uba.ar?subject=Sugerencia Mi-Exactas'),
        )
      ],
    ),
  );
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// ignore: non_constant_identifier_names
Widget CambioDeCarrera(context, ctx) => ListTile(
      leading: Icon(FontAwesomeIcons.penSquare),
      title: Text("Cambiar de carrera"),
      onTap: () => {
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangeDegreeScreen()))
            .then((value) {
          if (value != null) showSnackBar(ctx, value);
        })
      },
    );

// ignore: non_constant_identifier_names
Widget Notificaciones(context, ctx) => ListTile(
    //TODO: TERMINAR
    leading: Icon(FontAwesomeIcons.solidBell),
    title: Text("Notificaciones"),
    onTap: () => {
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationsSettings()))
            .then((value) {
          if (value != null) showSnackBar(ctx, value);
        })
      });

// ignore: non_constant_identifier_names
Widget Valoranos() => ListTile(
    leading: Icon(FontAwesomeIcons.solidStar),
    title: Text("Valoranos"),
    onTap: () async => {
          if (await inAppReview.isAvailable())
            {inAppReview.requestReview()}
          else
            {
              _launchURL(
                  "https://play.google.com/store/apps/details?id=com.plan_estudios_exactas.app")
            }
        });

// ignore: non_constant_identifier_names
Widget Sugerencias(context) => GestureDetector(
    child: ListTile(
        leading: Icon(FontAwesomeIcons.solidHeart),
        title: Text("¿Tenés alguna sugerencia?")),
    onTap: () => alertSuggestion(context));
