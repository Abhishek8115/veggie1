import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cache.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.call),
        onPressed: () {
          launch('tel://' + Cache.contact);
        },
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            child: Stack(
              children: [
                Container(
                    height: 150,
                    decoration: BoxDecoration(
                        boxShadow: [],
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Cache.appBarColor, Colors.brown]))),
                Positioned(
                    bottom: 10,
                    left: MediaQuery.of(context).size.width / 2 - 64,
                    child: CircleAvatar(
                        radius: 68,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                            child: Image.asset(
                              'assets/logo.png',
                              height: 128,
                              width: 128,
                            ),
                            borderRadius: BorderRadius.circular(128)))),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }),
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(8)),
          Text(Cache.vendor.businessName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            Cache.vendor.businessAddress,
            textAlign: TextAlign.center,
          ),
          Divider(),
          Text(Cache.vendor.name, textAlign: TextAlign.center),
          Divider(),
          Row(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Icon(Icons.call, color: Colors.blue),
              Padding(child: Text(Cache.contact), padding: EdgeInsets.all(8)),
            ],
          ),
          Divider(),
          Row(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Icon(Icons.mail, color: Colors.red),
              Padding(padding: EdgeInsets.all(8), child: Text(Cache.email)),
            ],
          ),
          Divider(),
          Row(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Image.network(
                  'https://www.archerstack.com/static/webicons/fb-icon.png',
                  height: 24,
                  width: 24),
              Padding(padding: EdgeInsets.all(8), child: Text(Cache.fbId)),
            ],
          ),
          Divider(),
          Row(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Image.network(
                  'https://www.archerstack.com/static/webicons/insta-icon.png',
                  height: 24,
                  width: 24),
              Padding(padding: EdgeInsets.all(8), child: Text(Cache.instaId)),
            ],
          ),
          Divider(),
          InkWell(
              child: Text('Privacy-Policy',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                launch("https://www.archerstack.com/privacy-policy");
              })
        ],
      ),
    );
  }
}
