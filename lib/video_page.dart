import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

var dio = Dio();
VideoPlayerController videoPlayerController;
ChewieController chewieController;

class VideoArchivePageTest extends StatefulWidget {
  VideoArchivePageTest({
    @required this.url,
    @required this.name,
  });

  final String url;
  final String name;

  @override
  _VideoArchivePageTestState createState() => _VideoArchivePageTestState();
}

class _VideoArchivePageTestState extends State<VideoArchivePageTest> {
  var uint8list;
  bool isLoadingMain = false;
  String dir;
  String dir1;

  Future<bool> checkExistance(String name) async {
    var tempDir = await getTemporaryDirectory();
    dir = tempDir.path;
    if (await File(tempDir.path + "/$name.mp4").exists()) {
      print("File exists");
      return true;
    } else {
      print("File don't exists");
      return false;
    }
  }

  Future download2(Dio dio, String url, String name) async {
    var tempDir = await getTemporaryDirectory();
    String fullPath = tempDir.path + "/$name.mp4";
    try {
      Response response = await dio.get(url,
          //Received data with List<int>
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status < 500;
              }), onReceiveProgress: (n, i) {
        print(n);
      });
      // print(response.data);
      print(response.headers);
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  Future download(Dio dio, String url, String name) async {
    var tempDir = await getExternalStorageDirectory();
    print(tempDir.path);
    String fullPath = tempDir.path + "/$name.mp4";
    dir1 = tempDir.path;
    try {
      Response response = await dio.get(url,
          //Received data with List<int>
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status < 500;
              }), onReceiveProgress: (n, i) {
        print(n);
      });
      // print(response.data);
      print(response.headers);
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  deleteFile() {
    final directory = Directory(dir);
    directory.deleteSync(recursive: true);
  }

  start() async {
    if (await checkExistance(widget.name) == false) {
      setState(() {
        isLoadingMain = true;
      });
      await download2(
        dio,
        widget.url,
        widget.name,
      );
      setState(() {
        isLoadingMain = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    deleteFile();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoPlayerController = VideoPlayerController.file(
      File("$dir/${widget.name}.mp4"),
    );

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
      autoInitialize: true,
      placeholder: Container(),
    );

    return Scaffold(
      body: isLoadingMain
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Chewie(
                              controller: chewieController,
                            ),
                            Container(
                              width: 100.0,
                              height: 100.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Builder(
                                    builder: (context) => InkWell(
                                      onTap: () async {
                                        await download(
                                          dio,
                                          widget.url,
                                          widget.name,
                                        );
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Файл сохранён в $dir1',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.file_download,
                                        size: 50.0,
                                      ),
                                    ),
                                  ),
                                  // InkWell(
                                  //   child: Icon(
                                  //     Icons.frame,
                                  //     size: 50.0,
                                  //   ),
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
    );
  }
}
