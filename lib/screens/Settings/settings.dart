import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_degree.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({ Key key }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void showSnackBar(context, degreeName) {
    final SnackBar snackBar = SnackBar(
      content: Text("Carrera cambiada a $degreeName"),
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds:2000)
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
  
  @override 
  Widget build(BuildContext context) {
    return 
      Scaffold(
       appBar: AppBar(
         title: Text('Configuración')
       ),
       body: 
        Builder(
          builder: (ctx) =>
        Padding(
          padding: EdgeInsets.all(12.0),
          child: 
            Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ 
                ListTile(
                  leading: Icon(FontAwesomeIcons.penSquare),
                  title: Text("Cambiar de carrera"),
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => 
                      ChangeDegreeScreen())
                    ).then( (value) {if(value != null) showSnackBar(ctx, value);} )
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(FontAwesomeIcons.solidStar),
                  title: Text("Valoranos")
                ),
                Divider(),
                GestureDetector(
                  child:
                    ListTile(
                      leading: Icon(FontAwesomeIcons.solidHeart),
                      title: Text("¿Tenés alguna sugerencia?")
                    ),
                  onTap: () => alertSuggestion(context)
                ),
                Divider(),
              ]
            )
        ))
      );
  }
}

Future<void> alertSuggestion(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => 
      AlertDialog(
        title: Text("Hola :)"),
        content: Text("Esta aplicación es de código abierto, si sabes programar podes hacer pull request. También me podes dejar un mail con la sugerencia."),
        actions: [
          FlatButton(
          child: Text("Link Repo"),
          onPressed: () => _launchURL('https://github.com/maurosch/mi-exactas'),
        ),
        FlatButton(
          child: Text("Mandarme mail"),
          onPressed: () => _launchURL('mailto:mschiavinato@dc.uba.ar?subject=Sugerencia Mi-Exactas'),
        )
        ],
      ),
  );
}

_launchURL(String url) async {
  //const url = 'https://www.cubawiki.com.ar';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}