import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:day_night_time_picker/day_night_time_picker.dart';
// import 'package:flutter_rounded_date_picker/rounded_picker.dart';

import './video_page.dart';

class VideoArchivePage extends StatefulWidget {
  @override
  _VideoArchivePageState createState() => _VideoArchivePageState();
}

class _VideoArchivePageState extends State<VideoArchivePage> {
  CalendarController _calendarController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var filePath;
  var serverResponse;
  var isLoading = false;
  var isLoadingMain = false;
  Map<DateTime, List<dynamic>> events = {};
  List hours = [];
  DateTime date = DateTime.now();
  double hour = double.parse(DateTime.now().hour.toString());
  DateTime _selectedDate;
  String _selectedTime = '00';
  List<String> timeList = [];
  final globalKey = GlobalKey<ScaffoldState>();

  // Future genThumbnailFile() async {
  // var tempDir = await getExternalStorageDirectory();
  // String fullPath = tempDir.path + "/video.mp4";
  // final thumbnail = await VideoCompress.getFileThumbnail(
  //   fullPath,
  //   quality: 100, // default(100)
  //   position: -1, // default(-1)
  // );
  // setState(() {
  //   final file = thumbnail;
  //   filePath = file.path;
  // });
  // }

  Future<int> getSize(String url) async {
    final response = await http.head(url);
    return response.contentLength;
  }

  _fetchDataDay(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}&h=all");
    if (response.statusCode == 200) {
      setState(() {
        serverResponse = json.decode(response.body);
        print(serverResponse);
        isLoading = false;
      });
    } else {
      throw Exception('Не получилось загрузить видео');
    }
  }

  _fetchDataHour(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}&h=${date.hour.toString()}");
    if (response.statusCode == 200) {
      setState(() {
        serverResponse = json.decode(response.body);
        print(serverResponse);
        isLoading = false;
      });
    } else {
      throw Exception('Не получилось загрузить видео');
    }
  }

  getEvents() async {
    var mainList;
    int i = 0;
    while (i != 12) {
      final response = await http.get(
          'http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=$i');
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
              events.putIfAbsent(date, () => ['Event']);
            });
          }
          setState(() {
            isLoadingMain = false;
          });
        }
      } else {
        throw Exception('Failed to load');
      }
      i++;
    }
  }

  getHours() async {
    // debugger();
    var mainList;
    final response = await http.get(
        'http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}');
    if (response.statusCode == 200) {
      setState(() {
        mainList = json.decode(response.body);
        hours = mainList['hours'];
      });
    }
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    getEvents();
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  showUniversalPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Builder(
            builder: (context) => Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CupertinoButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoButton(
                        child: Text(
                          'Done',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          // _selectedDate = DateTime.parse(
                          //   _selectedDate.toString().replaceAll('Z', ''),
                          // );
                          getHours();
                          hours.contains(_selectedTime)
                              ? setState(() {
                                  date = _selectedDate;
                                  date = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    int.parse(_selectedTime),
                                  );
                                  _calendarController.setSelectedDay(date);
                                  _fetchDataHour(date);
                                })
                              : globalKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text('В выбраной дате нет видео'),
                                  ),
                                );

                          // print(date);
                          Navigator.of(context).pop();
                        },
                      )
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
                              initialDateTime: date,
                              onDateTimeChanged: (DateTime dateTime) {
                                setState(() {
                                  _selectedDate = dateTime;
                                });
                              },
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: CupertinoPicker(
                                itemExtent: 38,
                                useMagnifier: true,
                                magnification: 0.95,
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    _selectedTime = timeList[index];
                                  });
                                },
                                children: timeList
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
                      )),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _fetchDataDay(date);
    for (int i = 0; i < 24; i++) {
      timeList.add(i.toString().padLeft(2, '0'));
    }
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
      key: globalKey,
      body: Builder(builder: (context) {
        return SafeArea(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: isLoadingMain
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
                                child: Date(date: date),
                                onTap: () {
                                  // DatePicker.showPicker(context,
                                  // currentTime: date,
                                  //     pickerModel: CustomPicker(
                                  //       currentTime: date,
                                  //       locale: LocaleType.ru,
                                  //     ), onConfirm: (chosenDate) {
                                  //   chosenDate = DateTime.parse(
                                  //     chosenDate
                                  //         .toString()
                                  //         .replaceAll('Z', ''),
                                  //   );
                                  //   events.containsKey(chosenDate)
                                  //       ? setState(() {
                                  //           date = chosenDate;
                                  //           hour = double.parse(
                                  //               date.hour.toString());
                                  //           getHours();
                                  //           _fetchDataDay(date);
                                  //           _calendarController
                                  //               .setSelectedDay(date);
                                  //         })
                                  //       : Scaffold.of(context)
                                  //           .showSnackBar(
                                  //           SnackBar(
                                  //             content: Text(
                                  //                 'В выбранной дате нет видео'),
                                  //           ),
                                  //         );
                                  // });

                                  showUniversalPicker();

                                  // CupertinoRoundedDatePicker.show(
                                  //   context,
                                  //   initialDatePickerMode:
                                  //       CupertinoDatePickerMode
                                  //           .dateAndTime,
                                  // );
                                },
                                borderRadius: BorderRadius.circular(10),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              TableCalendar(
                                enabledDayPredicate: (day) {
                                  day = day.subtract(
                                    Duration(hours: 12),
                                  );
                                  day = DateTime.parse(
                                    day.toString().replaceAll('Z', ''),
                                  );
                                  // print(day);
                                  return events.containsKey(day);
                                },
                                initialSelectedDay: date,
                                calendarController: _calendarController,
                                initialCalendarFormat: CalendarFormat.month,
                                onDaySelected:
                                    (DateTime chosenDate, List list) {
                                  setState(() {
                                    date = chosenDate;
                                    hour = double.parse(date.hour.toString());
                                    // getHours();
                                  });
                                  _fetchDataDay(date);
                                },
                                events: events,
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
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 200.0,
                            bottom: 50.0,
                          ),
                          child: Text(
                            'Выберите видео:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Container(
                          width: 270.0,
                          //width of the shield
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : serverResponse['res']
                                  ? ListView.separated(
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              SizedBox(
                                        height: 40.0,
                                      ),
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () async {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        VideoArchivePageTest(
                                                  url:
                                                      "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}&h=${serverResponse['names'][index]['time'].split(':')[0]}&n=${serverResponse['names'][index]['name']}",
                                                  name: serverResponse['names']
                                                      [index]['name'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 220.0,
                                            height: 80.0,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 5.0,
                                                  spreadRadius: 2.0,
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 220.0,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30,
                                                            ),
                                                            Text(
                                                              'Время: ',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ),
                                                            Text(
                                                              serverResponse['names']
                                                                          [
                                                                          index]
                                                                      ['time']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Container(
                                                        width: 220.0,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 30,
                                                            ),
                                                            Text(
                                                              'Протяжность: ',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                            Text(
                                                              DateFormat('ms')
                                                                  .format(
                                                                    DateTime(
                                                                      2001,
                                                                      6,
                                                                      19,
                                                                      0,
                                                                      0,
                                                                      double
                                                                          .parse(
                                                                        serverResponse['names'][index]['duration']
                                                                            .toString()
                                                                            .split('.')[0],
                                                                      ).round(),
                                                                    ),
                                                                  )
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                serverResponse['names'][index]
                                                            ['type'] ==
                                                        'in'
                                                    ? FaIcon(
                                                        FontAwesomeIcons
                                                            .arrowAltCircleDown,
                                                        color: Colors.green,
                                                      )
                                                    : FaIcon(
                                                        FontAwesomeIcons
                                                            .arrowAltCircleUp,
                                                        color: Colors.red,
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: serverResponse['names'].length,
                                    )
                                  : Text(
                                      'No video found',
                                    ),
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

// class TimePicker extends StatelessWidget {
//   const TimePicker({
//     Key key,
//     @required this.date,
//   });

//   final DateTime date;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 100.0,
//       height: 50.0,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Colors.black38,
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: Text(
//           '${date.hour.toString()}:${DateFormat('mm').format(date)}',
//           style: TextStyle(
//             fontSize: 19.0,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
