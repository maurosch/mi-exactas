import 'package:flutter/material.dart';
import '../../models.dart';
import 'package:plan_estudios/database.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var _calendarController;
  List<Event> _selectedEvents = [];
  Map<DateTime, List> _events = Map<DateTime, List>();

  @override
  void initState() {
    _calendarController = CalendarController();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
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

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      _selectedEvents = events.length == 0 ? [] : events;
    });
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
    super.build(context);
    return Column(children: [
      _buildTableCalendarWithBuilders(_events),
      Expanded(child: _buildEventList())
    ]);
  }

  Widget _buildTableCalendarWithBuilders(_events) {
    return TableCalendar(
      locale: 'es',
      calendarController: _calendarController,
      events: _events,
      startDay: DateTime(DateTime.now().year, 1, 1),
      endDay: DateTime(DateTime.now().year, 12, 31),
      initialCalendarFormat: CalendarFormat.month,
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