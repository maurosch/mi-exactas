import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
//import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart' as parser;
import '../../models.dart';
import 'card_sport_game.dart';
//import 'important_dates.dart';
import 'package:plan_estudios/database.dart';

import 'package:table_calendar/table_calendar.dart';



class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<SportGame> sportGame;
  var _calendarController;
  List<Event> _selectedEvents = [];
  DateTime _currentDate;
  Map<DateTime, List> _events = Map<DateTime, List>();

  @override
  void initState(){
    _calendarController = CalendarController();
    getData();
    super.initState(); 
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  getData() async{
    DbHelper db = DbHelper();
    var aux = await db.getEvents();
    var now = DateTime.now();
    setState(() {
      _events = aux;
      _selectedEvents = aux[ DateTime(now.year, now.month, now.day) ] ?? [];
    });
  }
  
  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Row(
      children:
      events.map( (event) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 0.3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(event.colorHex),
          )
        );}).toList()
      );
  }


  @override
  Widget build(BuildContext context)
  {
    super.build(context);
    return Column(
      children: [
        _buildTableCalendarWithBuilders(),
        Expanded(child:_buildEventList())
      ]
    ) ;
    
    
    /*   FutureBuilder<SportGame>(
          future: sportGame,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CardSportGame(data:snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return //CircularProgressIndicator();
              Card( 
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), 
                child: 
                  Padding( 
                    padding: EdgeInsets.all(45), 
                    child: Center(
                      child: CircularProgressIndicator()
                    )
                  )
              );
          },
        ),*/
        
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'es',
      calendarController: _calendarController,
      events: _events,
      startDay: DateTime(DateTime.now().year,1,1),
      endDay: DateTime(DateTime.now().year,12,31),
      
      
      //holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      //formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.none,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.purple[300]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
        todayColor: Colors.orange[600],
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle().copyWith(color: Colors.white),
        weekendStyle: TextStyle().copyWith(color: Colors.purple[300]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: 8,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: _onDaySelected,
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }


  
  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8, color: Color(event.colorHex)),
                  borderRadius: BorderRadius.circular(8.0),
                  
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(event.text.toString()),
                ),
              ))
          .toList(),
    );
  }
}

Future<SportGame> getData() async { 
  http.Response response = await http.get('https://resultados.lapaginamillonaria.com/futbol/');
  dom.Document document = parser.parse(response.body);
  var auxTime = document.getElementsByClassName("match").first
          .getElementsByClassName("date").first
          .getElementsByTagName("span").first.innerHtml.trim();

  auxTime = auxTime.substring(0, auxTime.length-1) + " " +
            document.getElementsByClassName("match").first
            .getElementsByClassName("date-moment").first.attributes["data-time"].trim();
  return SportGame(
    localTeam: document.getElementsByClassName("match").first
          .getElementsByClassName("team home").first
          .getElementsByClassName("name").first.innerHtml.trim(),
    visitTeam: document.getElementsByClassName("match").first
          .getElementsByClassName("team away").first
          .getElementsByClassName("name").first.innerHtml.trim(),
    time: DateTime.parse(auxTime),
    localImage: document.getElementsByClassName("match").first
          .getElementsByClassName("team home").first
          .getElementsByTagName("img").first.attributes["src"].trim(),
    visitImage: document.getElementsByClassName("match").first
          .getElementsByClassName("team away").first
          .getElementsByTagName("img").first.attributes["src"].trim(),
  );
}

