import 'package:flutter/material.dart';
import '../../models.dart';
import 'package:plan_estudios/database/main.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<Event> _selectedEvents = [];
  Map<DateTime, List<Event>> _events = Map<DateTime, List<Event>>();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final _firstDay = DateTime.now().subtract(Duration(days: 365));
  final _lastDay = DateTime.now().add(Duration(days: 365));

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    DbHelper db = DbHelper();
    var aux = await db.getEvents();
    print(aux);
    var now = DateTime.now();
    setState(() {
      _events = aux;
      _selectedEvents = aux[DateTime(now.year, now.month, now.day)] ?? [];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print(selectedDay);
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents = _events[removeFormat(selectedDay)] ?? [];
      });
    }
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Row(
        children: events.map((event) {
      return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 0.3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: event.color,
          ));
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TableCalendar<Event>(
        locale: 'es',
        eventLoader: (day) => _events[day] ?? [],
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.none,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle().copyWith(color: Colors.purple[300]),
          holidayTextStyle: TextStyle().copyWith(color: Colors.blue[800]),
          todayDecoration:
              BoxDecoration(color: Colors.orange[600], shape: BoxShape.circle),
          selectedDecoration:
              BoxDecoration(color: Colors.teal[600], shape: BoxShape.circle),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle().copyWith(color: Colors.white),
          weekendStyle: TextStyle().copyWith(color: Colors.purple[300]),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        /*calendarBuilders: CalendarBuilders(
            singleMarkerBuilder: (context, date, Event event) {
          return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ));
        }
            /*markerBuilder: (context, date, events) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: 8,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children.length == 0 ? null : children[0];
        },*/
            ),*/
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _selectedDay,
      ),
      Expanded(child: _buildEventList())
    ]);
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
                  border: Border.all(width: 0.8, color: event.color),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(event.text.toString()),
                ),
              ))
          .toList(),
    );
  }
}
