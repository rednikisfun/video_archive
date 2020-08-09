import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:video_archive/video_archive_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then(
    (_) => runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.of(context).locale,
      builder: DevicePreview.appBuilder,
      home: VideoArchivePage(),
    );
  }
}
