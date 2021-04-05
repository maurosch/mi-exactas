import 'package:flutter/material.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({Key? key}) : super(key: key);

  @override
  _NotificationsSettings createState() => _NotificationsSettings();
}

class _NotificationsSettings extends State<NotificationsSettings> {
  bool notiFinales = false;
  @override
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(title: Text('Configuración')),
        body: Builder(
            builder: (ctx) => Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SwitchListTile(
                        title: const Text(
                            "Notificar dos semanas antes de finales"),
                        value: notiFinales,
                        onChanged: (v) {
                          setState(() => {notiFinales = v});
                        },
                      ),
                    ]))));
  }
}
