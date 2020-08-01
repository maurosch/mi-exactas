import 'dart:core';

import 'package:flutter/material.dart';

String dayToString(DateTime f)
{
  if(f.weekday == DateTime.monday)
    return "Lunes";
  if(f.weekday == DateTime.tuesday)
    return "Martes";
  if(f.weekday == DateTime.wednesday)
    return "Miércoles";
  if(f.weekday == DateTime.thursday)
    return "Jueves";
  if(f.weekday == DateTime.friday)
    return "Viernes";
  if(f.weekday == DateTime.saturday)
    return "Sábado";
  if(f.weekday == DateTime.sunday)
    return "Domingo";
}

String monthToString(DateTime f)
{
  if(f.month == DateTime.january)
    {return "Enero";}
  
  if(f.month == DateTime.february)
    {return "Febrero";}
  
  if(f.month == DateTime.march)
    {return "Marzo";}
  
  if(f.month == DateTime.april)
    {return "Abril";}
  
  if(f.month == DateTime.may)
    {return "Mayo";}
  
  if(f.month == DateTime.june)
    {return "Junio";}
  
  if(f.month == DateTime.july)
    {return "Julio";}
  
  if(f.month == DateTime.august)
    {return "Agosto";}
  
  if(f.month == DateTime.september)
    {return "Septiembre";}
  
  if(f.month == DateTime.october)
    {return "October";}
  
  if(f.month == DateTime.november)
    {return "November";}
  
  if(f.month == DateTime.december)
    {return "December";}
    
  return "Error";
}

class SportGame {
  const SportGame({this.localTeam, this.localImage, this.time, this.visitImage, this.visitTeam});
  final String localTeam;
  final String visitTeam;
  final DateTime time;
  final String localImage;
  final String visitImage;
}

class CardSportGame extends StatelessWidget{
  const CardSportGame({this.data});
  final SportGame data; 
  @override
  Widget build(BuildContext context)
  {
    return 
    Card( 
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), 
      child: 
        Padding( 
          padding: EdgeInsets.all(10), 
          child:  
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child:
                    Team(
                      text:"LOCAL",
                      teamName:data.localTeam,
                      teamImage:data.localImage
                    )
                ),

                Expanded(
                  flex: 1,
                  child:
                    Column(
                    children: [
                      Text(dayToString( data.time.toLocal() )),
                      Text(
                        data.time.toLocal().day.toString()+" de "+
                        monthToString(data.time.toLocal())
                      ),
                      Text(
                        data.time.toLocal().hour.toString()+':'+
                        data.time.toLocal().minute.toString()
                      ),
                    ]
                  ),
                ),
                
                
                Expanded(
                  flex: 1,
                  child:
                    Team(
                      text:"VISITANTE",
                      teamName:data.visitTeam,
                      teamImage:data.visitImage
                    )
                )
              ]
            )
        )
    );
    
  }
}

class Team extends StatelessWidget {
  const Team({this.text,this.teamName,this.teamImage});
  final String text, teamName, teamImage;
  @override
  Widget build(BuildContext context) {
    return 
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            SizedBox(height: 7),
            Image.network(teamImage, height: 40),
            SizedBox(height: 7),
            Text(teamName, textAlign: TextAlign.center)
          ]
        );
  }
  
}