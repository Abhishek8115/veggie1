import 'package:flutter/material.dart';
import 'server.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'cache.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class LiveTracker extends StatefulWidget {
  final String orderId;
  LiveTracker({@required this.orderId});
  @override
  _LiveTrackerState createState() => _LiveTrackerState();
}

class _LiveTrackerState extends State<LiveTracker> {
  String contact;
  LatLng position; Timer timer;
  GoogleMapController _controller;
  Set<Marker> markers;
  Socket socket;
  void initialiseMap(LatLng p) {
    position = p;
    markers = Set<Marker>();
    markers.add(Marker(
      markerId: MarkerId('cp'),
      draggable: false,
      position: p,
      infoWindow: InfoWindow(
        title: 'Delivery Location',
      ),
    ));
  }

  void refreshMarker() {
    markers.removeWhere((element) => element.markerId.value == 'cp');
    markers.add(Marker(
      markerId: MarkerId('cp'),
      draggable: false,
      position: position,
    ));
    if (mounted) setState(() {});
  }

  Future connectToSocket() async {
    if (socket != null) {socket.disconnect(); socket.dispose(); if(timer != null) timer.cancel();}
    socket = io(
        'https://www.archerstack.com',
        OptionBuilder().setTransports(['websocket']).setExtraHeaders({
          'vendorid': Cache.vendorId,
          'password': password,
          'customerid': id
        }).build());
   socket.onConnect((_) {
      print("Connected");print(widget.orderId);
      socket.emit('getLocation', widget.orderId);
    });
    socket.onDisconnect((_) async{
	      await showDialog(
              context: context,
              builder: (context) =>
                  MessageDialog(message: "Connection Error"));
          if (Navigator.canPop(context)) Navigator.pop(context);
    });
    socket.on('updateLocation', (latlng) async {
      try {print(latlng);
        if (latlng == 'null') {
          await showDialog(
              context: context,
              builder: (context) =>
                  MessageDialog(message: "Your Delivery is Not Yet Started"));
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
        List<String> splits = (latlng as String).split(',');
        if (position == null) {
          initialiseMap(
              LatLng(double.parse(splits[0]), double.parse(splits[1])));
        }
        position = LatLng(double.parse(splits[0]), double.parse(splits[1]));
        refreshMarker();
        print(latlng); if(timer != null) timer.cancel();
        timer  = Timer(Duration(seconds: 7), () {
          socket.emit('getLocation',widget.orderId);
        });
      } catch (err) {}
    });

    socket.on('deliveryAgentContact', (_) {
      contact = _;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (position == null) connectToSocket();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }),
        title: Text('Track Your Order', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
          child: Column(
        children: [
          position == null
              ? Expanded(
                  child: Center(
                    child: Container(child: Pending(), color: Colors.black),
                  ),
                )
              : Expanded(
                  child: GoogleMap(
                      onMapCreated: (GoogleMapController c) {
                        _controller = c;
                        _controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(target: position, zoom: 16)));
                      },
                      markers: markers,
                      initialCameraPosition:
                          CameraPosition(target: position, zoom: 16.0))),
          RaisedButton(
              onPressed: () {
                launch('tel://' + contact);
              },
              color: Colors.green,
              child: Text('Call Your Delivery Agent',
                  style: TextStyle(color: Colors.white)))
        ],
      )),
    );
  }
}
