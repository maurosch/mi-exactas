import 'package:flutter/material.dart';

const respuesta = 
{
  "examenes":
  [
    {
      "titulo": "EXAMENES DE FEBRERO-MARZO",
      "fechas": [
        {
          "titulo": "Primera fecha",
          "inscripcion": ["2020-02-10","2020-02-14"],
          "examenes": ["2020-02-20","2020-02-21"]
        },
        {
          "titulo": "Segunda fecha",
          "inscripcion": ["2020-02-17","2020-02-22"],
          "examenes": ["2020-02-27","2020-02-28"]
        },
        {
          "titulo": "Tercera fecha",
          "inscripcion": ["2020-02-24","2020-02-28"],
          "examenes": ["2020-03-05","2020-03-06"]
        }
      ]
    },
  ]
};

class DateExam {
  const DateExam({this.title, this.inscription, this.date});
  final String title;
  final List<DateTime> inscription;
  final List<DateTime> date;

  factory DateExam.fromJson(Map<String, dynamic> json) {
    return DateExam(
      title: json['titulo'] as String,
      inscription: json['inscripcion'].map<DateTime>( (d) => DateTime.parse(d) ).toList() as List<DateTime>,
      date: json['examenes'].map<DateTime>( (d) => DateTime.parse(d) ).toList() as List<DateTime>,
    );
  }
}
class Exams {
  const Exams({this.title, this.datesExams});
  final String title;
  final List<DateExam> datesExams;

  factory Exams.fromJson(Map<String, dynamic> json) {
    return Exams(
      title: json['titulo'] as String,
      datesExams: json['fechas'].map<DateExam>( (d) => DateExam.fromJson(d) ).toList() as List<DateExam>,
    );
  }
} 

class ImportantDates extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    var exams = respuesta['examenes'].map( (d) => Exams.fromJson(d) ).toList();
    //exams.forEach((element) => (print(element.title)));
    
    return 
    Padding(
      padding: EdgeInsets.all(20),
      child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: 
            exams.map(
              (elem) => (
                RichText(
                  text: TextSpan(
                    children: 
                      <TextSpan>[
                      TextSpan(
                        text:elem.title+'\n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      )]+
                      elem.datesExams.map((dateExams) => (
                        [
                          TextSpan(
                            text:dateExams.title+'\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          TextSpan(
                            text:
                            'Semana de inscripción:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          TextSpan(
                            text:
                            dateExams.inscription[0].day.toString()
                            +' al '+dateExams.inscription[1].day.toString()+'\n'
                          ),
                          TextSpan(
                            text:
                            'Examenes:'+dateExams.date[0].day.toString()
                            +' al '+dateExams.date[1].day.toString()+'\n'
                          ),
                        ]
                      )).toList().expand((i)=>i).toList(),
                  )
                )
              )
            ).toList(),
            
          /*
            exams.map( (d) => 
              (
                Column(
                  children:[
                    Text(d.title),
                    Text(d.title)
                  ]
                )
              )
            ).toList(),*/
        )
    );
    
  }
}