import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/utils/hive_boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await HiveBoxes.initHive(); // initialise Hive ( box )
  runApp(MyApp());
}
