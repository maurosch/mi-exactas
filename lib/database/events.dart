import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import '../models.dart';
import 'package:timezone/timezone.dart' as tz;

int getHashDate(DateTime v) => v.day * 1000000 + v.month * 10000 + v.year;

Future<LinkedHashMap<DateTime, List<Event>>> getEvents() async {
  LinkedHashMap<DateTime, List<Event>> response = LinkedHashMap<DateTime,
          List<Event>>(
      equals: isSameDay,
      hashCode:
          getHashDate); //Usamos linkedHashMap para no tener en cuenta la hora y segundos

  try {
    final data = await getListEvents();

    for (var i in data) {
      var event = Event(text: i.text, color: Colors.green[400]!, type: i.type);
      DateTime aux = i.dateStart.subtract(Duration(days: 1));
      do {
        aux = aux.add(Duration(days: 1));
        if (response[i.dateEnd] == null)
          response[aux] = [event];
        else
          response[aux]!.add(event);
      } while (i.dateEnd.day != aux.day || i.dateEnd.month != aux.month);
    }

    //await addEventsNotifications(data);
  } catch (ex) {
    print("Error al obtener notificaciones");
  }

  return response;
}

Future<List<EventFb>> getListEvents() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  return (await firestore.collection('events').get()) //TODO: Catch error
      .docs
      .map((v) => EventFb.fromJson(v.data()!))
      .toList();
}

Future<void> addEventsNotifications(List<EventFb> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool finalesNotifications = prefs.getBool('finalesNotifications') ?? false;

  if (finalesNotifications) {
    final Map<String, bool> mapaNotificacionesPendientes =
        new Map<String, bool>();
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    pendingNotificationRequests.forEach((element) {
      String index = element.payload!;
	  
      mapaNotificacionesPendientes[index] = true;
    });

    for (var i in data) {
      if (i.type == TypeEvent.finales) {
        if (mapaNotificacionesPendientes[
                getHashNotification(i.dateStart, i.type).toString()] !=
            true) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
              0,
              'Fecha de finales',
              'En dos semanas abren las inscripciones a finales',
              tz.TZDateTime.from(i.dateStart, tz.local)
                  .subtract(Duration(days: 12))
                  .add(Duration(hours: 12)),
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                      '0', "Finales", "Alertar dos semanas antes del final")),
              androidAllowWhileIdle: true,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: getHashNotification(i.dateStart, i.type).toString());
          mapaNotificacionesPendientes[
              i.dateStart.toString() + i.type.toString()] = true;
        }
      }
    }
  }
}

int getHashNotification(DateTime start, TypeEvent type) =>
    getHashDate(start) * 10 + type.index;

String getChannelName(TypeEvent type) {
  if (type == TypeEvent.finales) return "Finales";
  return "";
}

String getChannelDescription(TypeEvent type) {
  if (type == TypeEvent.finales) return "Alertar dos semanas antes del final";
  return "";
}
