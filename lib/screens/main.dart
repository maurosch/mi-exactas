import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_estudios/screens/Calendar/index.dart';
import 'package:plan_estudios/screens/Newcomers/select_degree.dart';
import 'package:plan_estudios/screens/Settings/settings.dart';
import 'package:plan_estudios/database/main.dart';
import 'package:plan_estudios/screens/StudyProgram/index.dart';
import 'package:plan_estudios/globals.dart' as globals;

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<int>? degreesDoing;
  int _page = 0;

  late TabController _tabController;
  @override
  void initState(){
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.animation!.addListener(() { 
      var value = _tabController.animation!.value.round();
      if(value != _page)
        setState(() {_page = value;}); 
    });
    _calendarScreen = CalendarScreen();
    getData();
    super.initState();
  }

  getData() async{
    var db = DbHelper();
    var aux = await db.getDegreesDoingIds();
    setState(() {
      degreesDoing = aux;
      _studyProgramScreen = StudyProgramScreen(degreeIds: aux);
      //_calendarScreen = CalendarScreen();
    });
  }

  var _studyProgramScreen, _calendarScreen;

  Widget studyProgramScreenCache(List<int> _degreesDoing) {
    if(_studyProgramScreen == null) {
      setState(() {
        _studyProgramScreen = StudyProgramScreen(degreeIds: _degreesDoing);
      });
    }
    return _studyProgramScreen;
  }
  Widget calendarScreenCache() {
    if(_calendarScreen == null) {
      setState(() {
        _calendarScreen = CalendarScreen();
      });
    }
    return _calendarScreen;
  }

  @override
  Widget build(BuildContext context) {
    if(degreesDoing == null) 
      return Container();
    
    if(degreesDoing!.length == 0) 
      return SelectDegreeScreen();
    
    return Scaffold(
        appBar: AppBar(
          title: 
          Padding(
            padding: EdgeInsets.only(left:12),
            child:
              Text(globals.NAME_APP)),
          actions: <Widget>[
            IconButton(
              icon: const Icon(FontAwesomeIcons.cog),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => 
                    SettingsScreen())
                ).then(
                  (_) => getData()
                );
              },
            ),
          ],
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            studyProgramScreenCache(degreesDoing!),
            calendarScreenCache()
            
          ],
        ),
        

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff212121),
          currentIndex: _page,
          onTap: (index){
            setState(() {
              _page = index;
            });
            this._tabController.animateTo(index);
            //print(_tabController.index);
          },
          items: const <BottomNavigationBarItem>[
            /*BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.newspaper),
              title: Text('Noticias'),
            ),*/
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Materias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.date_range),
              label: 'Calendario',
            ),
          ],
        ),
      );
  }
}
