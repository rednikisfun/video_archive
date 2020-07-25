import 'package:flutter/material.dart';
import 'package:video_archive/video_archive_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then(
    (_) => runApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoArchivePage(),
    );
  }
}
