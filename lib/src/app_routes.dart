import 'package:church/src/page/homepage/home_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> route = {
    HomePage.routeName: (context) => HomePage(),
  };
}
