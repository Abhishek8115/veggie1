import 'package:geolocator/geolocator.dart';
import 'cache.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'dart:async';
import 'dart:convert';
import 'models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class SimpleBtn extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final Color backColor;
  SimpleBtn(
      {@required this.onPressed,
      @required this.child,
      this.backColor = Colors.green});
  @override
  _SimpleBtnState createState() => _SimpleBtnState();
}

class _SimpleBtnState extends State<SimpleBtn> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(6),
      textColor: Colors.white,
      color: widget.backColor,
      onPressed: () async {
        try {
          if (loading) return;
          setState(() {
            loading = true;
          });
          await widget.onPressed();
          setState(() {
            loading = false;
          });
        } catch (err) {
          setState(() {
            loading = false;
          });
        }
      },
      child: (loading) ? Image.asset('assets/btn-loading.gif') : widget.child,
    );
  }
}

class MessageDialog extends StatelessWidget {
  final String message;
  MessageDialog({@required this.message});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Text('Ok'),
        )
      ],
    );
  }
}

class PendingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/btn-loading.gif');
  }
}

class Pending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/btn-loading.gif');
  }
}

class ShowImage extends StatefulWidget {
  final String itemId;
  final String header;
  final String description;
  final List<String> secondaryImages = [];
  ShowImage(
      {@required this.itemId,
      @required this.header,
      @required this.description}) {
    secondaryImages.add(this.itemId);
  }
  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  int index = 0;
  bool initialized = false;
  double height, width;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = width / 2;
    if (!initialized) {
      initialized = true;
      getRequest(domain + '/vendor/secondary-images?itemId=' + widget.itemId)
          .then((response) {
        if (response.statusCode == 200) {
          widget.secondaryImages
              .addAll((json.decode(response.body) as List).cast<String>());
          setState(() {});
        }
      });
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            widget.header,
            style: TextStyle(color: Cache.appBarActionsColor),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Cache.appBarActionsColor),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: ListView(children: <Widget>[
          GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity > 0) {
                  index--;
                  if (index == -1)
                    index = 0;
                  else
                    setState(() {});
                }
                if (details.primaryVelocity < 0) {
                  index++;
                  if (index == widget.secondaryImages.length)
                    index--;
                  else
                    setState(() {});
                }
              },
              child: InteractiveViewer(
                  child: FadeInImage.assetNetwork(
                image: s3Domain + widget.secondaryImages[index],
                height: height,
                width: width,
                fit: BoxFit.fill,
                placeholder: 'assets/no-image.png',
              ))),
          Padding(
              child: Text(
                widget.header,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              padding: EdgeInsets.all(8)),
          Divider(color: Colors.grey),
          Padding(
              child: Text(widget.description,
                  style: TextStyle(color: Colors.white)),
              padding: EdgeInsets.all(8)),
          Divider(height: 10)
        ]));
  }
}

class GMap extends StatefulWidget {
  final GMapState state;
  GMap({@required this.state});
  @override
  GMapState createState() => state;
}

class GMapState extends State<GMap> {
  GMapState(LatLng p) {
    position = p;
    markers = Set<Marker>();
    markers.add(Marker(
        markerId: MarkerId('cp'),
        draggable: true,
        position: p,
        infoWindow: InfoWindow(
          title: 'Delivery Location',
        ),
        onDragEnd: (LatLng pos) {
          position = pos;
          refreshMarker();
        }));
  }
  LatLng position;
  GoogleMapController _controller;
  Set<Marker> markers;
  double distance = 0;

  void refreshMarker() {
    markers.removeWhere((element) => element.markerId.value == 'cp');
    markers.add(Marker(
        markerId: MarkerId('cp'),
        draggable: true,
        position: position,
        onDragEnd: (LatLng pos) {
          position = pos;
          refreshMarker();
        }));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 330,
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                child: GoogleMap(
                    onMapCreated: (GoogleMapController c) {
                      _controller = c;
                      _controller.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: position, zoom: 16)));
                    },
                    onCameraMove: (cp) {
                      position =
                          LatLng(cp.target.latitude, cp.target.longitude);
                      refreshMarker();
                    },
                    onCameraIdle: () {
                      distance = Geolocator.distanceBetween(
                          Cache.latitude,
                          Cache.longitude,
                          position.latitude,
                          position.longitude);
                      print(distance);
                      setState(() {});
                    },
                    markers: markers,
                    initialCameraPosition:
                        CameraPosition(target: position, zoom: 15.0)),
                width: 400,
                height: 300),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                distance.floor() < 7000
                    ? Icon(Icons.emoji_emotions, color: Colors.green)
                    : Icon(Icons.report, color: Colors.orange),
                Text((distance.floor() < 7000
                    ? 'We deliver here '
                    : 'We do not deliver here'))
              ],
            )
          ],
        ));
  }
}

class ItemDetails extends StatelessWidget {
  final StoreItem item;
  ItemDetails({@required this.item});
  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> splitted = {};
    if (item.variations != null) {
      for (var v in item.variations) {
        try {
          int i = v.name.indexOf(' ');
          String s = v.name.substring(0, i);
          String c = v.name.substring(i + 1);
          if (splitted.containsKey(s))
            splitted[s].add(c);
          else {
            splitted.putIfAbsent(s, () => []);
            splitted[s].add(c);
          }
        } catch (err) {
          splitted.clear();
        }
      }
    }
    List<Widget> widgets = [];
    widgets.add(
      item.description == null
          ? Padding(padding: EdgeInsets.all(0))
          : Padding(
              padding: EdgeInsets.all(8),
              child: Text(item.description, textAlign: TextAlign.center)),
    );
    widgets.add(Divider());
    if (item.variations != null && splitted.isNotEmpty) {
      for (var key in splitted.keys) {
        widgets.add(Container(
            width: MediaQuery.of(context).size.width - 120,
            padding: EdgeInsets.all(8),
            child: Text(key + ":",
                style: TextStyle(fontWeight: FontWeight.bold))));
        widgets.add(Column(
            mainAxisSize: MainAxisSize.min,
            children: splitted[key].map((e) {
              var v = item.variations
                  .firstWhere((element) => element.name == key + " " + e);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(child: Text(e), padding: EdgeInsets.only(left: 8)),
                  Padding(
                      child: Text(Cache.currency +
                          " " +
                          (v.price - v.discount).toStringAsFixed(2)),
                      padding: EdgeInsets.only(right: 8))
                ],
              );
            }).toList()));
        widgets.add(Padding(padding: EdgeInsets.all(8)));
      }
    }
    if (item.variations != null && splitted.isEmpty) {
      widgets.addAll(item.variations.map((e) {
        var v = item.variations.firstWhere((element) => element.name == e.name);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(e.name),
                padding: EdgeInsets.only(left: 8)),
            Padding(
                child: Text(Cache.currency +
                    " " +
                    (v.price - v.discount).toStringAsFixed(2)),
                padding: EdgeInsets.only(right: 8))
          ],
        );
      }));
    }
    if (item.customizations != null)
      widgets.add(Padding(
          padding: EdgeInsets.all(8),
          child: Text("Customizations and Add-ons:",
              style: TextStyle(fontWeight: FontWeight.bold))));
    if (item.customizations != null)
      widgets.addAll(item.customizations.keys.map((e) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: MediaQuery.of(context).size.width - 120,
                child: Text(e),
                padding: EdgeInsets.only(left: 8, bottom: 4)),
            Padding(
                child: Text(item.customizations[e] <= 0
                    ? Cache.currency + " " + item.price
                    : Cache.currency +
                        " " +
                        (item.customizations[e]).toStringAsFixed(2)),
                padding: EdgeInsets.only(right: 8))
          ],
        );
      }));
    widgets.add(Padding(padding: EdgeInsets.all(8)));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            }),
        title: Text(item.header, style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
          child: Column(children: [
        Stack(children: [
          FadeInImage.assetNetwork(
              fit: BoxFit.fill,
              image: s3Domain + item.itemId,
              placeholder: 'assets/no-image.png',
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width),
          Positioned(
              left: 0,
              width: 80,
              height: 80,
              child: getPriceWidget(
                  double.parse(item.discount), double.parse(item.price))),
        ]),
        Expanded(child: ListView(children: widgets))
      ])),
    );
  }

  Transform getPriceWidget(double discount, double price) {
    return Transform.rotate(
        angle: -3.14 / 4,
        child: Container(
            width: 80,
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                discount > 0
                    ? Text(Cache.currency + ' ' + price.toStringAsFixed(2),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough))
                    : Padding(padding: EdgeInsets.all(0)),
                Text(
                    Cache.currency +
                        ' ' +
                        (price - discount).toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Padding(padding: EdgeInsets.all(8)),
              ],
            ),
            decoration: BoxDecoration(
                color: Color(0x50000000),
                borderRadius: BorderRadius.circular(50))));
  }
}

class AddNewAddress extends StatefulWidget {
  AddNewAddressState createState() => AddNewAddressState();
}

class AddNewAddressState extends State<AddNewAddress> {
  LatLng position;
  GoogleMapController _controller;
  Set<Marker> markers;
  double distance = 0;
  TextEditingController flatNo = TextEditingController(text: '');
  TextEditingController colony = TextEditingController(text: '');
  TextEditingController landmark = TextEditingController(text: '');
  TextEditingController pincode = TextEditingController(text: '');
  String flatError, colonyError, landmarkError, pincodeError;
  bool addingAddress = true;
  bool fetchingLocationData = false;
  double maxDistanceOfDelivery = 30;
  Map<String, String> address;
  void initialzeMap() {
    markers = Set<Marker>();
    markers.add(Marker(
        markerId: MarkerId('cp'),
        draggable: true,
        position: position,
        infoWindow: InfoWindow(
          title: 'Delivery Location',
        ),
        onDragEnd: (LatLng pos) {
          position = pos;
          refreshMarker();
        }));
  }

  void refreshMarker() {
    markers.removeWhere((element) => element.markerId.value == 'cp');
    markers.add(Marker(
        markerId: MarkerId('cp'),
        draggable: true,
        position: position,
        onDragEnd: (LatLng pos) {
          position = pos;
          refreshMarker();
        }));
    setState(() {});
  }

  Future saveAddress() async {
    showDialog(context: context, builder: (context) => Pending());
    var response = await postMap(
        '/customer/save-address',
        {
          'customerId': id,
          'password': password,
          'flat': flatNo.text,
          'colony': colony.text,
          'landmark': landmark.text,
          'pincode': pincode.text,
          'longitude': position.longitude.toString(),
          'latitude': position.latitude.toString()
        },
        context);
    if (Navigator.canPop(context)) Navigator.pop(context);
    if (response.statusCode == 200) {
      if (Navigator.canPop(context)) {
        Navigator.pop(
            context,
            Address(
                pincode.text.trim(),
                landmark.text.trim(),
                colony.text.trim(),
                flatNo.text.trim(),
                position.latitude.toString(),
                position.longitude.toString(),
                response.body));
      }
    } else {
      await showDialog(
          context: context,
          builder: (context) => MessageDialog(
                message: response.body,
              ));
      setState(() {
        position = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (fetchingLocationData) fetchLocationData();
    Widget body;
    if (addingAddress) {
      body = Column(children: [
        Padding(padding: EdgeInsets.all(20)),
        Padding(
          child: TextFormField(
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            onTap: () {
              flatError = null;
              setState(() {});
            },
            maxLines: 1,
            controller: flatNo,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                labelText: 'House/Flat/Apartment No.',
                errorText: flatError),
          ),
          padding: EdgeInsets.all(4),
        ),
        Padding(
          child: TextFormField(
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            onTap: () {
              colonyError = null;
              setState(() {});
            },
            maxLines: 1,
            controller: colony,
            decoration: InputDecoration(
               border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                labelText: 'Colony/Street/Locality',
                labelStyle: TextStyle(color: Colors.grey[400]),
                errorText: colonyError),
          ),
          padding: EdgeInsets.all(4),
        ),
        Padding(
          child: TextFormField(
            cursorColor: Colors.black,
            style: TextStyle(color:Colors.black),
            onTap: () {
              landmarkError = null;
              setState(() {});
            },
            maxLines: 1,
            controller: landmark,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                labelText: 'Landmark',
                labelStyle: TextStyle(color: Colors.grey[400]),
                errorText: landmarkError),
          ),
          padding: EdgeInsets.all(4),
        ),
        Padding(
          child: TextFormField(
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            onTap: () {
              pincodeError = null;
              setState(() {});
            },
            maxLines: 1,
            controller: pincode,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1)),
                labelText: 'Pincode/Postal Code',
                labelStyle: TextStyle(color: Colors.grey[400]),
                errorText: pincodeError),
          ),
          padding: EdgeInsets.all(4),
        ),
        FlatButton(
            child: Text('Next', style: TextStyle(color: Colors.white)),
            color: Cache.appBarColor,
            onPressed: () {
              validateAddress();
            })
      ]);
    } else if (fetchingLocationData)
      body = Center(child: Pending());
    else if (position == null) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: MediaQuery.of(context).size.width),
          Icon(Icons.error, color: Colors.grey),
          Text('Something went wrong', style: TextStyle(color: Colors.grey)),
          FlatButton(
            child: Text('Try again', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                fetchingLocationData = true;
              });
            },
          )
        ],
      );
    } else {
      body = Column(
        children: [
          Container(
              height: 400,
              child: GoogleMap(
                  onMapCreated: (GoogleMapController c) {
                    _controller = c;
                    _controller.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: position, zoom: 16)));
                  },
                  onCameraMove: (cp) {
                    position = LatLng(cp.target.latitude, cp.target.longitude);
                    refreshMarker();
                  },
                  onCameraIdle: () {
                    distance = Geolocator.distanceBetween(
                        Cache.locations[Cache.outletId][0],
                        Cache.locations[Cache.outletId][1],
                        position.latitude,
                        position.longitude);
                    print(distance);
                    setState(() {});
                  },
                  markers: markers,
                  initialCameraPosition:
                      CameraPosition(target: position, zoom: 15.0))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              distance.floor() < maxDistanceOfDelivery
                  ? Icon(Icons.emoji_emotions, color: Colors.green)
                  : Icon(Icons.report, color: Colors.orange),
              Text(
                  (distance.floor() < maxDistanceOfDelivery
                      ? 'We deliver here '
                      : 'We do not deliver here'),
                  style: TextStyle(color: Colors.grey))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                  child: Text('Confirm Address',
                      style: TextStyle(color: Colors.white)),
                  color: Cache.appBarColor,
                  onPressed: () {
                    saveAddress();
                  }),
              Text(" or ", style: TextStyle(color: Colors.white)),
              FlatButton(
                  child: Text('Use Current Location',
                      style: TextStyle(color: Colors.white)),
                  color: Cache.appBarColor,
                  onPressed: () async {
                    showDialog(
                        context: context, builder: (context) => Pending());
                    var perm = await Geolocator.requestPermission();
                    if (perm == LocationPermission.always ||
                        perm == LocationPermission.whileInUse) {
                      Position p = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.best);
                      if (p == null) {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        return;
                      }
                      position = LatLng(p.latitude, p.longitude);
                      if (Navigator.canPop(context)) Navigator.pop(context);
                      saveAddress();
                    }
                  }),
            ],
          )
        ],
      );
    }
    return Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Add New Address', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,elevation : 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, null);
                }
              }),
        ),
        body: body);
  }

  void validateAddress() {
    if (flatNo.text.trim().length == 0) {
      setState(() {
        flatError = 'Please fill this field';
      });
      return;
    }
    if (colony.text.trim().length == 0) {
      setState(() {
        colonyError = 'Please fill this field';
      });
      return;
    }
    if (landmark.text.trim().length == 0) {
      setState(() {
        landmarkError = 'Please fill this field';
      });
      return;
    }
    if (pincode.text.trim().length == 0) {
      setState(() {
        pincodeError = 'Please fill this field';
      });
      return;
    }
    addingAddress = false;
    fetchingLocationData = true;
    setState(() {});
  }

  Future fetchLocationData() async {
    try {
      var res = await postMap('/customer/get-delivery-distance',
          {'customerId': id, 'password': password}, context);
      if (res.statusCode == 200) maxDistanceOfDelivery = double.parse(res.body);
      String uri = "https://maps.googleapis.com/maps/api/geocode/json?address=";
      uri +=
          landmark.text.trim().replaceAll(' ', '+') +
          "&components=country:IN|postal_code:" +
          pincode.text.trim();
      uri += "&key=AIzaSyA6VaH0-8E3e342zmuwY3SoZ4IhemmVpQc";
      print(uri);
      var response = await get(uri);
      if (response.statusCode == 200) {
        try {
          var decoded = json.decode(response.body) as Map;
          print(decoded);
          double lat = double.parse((decoded['results'] as List)
              .first['geometry']['location']['lat']
              .toString());
          double long = double.parse((decoded['results'] as List)
              .first['geometry']['location']['lng']
              .toString());
          double min = double.infinity;
          String selectMin;
          for (var key in Cache.locations.keys) {
            double dis = Geolocator.distanceBetween(
                Cache.locations[key][0], Cache.locations[key][1], lat, long);
            if (dis < min) {
              min = dis;
              selectMin = key;
            }
          }
          Cache.outletId = selectMin;
          position = LatLng(lat, long);
        } catch (err) {
          position = LatLng(Cache.latitude, Cache.longitude);
        }
        initialzeMap();
        setState(() {
          fetchingLocationData = false;
        });
      } else
        throw NullThrownError();
    } catch (err) {
      print(err);
      setState(() {
        position = null;
        fetchingLocationData = false;
      });
    }
  }
}
