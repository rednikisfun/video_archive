import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<bool> checkExistance(String name) async {
    var tempDir = await getExternalStorageDirectory();
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
    var tempDir = await getExternalStorageDirectory();
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
      body: Center(
        child: isLoadingMain
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Chewie(
                    controller: chewieController,
                  ),
                  Container(
                      // child: Image.memory(uint8list),
                      ),
                ],
              ),
      ),
    );
  }
}

// Future<Uint8List> thumbnailBytes() async {
//   dynamic thumbnail = await VideoThumbnail.thumbnailFile(
//     video:
//         "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
//     thumbnailPath: (await getTemporaryDirectory()).path,
//     imageFormat: ImageFormat.PNG,
//     maxHeight:
//         64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
//     quality: 75,
//   );
//   return thumbnail;
// }
