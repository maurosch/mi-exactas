import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:plan_estudios/database/events.dart';
import 'package:plan_estudios/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({Key? key}) : super(key: key);

  @override
  _NotificationsSettings createState() => _NotificationsSettings();
}

class _NotificationsSettings extends State<NotificationsSettings> {
  SharedPreferences? prefs;
  bool? finalesNotifications;
  getData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() => {
          finalesNotifications = prefs!.getBool('finalesNotifications') ?? false
        });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(context) {
    if (finalesNotifications == null) return Container();
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
                            "Notificar fecha de finales (2 semanas antes)"),
                        value: finalesNotifications!,
                        onChanged: (v) async {
                          FirebaseMessaging messaging =
                              FirebaseMessaging.instance;
                          if (v == true) {
                            await messaging.subscribeToTopic('Finales');
                          } else {
                            await messaging.unsubscribeFromTopic('Finales');
                          }

                          setState(() => {finalesNotifications = v});

                          await prefs!.setBool('finalesNotifications', true);

                          if (v == true)
                            notificationMessage(ctx, "Notificación agregada");
                          else
                            notificationMessage(ctx, "Notificación removida");
                        },
                      ),
                    ]))));
  }
}
