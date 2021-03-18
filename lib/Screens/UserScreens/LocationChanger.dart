import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swap/Screens/UserScreens/EditProfile.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
class LocationChanger extends StatefulWidget {
  @override
  _LocationChangerState createState() => _LocationChangerState();
}

Size size ;

class _LocationChangerState extends State<LocationChanger> {
   String dropdownValue;
  List<String> cityList = [
    'Ajman',
    'Al Ain',
    'Dubai',
    'Fujairah',
    'Ras Al Khaimah',
    'Sharjah',
    'Umm Al Quwain'
  ];
 
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController _controller;
  Location _location = Location();

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) { 
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
          ),
      );
      //debugPrint(l.latitude.toString() +" :: "+ l.longitude.toString());
      CupertinoAlertDialog(
        title: new Text("Dialog Title"),
        content: new Text("This is my content"),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yes"),
          ),
          CupertinoDialogAction(
            child: Text("No"),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Location"), 
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(100),
            ),
            height: size.height*0.6,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialcameraposition),
              mapType: MapType.satellite,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              //polylines: Set<Polyline>.of(_mapPolylines.values),
            ),
          ),
          SizedBox(height: size.height*0.1,),
          Padding(
            padding: EdgeInsets.symmetric(vertical :0, horizontal:size.width*0.08),
            child: ButtonTheme(
              minWidth: 00.0,
              height: size.height*0.07,
              child: RaisedButton(
                elevation: 5,
                color: Colors.purple[400],
                onPressed: (){
                  //debugPrint("SnackBar called");
                 return Fluttertoast.showToast(
                    msg: "Location Updated",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.purple[300].withOpacity(0.7),
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: <Widget>[
                    Text("Set my current location", 
                      style: TextStyle(fontSize: size.height*0.03, fontWeight: FontWeight.w600, color: Colors.white)),
                    SizedBox(width: size.width*0.02,),
                    Icon(Icons.location_pin, color: Colors.white,)
                  ],
                )
              ),
            ),
          )
        ],
      )
    );
  }
}
 // Completer<GoogleMapController> _controller = Completer();
  // Set<Marker> _markers = Set<Marker>();
  // CameraPosition cameraPosition = CameraPosition(target: LatLng(currentLocation.latitude, currentLocation.longitude));
  // MapType _currentmapType = MapType.normal;
  // Marker marker;
  
//   Map<PolylineId, Polyline> _mapPolylines = {};
// int _polylineIdCounter = 1;

// List<LatLng> _createPoints() {
//   final List<LatLng> points = <LatLng>[];
//   points.add(LatLng(1.875249, 0.845140));
//   points.add(LatLng(4.851221, 1.715736));
//   points.add(LatLng(8.196142, 2.094979));
//   points.add(LatLng(12.196142, 3.094979));
//   points.add(LatLng(16.196142, 4.094979));
//   points.add(LatLng(20.196142, 5.094979));
//   return points;
// }
// void _add() {
//   final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
//   _polylineIdCounter++;
//   final PolylineId polylineId = PolylineId(polylineIdVal);

//   final Polyline polyline = Polyline(
//     polylineId: polylineId,
//     consumeTapEvents: true,
//     color: Colors.red,
//     width: 5,
//     points: _createPoints(),
//   );
  

//   setState(() {
//     _mapPolylines[polylineId] = polyline;
//   });
// }