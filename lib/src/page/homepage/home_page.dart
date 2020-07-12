import 'package:church/src/page/homepage/homepage_viewmodel.dart';
import 'package:church/src/theme/theme_primary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'homepage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageViewModel viewModel = HomePageViewModel();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Color colorDirection = Colors.blue;
  Future onSelectNotification(String payload) async {
    viewModel.getLocation();
    viewModel.getMarker();
    // viewModel.getPolyline();
    setState(() {
      colorDirection = Colors.red;
      Future.delayed(Duration(seconds: 3),(){
        colorDirection = Colors.blue;
      });
    });
  }

  @override
  void initState() {
    Geolocator().getCurrentPosition();
    var android = AndroidInitializationSettings('app_icon');
    var ios = IOSInitializationSettings();
    var setting = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(setting,
        onSelectNotification: onSelectNotification);
    Firestore.instance
        .collection('utils')
        .document('time_minus')
        .get()
        .then((value) {
      int index = value['time_minus'];
      viewModel.listIsCheckedCheckBox = [
        false,
        false,
        false,
        false,
        false,
        false
      ];
      viewModel.listIsCheckedCheckBox[index] = true;
    });

    Firestore.instance
        .collection('utils')
        .document('time_minus')
        .get()
        .then((value) {
      String time = value['church_nearest']['open_time'];
      int hours = int.parse(time.split(':')[0]);
      int minute = int.parse(time.split(':')[1]);
      print(value['time_value_minute']);

      if (minute > value['time_value_minute']) {
        minute = minute - value['time_value_minute'];
      } else {
        hours = hours - 1;
        minute = minute + (60 - value['time_value_minute']);
        if (minute >= 60) {
          hours += 1;
          minute = minute - 60;
        }
      }
      print("$hours : $minute");
      showNotificationByTime(
          747, Time(hours, minute, 00), value['church_nearest']['church_name'],
          value['church_nearest']['open_time']
          );
    });

    super.initState();
  }

  void showNotificationByTime(int id, Time time, String nameOfChurch, String realTime) async {
    var android = AndroidNotificationDetails('id', 'name', 'description');
    var ios = IOSNotificationDetails();
    NotificationDetails platformChannel = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        id,
        'Thông báo ứng dụng Church',
        '$nameOfChurch mở lúc $realTime',
        time,
        platformChannel);
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar() {
      void _showDialog() async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setstate) {
                return AlertDialog(
                  title: Text("Cài đặt".toUpperCase()),
                  content: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Bán kính: ${viewModel.radiusSliderValue.toInt()} km',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Slider(
                                  value: viewModel.radiusSliderValue,
                                  onChanged: (value) {
                                    setstate(() {
                                      viewModel
                                          .onRadiusSliderValueChange(value);
                                    });
                                  },
                                  min: 0,
                                  max: 10,
                                ),
                                Divider(),
                                Text(
                                  'Thông báo giờ mở cửa trước:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              ' 5p  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 0);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[0],
                                              ),
                                            ),
                                            Divider(),
                                            Text(
                                              ' 10p  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 1);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[1],
                                              ),
                                            ),
                                            Text(
                                              ' 15p  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 2);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[2],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              ' 30p  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 3);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[3],
                                              ),
                                            ),
                                            Divider(),
                                            Text(
                                              ' 45p  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 4);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[4],
                                              ),
                                            ),
                                            Text(
                                              ' 1h  ',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  setstate(() {
                                                    viewModel
                                                        .onCheckBoxValueChange(
                                                            value, 5);
                                                  });
                                                },
                                                value: viewModel
                                                    .listIsCheckedCheckBox[5],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Đóng"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      }

      return AppBar(
        title: Text(
          viewModel.titleAppbar.toUpperCase(),
          style: TextStyle(fontFamily: 'Quicksand'),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showDialog();
            },
            icon: Icon(
              Icons.settings,
              color: ThemePrimary.textPrimaryWhite,
            ),
          )
        ],
      );
    }

    Widget body() {
      return StreamBuilder<QuerySnapshot>(
        stream: viewModel.getMarker(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            viewModel.snapshot = snapshot.data.documents;
            viewModel.updateMaker();
          }

          return GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: viewModel.kGooglePlex,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              viewModel.controller.complete(controller);
            },
            // markers: viewModel.markers,
            // onMapCreated: _onMapCreated,
            markers: viewModel.markers,
            circles: viewModel.circles,
            polylines: Set<Polyline>.of(viewModel.polylines.values),
          );
        },
      );
    }

    return ChangeNotifierProvider(
      create: (context) => HomePageViewModel(),
      child: Consumer<HomePageViewModel>(
        builder: (context, view, child) {
          view.context = context;
          viewModel = view;
          return Scaffold(
            appBar: appBar(),
            body: body(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    viewModel.getLocation();
                  },
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.search),
                  tooltip: 'Lấy vị trí',
                ),
                SizedBox(
                  width: 15,
                ),
                FloatingActionButton(
                  onPressed: () {
                    viewModel.getPolyline();
                  },
                  autofocus: true,
                  tooltip: 'Chỉ đường',
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.directions),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
