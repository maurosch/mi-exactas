import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plan_estudios/screens/main.dart';
FirebaseApp defaultApp = await Firebase.initializeApp();

//void main() => runApp(MyApp());
void main() => initializeDateFormatting().then((_) => runApp(MyApp()));


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xff212121),
          primaryColor: Color(0xff00AF89),
          accentColor: Color(0xff00AF89),
          buttonTheme: ButtonThemeData(

            buttonColor: Color(0xff6699FF)            
          ),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Color(0xffF8F9FA),
                //displayColor: Color(0xffF8F9FA)
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.02)
          )
        ),
      home: MainScreen(),
    );
  }
}
