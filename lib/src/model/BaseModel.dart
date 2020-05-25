import 'package:flutter/material.dart';



class BaseModel extends ChangeNotifier{
  BuildContext context;



  updateState(){
    notifyListeners();
  }
  @override
  void dispose() {
    super.dispose();
  }
}