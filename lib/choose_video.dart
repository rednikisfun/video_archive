import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:video_archive/video_page.dart';

class ChooseVideo extends StatefulWidget {
  ChooseVideo({
    @required this.date,
    @required this.wholeDay,
  });

  final DateTime date;
  final bool wholeDay;

  @override
  _ChooseVideoState createState() => _ChooseVideoState();
}

class _ChooseVideoState extends State<ChooseVideo> {
  var serverResponse;
  var isLoading = false;

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

  @override
  void initState() {
    widget.wholeDay ? _fetchDataDay(widget.date) : _fetchDataHour(widget.date);
    // _fetchDataHour(widget.date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy').format(widget.date),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 200.0,
                        bottom: 20.0,
                        top: 20.0,
                      ),
                    ),
                    Container(
                      width: 350.0,
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
                                            builder: (BuildContext context) =>
                                                VideoArchivePageTest(
                                              url:
                                                  "http://45.84.225.18:81/video-archive.php?q=123&ext=80008&y=${widget.date.year.toString()}&m=${widget.date.month.toString()}&d=${widget.date.day.toString()}&h=${serverResponse['names'][index]['time'].split(':')[0]}&n=${serverResponse['names'][index]['name']}",
                                              name: serverResponse['names']
                                                  [index]['name'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 300.0,
                                        height: 140.0,
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
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 300.0,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                        Text(
                                                          'Время: ',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                        Text(
                                                          serverResponse[
                                                                      'names'][
                                                                  index]['time']
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
                                                    width: 300.0,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                        Text(
                                                          'Протяжность: ',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.green,
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
                                                                  serverResponse['names'][index]
                                                                              [
                                                                              'duration'] !=
                                                                          ''
                                                                      ? double
                                                                          .parse(
                                                                          serverResponse['names'][index]['duration']
                                                                              .toString()
                                                                              .split('.')[0],
                                                                        ).round()
                                                                      : '',
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
                                                  SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                      left: 30.0,
                                                    ),
                                                    width: 300,
                                                    child: FittedBox(
                                                      child: Text(
                                                        'Нур-Султан, Пушкинская, 15, 37',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        softWrap: true,
                                                      ),
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
                                  'Нет видео',
                                ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
