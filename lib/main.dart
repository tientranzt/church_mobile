import 'package:church/src/app_routes.dart';
import 'package:church/src/page/homepage/home_page.dart';
import 'package:church/src/theme/theme_primary.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  theme: ThemePrimary.theme(),
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.route,
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}
