import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context)
  {
    return Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.border_color),
              title: Text("+Exactas"),
              
            ),
            Divider(),
            ListTile(
              leading: Icon(FontAwesomeIcons.instagram),
              title: Text("Seguinos en Instagram"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Configuración"),
            ),
          ],
        ),
      );
    }
}