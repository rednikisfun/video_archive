import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:export_video_frame/export_video_frame.dart';

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
  bool isPaused = false;

  Future<bool> checkExistance(String name) async {
    var tempDir = await getTemporaryDirectory();
    dir = tempDir.path;
    if (await File(tempDir.path + "/$name").exists()) {
      print("File exists");
      return true;
    } else {
      print("File don't exists");
      return false;
    }
  }

  togglePauseButton() {
    setState(() {
      isPaused ? isPaused = false : isPaused = true;
    });
  }

  Future download2(Dio dio, String url, String name) async {
    var tempDir = await getTemporaryDirectory();
    String fullPath = tempDir.path + "/$name";
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
    String fullPath = tempDir.path + "/$name";
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

  Future _getImagesByDuration() async {
    var file = File("$dir/${widget.name}");
    var duration = videoPlayerController.value.position;
    var image = await ExportVideoFrame.exportImageBySeconds(file, duration, 0);
    await ExportVideoFrame.saveImage(image, 'Call Info Images');
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

      videoPlayerController = VideoPlayerController.file(
        File("$dir/${widget.name}"),
      );

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        allowFullScreen: false,
        allowMuting: false,
        showControls: false,
        aspectRatio: 3 / 2,
        autoPlay: true,
        looping: true,
        autoInitialize: true,
        placeholder: Container(),
      );
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
    // AppData _provider = Provider.of<AppData>(
    //   context,
    //   listen: false,
    // );

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
                              width: 300.0,
                              height: 100.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  !isPaused
                                      ? InkWell(
                                          onTap: () {
                                            videoPlayerController.pause();
                                            togglePauseButton();
                                          },
                                          child: Icon(
                                            Icons.pause,
                                            size: 50.0,
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            videoPlayerController.play();
                                            togglePauseButton();
                                          },
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 50.0,
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () {
                                      videoPlayerController.seekTo(
                                        Duration(
                                          seconds: 0,
                                        ),
                                      );
                                      videoPlayerController.pause();
                                      setState(() {
                                        isPaused = true;
                                      });
                                    },
                                    child: Icon(
                                      Icons.stop,
                                      size: 50.0,
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) => InkWell(
                                      onTap: () async {
                                        await _getImagesByDuration();
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Файл сохранён в альбом "Call Info Images"',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.crop_original,
                                        size: 50.0,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) => InkWell(
                                      onTap: () {
                                        GallerySaver.saveVideo(
                                          "$dir/${widget.name}",
                                          albumName: 'Call Info Video',
                                        );
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Файл сохранён в альбом "Call Info Video"',
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
                  BackButton(),
                ],
              ),
            ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
