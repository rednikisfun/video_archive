import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:video_archive/choose_video.dart';

class VideoArchivePage extends StatefulWidget {
  @override
  _VideoArchivePageState createState() => _VideoArchivePageState();
}

class _VideoArchivePageState extends State<VideoArchivePage> {
  CalendarController _calendarController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var _isLoadingMain = false;
  Map<DateTime, List<dynamic>> _events = {};
  List _hours = [];
  DateTime _date = DateTime.now();
  double _hour = double.parse(DateTime.now().hour.toString());
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '00';
  List<String> _timeList = [];
  bool _noVideo;
  final _globalKey = GlobalKey<ScaffoldState>();
  StateSetter setModalSheetState;

  Future<int> getSize(String url) async {
    final response = await http.head(url);
    return response.contentLength;
  }

  getEvents() async {
    var mainList;
    int i = 0;
    while (i != 12) {
      final response = await http.get(
          'http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${_date.year.toString()}&m=$i');
      if (response.statusCode == 200) {
        mainList = json.decode(response.body);
        if (mainList['days'] != []) {
          for (var day in mainList['days']) {
            DateTime date = DateTime(
              DateTime.now().year.toInt(),
              i,
              int.parse(day),
            );
            setState(() {
              _events.putIfAbsent(date, () => ['Event']);
            });
          }
          setState(() {
            _isLoadingMain = false;
          });
        }
      } else {
        throw Exception('Failed to load');
      }
      i++;
    }
  }

  Widget getTableCalendar() => TableCalendar(
        enabledDayPredicate: (day) {
          day = day.subtract(
            Duration(hours: 12),
          );
          day = DateTime.parse(
            day.toString().replaceAll('Z', ''),
          );
          return _events.containsKey(day);
        },
        initialSelectedDay: _date,
        calendarController: _calendarController,
        initialCalendarFormat: CalendarFormat.month,
        onDaySelected: (DateTime chosenDate, List list) {
          setState(() {
            _date = chosenDate;
            _selectedDate = _date;
            _hour = double.parse(_date.hour.toString());
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChooseVideo(
                date: _date,
                wholeDay: true,
              ),
            ),
          );
        },
        events: _events,
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
        ),
        locale: 'ru_RU',
        availableCalendarFormats: {
          CalendarFormat.month: 'Month',
        },
        calendarStyle: CalendarStyle(
          selectedColor: Colors.blue,
          markersColor: Colors.red,
        ),
        startingDayOfWeek: StartingDayOfWeek.monday,
      );

  getHours() async {
    var mainList;
    final response = await http.get(
        'http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${_selectedDate.year.toString()}&m=${_selectedDate.month.toString()}&d=${_selectedDate.day.toString()}');
    if (response.statusCode == 200) {
      setState(() {
        mainList = json.decode(response.body);
        _hours = mainList['hours'];
      });
    }
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    getEvents();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  setTimeList() async {
    if (_timeList.isEmpty) {
      await getHours();
      print(_hours);
      List<String> tempList = [];
      for (int i = 0; i < 24; i++) {
        if (_hours.contains(i.toString().padLeft(2, '0'))) {
          tempList.add(
            i.toString().padLeft(2, '0'),
          );
        }
      }
      print(tempList);
      if (tempList.isEmpty) {
        setModalSheetState ??
            setState(() {
              _noVideo = true;
            });
      } else {
        setModalSheetState ??
            setState(() {
              _timeList = tempList;
              _noVideo = false;
              _timeList.clear();
              tempList.clear();
            });
      }
    }
  }

  showUniversalPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              _selectedTime = '00';
              return Container(
                height: 300,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CupertinoButton(
                          child: Text(
                            'Отменить',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Row(
                          children: [
                            CupertinoButton(
                              child: Text(
                                'Показать всё',
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {
                                setState(() {
                                  _date = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      int.parse(_selectedTime));
                                });
                                _calendarController.setSelectedDay(_date);
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChooseVideo(
                                      date: _date,
                                      wholeDay: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                            CupertinoButton(
                              child: Text(
                                'Подтвердить',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                setState(() {
                                  _date = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      int.parse(_selectedTime));
                                });
                                _calendarController.setSelectedDay(_date);
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChooseVideo(
                                      date: _date,
                                      wholeDay: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 200.0,
                      child: Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Flexible(
                            flex: 8,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: _date,
                              onDateTimeChanged: (DateTime dateTime) {
                                setState(() {
                                  setModalSheetState = setSheetState;
                                });
                                _selectedDate = dateTime;
                                // setTimeList();
                              },
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: CupertinoPicker(
                                itemExtent: 38,
                                magnification: 0.95,
                                useMagnifier: true,
                                looping: true,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    _selectedTime = _timeList[index];
                                  });
                                },
                                children: _timeList
                                    .map(
                                      (item) => Center(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // setTimeList();
    for (int i = 0; i < 24; i++) {
      _timeList.add(
        i.toString().padLeft(2, '0'),
      );
    }
    print(_timeList);
    _calendarController = CalendarController();
    // _fetchDataDay(date);
    getEvents();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Builder(builder: (context) {
        return SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _isLoadingMain
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50.0,
                              ),
                              Image.asset(
                                'assets/call_info_logo.png',
                                width: 100.0,
                              ),
                              SizedBox(height: 50.0),
                              InkWell(
                                child: Date(date: _date),
                                onTap: () {
                                  showUniversalPicker();
                                },
                                borderRadius: BorderRadius.circular(10),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              getTableCalendar(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class Date extends StatelessWidget {
  const Date({
    @required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black38,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${date.day.toString()}.${DateFormat('MM').format(date).toString()}.${date.year.toString()}',
          style: TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
    );
  }
}
