import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plan_estudios/screens/main.dart';

Future<void> main() async => {
      WidgetsFlutterBinding.ensureInitialized(),
      await initializeDateFormatting(),
      runApp(App())
    };

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
