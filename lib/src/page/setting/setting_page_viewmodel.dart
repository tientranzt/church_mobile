import 'package:church/src/model/BaseModel.dart';
import 'package:church/src/page/homepage/home_page.dart';
import 'package:flutter/material.dart';

class SettingPageViewModel extends BaseModel {
  String titleAppbar = 'Cài đặt';
  double radiusSliderValue = 3.0;

  onRadiusSliderValueChange(double value) {
    radiusSliderValue = value;
//    updateState();
    notifyListeners();
  }

  onPushBackButtonClick() {
    Navigator.of(context)
        .pushReplacementNamed(HomePage.routeName, arguments: radiusSliderValue.toInt());
  }
}
