import 'package:church/src/page/homepage/home_page.dart';
import 'package:church/src/page/setting/setting_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> route = {
    HomePage.routeName: (context) => HomePage(),
    SettingPage.routeName: (context) => SettingPage()
  };
}
