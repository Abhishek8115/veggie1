import 'models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html';
import 'server.dart';
import 'package:socket_io_client/socket_io_client.dart';

dynamic window;

class Cache {
  static String vendorId = '919877428591';
  static String outletId = '919877428591';
  static Vendor vendor =
      new Vendor('Mr. Harvansh Singh', "Veggie Singh", "", '10');
  static String contact = '919877428591';
  static String email = 'harvanshsingh@hotmail.com';
  static String fbId = '';
  static String instaId = '';
  static String currency = String.fromCharCode(0x20B9);
  static var appBarColor = Colors.red;
  static var appBarActionsColor = Colors.black;
  static var backgroundColor = Color(0xB0000000);
  static var loginBackgroundColor = Colors.white;
  static bool isRestaurantFriendly = false;
  static double latitude = 34.015916;
  static double longitude = 78.301331;
  static List<String> favorites = [];
  static int orderType = 0; //0-> delivery, 1-> take-way, 2-> dine-in
  static bool isWeb = kIsWeb;
  static Socket socket;
  static String trackOrderId;
  static Map<String, ImageProvider> images = {};
  static dynamic placeholder;
  static Map<String, List<double>> locations = {
    '919877428591': [26.693983148784152, 79.21410792591593],
  };
}

class WebFile {
  String field, value;
  WebFile(this.field);
  void writeAsStringSync(String content) {
    window.localStorage.remove(field);
    window.localStorage.putIfAbsent(field, () => content);
  }

  String readAsStringSync() {
    return window.localStorage[field];
  }

  bool existsSync() {
    return window.localStorage.containsKey(field);
  }

  void deleteSync() {
    window.localStorage.remove(field);
  }
}

class CachedImage extends StatefulWidget {
  final String id;
  final double width, height;
  CachedImage({@required this.id, this.width, this.height});
  CachedImageState createState() => CachedImageState();
}

class CachedImageState extends State<CachedImage> {
  @override
  Widget build(BuildContext context) {
    if (!Cache.images.containsKey(widget.id)) {
      Cache.images
          .putIfAbsent(widget.id, () => NetworkImage(s3Domain + widget.id));
    }
    return FadeInImage(
        placeholder: Cache.placeholder,
        image: Cache.images[widget.id],
        height: widget.height,
        width: widget.width,
        fit: BoxFit.fill);
  }
}
