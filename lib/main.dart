import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plan_estudios/screens/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
  return runApp(App());
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          FirebaseMessaging.instance.getToken();
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            RemoteNotification? notification = message.notification;
            AndroidNotification? android = message.notification?.android;

            if (notification != null && android != null) {
              flutterLocalNotificationsPlugin.show(
                  notification.hashCode,
                  notification.title,
                  notification.body,
                  NotificationDetails(
                    android: AndroidNotificationDetails(
                        '0', "Finales", "Alertar dos semanas antes del final"),
                  ));
            }
          });
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xff212121),
          primaryColor: Color(0xff00AF89),
          accentColor: Color(0xff00AF89),
          buttonTheme: ButtonThemeData(buttonColor: Color(0xff6699FF)),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Color(0xffF8F9FA),
                //displayColor: Color(0xffF8F9FA)
              ),
          inputDecorationTheme: InputDecorationTheme(
              filled: true, fillColor: Colors.white.withOpacity(0.02))),
      home: MainScreen(),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xff212121),
          primaryColor: Color(0xff00AF89),
          accentColor: Color(0xff00AF89),
          buttonTheme: ButtonThemeData(buttonColor: Color(0xff6699FF)),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Color(0xffF8F9FA),
                //displayColor: Color(0xffF8F9FA)
              ),
          inputDecorationTheme: InputDecorationTheme(
              filled: true, fillColor: Colors.white.withOpacity(0.02))),
      home: Text("Cargando"),
    ); //TODO: TERMINAR
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xff212121),
          primaryColor: Color(0xff00AF89),
          accentColor: Color(0xff00AF89),
          buttonTheme: ButtonThemeData(buttonColor: Color(0xff6699FF)),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Color(0xffF8F9FA),
                //displayColor: Color(0xffF8F9FA)
              ),
          inputDecorationTheme: InputDecorationTheme(
              filled: true, fillColor: Colors.white.withOpacity(0.02))),
      home: Text("Error"),
    ); //TODO: TERMINAR
  }
}
