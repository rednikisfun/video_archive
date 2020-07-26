import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

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
  var list;
  var isLoading = false;
  var isLoadingMain = false;
  Map<DateTime, List<dynamic>> events = {};
  DateTime date = DateTime.now();
  double hour = 0;

  Future genThumbnailFile() async {
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
  }

  Future<int> getSize(String url) async {
    final response = await http.head(url);
    return response.contentLength;
  }

  _fetchData(DateTime date) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}&h=${date.hour.toString()}");
    if (response.statusCode == 200) {
      setState(() {
        list = json.decode(response.body);
        print(list);
        isLoading = false;
      });
    } else {
      throw Exception('Не получилось загрузить видео');
    }
  }

  getEvents() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${DateTime.now().year.toString()}&m=${DateTime.now().month.toString()}&d=${DateTime.now().day.toString()}&h=${DateTime.now().hour.toString()}");
    if (response.statusCode == 200) {
      list = json.decode(response.body);
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Не получилось загрузить видео');
    }

    var mainList;
    int i = 0;
    while (i != 12) {
      final response = await http.get(
          'http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${DateTime.now().year.toString()}&m=$i');
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

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _fetchData(date);
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
      body: SafeArea(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Date(date: date),
                                  onTap: () {
                                    DatePicker.showDatePicker(context,
                                        currentTime: date,
                                        onChanged: (chosenDate) {
                                      setState(() {
                                        date = chosenDate;
                                        hour =
                                            double.parse(date.hour.toString());
                                      });
                                    });
                                  },
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0),
                                  ),
                                ),
                                InkWell(
                                  child: TimePicker(date: date),
                                  onTap: () {
                                    // DatePicker.showTimePicker(context,
                                    //     currentTime: date,
                                    //     showSecondsColumn: false,
                                    //     onConfirm: (time) {
                                    //   setState(() {
                                    //     date = time;
                                    //   });
                                    //   _fetchData(date);
                                    //   print(date);
                                    // });
                                    Navigator.of(context).push(
                                      showPicker(
                                        is24HrFormat: true,
                                        context: context,
                                        value: TimeOfDay.now(),
                                        onChange: (time) {
                                          setState(() {
                                            date = DateTime(
                                                date.year,
                                                date.month,
                                                date.day,
                                                time.hour,
                                                time.minute);
                                          });

                                          hour = double.parse(
                                              date.hour.toString());
                                          _fetchData(date);
                                          print(date);
                                        },
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 50.0,
                            ),
                            TableCalendar(
                              calendarController: _calendarController,
                              initialCalendarFormat: CalendarFormat.month,
                              onDaySelected: (DateTime chosenDate, List list) {
                                setState(() {
                                  date = chosenDate;
                                  hour = double.parse(date.hour.toString());
                                });
                                _fetchData(date);
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
                            SizedBox(
                              height: 50.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 220.0,
                              ),
                              child: Text(
                                'Выберите час:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                valueIndicatorColor: Colors.blue,
                              ),
                              child: Slider.adaptive(
                                value: hour,
                                onChanged: (value) {
                                  setState(() {
                                    hour = value;
                                    date = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        int.parse(hour.round().toString()),
                                        date.minute);
                                  });
                                  _fetchData(date);
                                },
                                divisions: 23,
                                min: 0.0,
                                max: 23.0,
                                label: hour.round().toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      Container(
                        width: 200.0,
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : list['res']
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
                                              builder: (BuildContext context) =>
                                                  VideoArchivePageTest(
                                                url:
                                                    "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${date.year.toString()}&m=${date.month.toString()}&d=${date.day.toString()}&h=${date.hour.toString()}&n=${list['names'][index]['name']}",
                                                name: list['names'][index]
                                                    ['name'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 200.0,
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // filePath != null
                                              //     ? ClipRRect(
                                              //         borderRadius:
                                              //             BorderRadius.only(
                                              //           topLeft:
                                              //               Radius.circular(
                                              //                   10.0),
                                              //           bottomLeft:
                                              //               Radius.circular(
                                              //                   10.0),
                                              //         ),
                                              //         child: Image(
                                              //           image: AssetImage(
                                              //               filePath),
                                              //           width: 110.0,
                                              //         ),
                                              //       )
                                              //     : Text('Подождите...'),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 65.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        list['names'][index]
                                                                ['time']
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20.0,
                                                    ),
                                                    Container(
                                                      child: double.parse(list[
                                                                          'names']
                                                                      [index][
                                                                  'duration']) >
                                                              10
                                                          ? Text(
                                                              '00:' +
                                                                  double.parse(list['names']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'duration'])
                                                                      .round()
                                                                      .toString(),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            )
                                                          : Text(
                                                              "00:0" +
                                                                  double.parse(list['names']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'duration'])
                                                                      .round()
                                                                      .toString(),
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: list['names'].length,
                                  )
                                : Text(
                                    'No video found',
                                  ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class TimePicker extends StatelessWidget {
  const TimePicker({
    Key key,
    @required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black38,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Center(
        child: Text(
          '${date.hour.toString()}:${DateFormat('mm').format(date)}',
          style: TextStyle(
            fontSize: 19.0,
          ),
        ),
      ),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
        ),
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
