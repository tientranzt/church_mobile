import 'package:church/src/model/BaseModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

//15 Tran Vinh kiet 10.012877, 105.751421
//50 Hoàng Quốc Việt 10.016985, 105.743923
//51 3/2 10.020015, 105.757648
//311 Nguyen Van Linh 10.029118, 105.753928
//244 Tran Hung Dao 10.033429, 105.774853
//10.044665, 105.744695 can tho
//10.016996, 105.743966 cong ty

class HomePageViewModel extends BaseModel {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int timeMinusInSecondToNotifications;
  String titleAppbar = 'Vị trí nhà thờ';
  Completer<GoogleMapController> controller = Completer();
  List<DocumentSnapshot> snapshot;
  static Position userPosition;
  // static var userPosition;
  static double radius = 3000;
  String idChurchNearest = '';
  double radiusSliderValue = 3.0;
  List<bool> listIsCheckedCheckBox = [false, false, false, false, false, false];
  final CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(10.044665, 105.744695),
    zoom: 13,
  );
  Set<Circle> circles = {};

  Set<Marker> markers = {};

  // google map route

  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;

  Stream<QuerySnapshot> getMarker() {
    return Firestore.instance.collection('churches').snapshots();
  }

  String apiKey = "AIzaSyBUhoLqjORjfER934kP-OFPRKNKFoWKlvA";

  updateMaker() {
    double tempDistance = 0;
    snapshot.forEach((church) {
      GeoPoint geo = church['location'];
      if (userPosition != null) {
        Geolocator()
            .distanceBetween(userPosition.latitude, userPosition.longitude,
                geo.latitude, geo.longitude)
            .then((value) {
          if (tempDistance == 0) tempDistance = value;
          if (value <= radius && value < tempDistance) {
            tempDistance = value;
            Firestore.instance
                .collection('churches')
                .document(church.documentID)
                .get()
                .then((DocumentSnapshot churchNear) {
              Firestore.instance
                  .collection('utils')
                  .document('time_minus')
                  .updateData({
                'church_nearest': {
                  'church_name': churchNear['church_name'],
                  'open_time': churchNear['open_time']
                }
              });
            });
            markers = {};
            _destLatitude = geo.latitude;
            _destLongitude = geo.longitude;
            markers.add(Marker(
                markerId: MarkerId(church['church_name']),
                infoWindow: InfoWindow(
                    title: church['church_name'],
                    snippet: church['church_address']),
                position: LatLng(geo.latitude, geo.longitude)));
          }
        });
      }
    });
  }

  onCheckBoxValueChange(bool isCheck, int index) {
    if (isCheck == true) {
      listIsCheckedCheckBox = [false, false, false, false, false, false];
      listIsCheckedCheckBox[index] = true;

      switch (index) {
        case 0:
          timeMinusInSecondToNotifications = 5;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 0, 'time_value_minute': 5});
          notifyListeners();
          break;
        case 1:
          timeMinusInSecondToNotifications = 10;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 1, 'time_value_minute': 10});
          notifyListeners();
          break;
        case 2:
          timeMinusInSecondToNotifications = 15;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 2, 'time_value_minute': 15});
          notifyListeners();
          break;
        case 3:
          timeMinusInSecondToNotifications = 30;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 3, 'time_value_minute': 30});
          notifyListeners();
          break;
        case 4:
          timeMinusInSecondToNotifications = 45;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 4, 'time_value_minute': 45});
          notifyListeners();
          break;
        case 5:
          timeMinusInSecondToNotifications = 60;
          Firestore.instance
              .collection('utils')
              .document('time_minus')
              .updateData({'time_minus': 5, 'time_value_minute': 60});
          notifyListeners();
          break;
        default:
          break;
      }
      notifyListeners();
    } else {
      listIsCheckedCheckBox = [false, false, false, false, false, false];
      notifyListeners();
    }
  }

  onRadiusSliderValueChange(double value) {
    radiusSliderValue = value;
    radius = double.parse('${radiusSliderValue.toInt()}000');
    if(userPosition != null){
          circles = {};
    circles.add(Circle(
        circleId: CircleId('113'),
//        center: LatLng(10.044665, 105.744695),
        center: LatLng(userPosition.latitude, userPosition.longitude),
        radius: radius,
        fillColor: Color.fromRGBO(66, 165, 245, 0.5),
        strokeColor: Colors.transparent));
    }
    markers = {};
    updateMaker();
    notifyListeners();
  }

//  function google map route

  GoogleMapController mapController;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double _originLatitude = 0;
  double _originLongitude = 0;
  double _destLatitude = 0;
  double _destLongitude = 0;
  String googleAPiKey = "AIzaSyB4HY9HtQRnzsi8A-LrF2khRk2yuw5bI_U";

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 4,
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates);
    polylines[id] = polyline;
    notifyListeners();
  }

  getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.bicycling,
      // wayPoints: [PolylineWayPoint(location: "Can Tho, Ninh Kiều, Cần Thơ, Việt Nam")]
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates = [];
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        notifyListeners();
      });
    }
    _addPolyLine();
  }

  void getLocation() async {
    Geolocator geolocator = Geolocator();
    GeolocationStatus status =
        await geolocator.checkGeolocationPermissionStatus();
    if (status == GeolocationStatus.granted) {
      print("grant lcoation");
      userPosition = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _originLatitude = userPosition.latitude;
      _originLongitude = userPosition.longitude;
      circles.add(Circle(
          circleId: CircleId('113'),
          center: LatLng(userPosition.latitude, userPosition.longitude),
          radius: radius,
          fillColor: Color.fromRGBO(66, 165, 245, 0.5),
          strokeColor: Colors.transparent));
      updateMaker();
      notifyListeners();
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông tin vị trí'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Xin mở vị trí để tiếp tục'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
