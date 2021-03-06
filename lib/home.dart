import 'package:demo/selectables.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'orderdetails.dart';
import 'about-us.dart';
import 'models.dart';
import 'orders.dart';
import 'login.dart';
import 'profile.dart';
import 'browse-store.dart';
import 'widgets.dart';
import 'notifications.dart' as cts;
import 'package:flutter/material.dart';
import 'server.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'selectables.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String customerName = '';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

BuildContext homeContext;
List<BrowseStore> nearbyStores = [];
List<EdvOffer> edvOffers = [];
List<Widget> bodyList = [];


  // Default font GoogleFonts.poppins() use kiya hu 
class _HomeState extends State<Home> {
  Timer timer;
  int _current = 0;
  bool initialized = false;
  Map<String, List<StoreItem>> dashboardItems = {};
  bool fetchingStores = true;
  final FirebaseMessaging _fc = FirebaseMessaging();
  List<CtsNotification> notifications = [];
  int cartCount = 0;
  List<String> couponOffers = [];
  bool searching = false;
  NotificationIcon notIcon = NotificationIcon();
  Position position;
  TextEditingController query = TextEditingController();
  bool expanded = false;
  @override
  void initState() {
    super.initState();
    Cache.placeholder = AssetImage('assets/no-image.png');
    if (!Cache.isWeb) {
      _fc.configure(onMessage: (message) async {
        if (message['data']['orderId'] == null) return;
        getOrderDetails(message['data']['orderId'].toString());
        notIcon.state.checkNotifications();
      }, onResume: (message) async {
        if (message['data']['orderId'] == null) return;
        getOrderDetails(message['data']['orderId'].toString());
        notIcon.state.checkNotifications();
      }, onLaunch: (message) async {
        if (message['data']['orderId'] == null) return;
        getOrderDetails(message['data']['orderId'].toString());
        notIcon.state.checkNotifications();
      });
      _fc.subscribeToTopic(Cache.vendorId + 'Offer');
      _fc.getToken().then((token) {
        postMap('/customer/save-fcm-token',
            {'customerId': id, 'password': password, 'token': token}, context);
      });
    }
  }

  Future getNotifications() async {
    try {
      showDialog(context: context, builder: (context) => PendingDialog());
      var response = await postMap(
          '/customer/notifications',
          {
            'customerId': id,
            'password': password,
          },
          context);
      if (response.statusCode == 200) {
        notifications.clear();
        var jsonArray = json.decode(response.body) as List;
        notifications = jsonArray
            .map((not) => CtsNotification.fromJson(not, context))
            .toList();
        if (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => cts.Notifications(
                      notifications: notifications,
                    )));
      }
    } catch (err) {}
  }

  Future getOutletsData() async {
    try {
      var res = await postMap('/customer/get-coupon-offers',
          {'customerId': id, 'password': password}, context);
      couponOffers = (json.decode(res.body) as List).cast<String>();
      await getVendorStores();
      var response = await postMap('/customer/get-favorites',
          {'customerId': id, 'password': password}, context);
      if (response.statusCode == 200) {
        Cache.favorites = (json.decode(response.body) as List).cast<String>();
      }
    } catch (err) {
      print(err);
      nearbyStores.clear();
      dashboardItems.clear();
      setState(() {
        fetchingStores = false;
      });
    }
  }

  Widget getDrawer() {
    return Drawer(
        child: Column(
      children: [
        DrawerHeader(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            child: Container(
              color: Cache.appBarColor,
              child: Center(
                child: ClipRRect(
                    child: Image.asset('assets/logo.png',
                        height: 128, width: 128, fit: BoxFit.fill),
                    borderRadius: BorderRadius.circular(64)),
              ),
            )),
        Expanded(
            child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                getNotifications();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Icon(Icons.message, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Messages')
                  ]),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    editDetails(context);
                  },
                  child: Row(children: [
                    Icon(Icons.person, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('My Profile')
                  ]),
                ),
              ],
            ),
            /*Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    getOrderHistory(context, 'accepted');
                  },
                  child: Row(children: [
                    Icon(Icons.location_pin, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Live Order Tracking')
                  ]),
                ),
              ],
            ),*/
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    getOrderHistory(context, null);
                  },
                  child: Row(children: [
                    Icon(Icons.history, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('My Orders')
                  ]),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    if (edvOffers.length == 0) {
                      showDialog(
                          context: context,
                          builder: (context) => MessageDialog(
                              message: 'Sorry! No Offer Found :('));
                      return;
                    }
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return SimpleDialog(
                            titlePadding: EdgeInsets.all(0),
                            contentPadding: EdgeInsets.all(0),
                            children: edvOffers.map((e) {
                              return InkWell(
                                onTap: () {
                                  getSelectables(e, context);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedImage(
                                        id: e.selectableId,
                                        width: 320,
                                        height: 160),
                                    Text(e.title),
                                    Divider(indent: 10)
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        });
                  },
                  child: Row(children: [
                    Icon(Icons.local_offer, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Offers')
                  ]),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                            titlePadding: EdgeInsets.all(0),
                            contentPadding: EdgeInsets.all(0),
                            children: nearbyStores.map((st) {
                              return InkWell(
                                onTap: () {
                                  getStoreItems(st, context);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedImage(
                                      id: st.storeId,
                                      width: 320,
                                      height: 160,
                                    ),
                                    Text(st.businessName),
                                    Divider(indent: 10)
                                  ],
                                ),
                              );
                            }).toList()));
                  },
                  child: Row(children: [
                    Icon(Icons.restaurant_menu, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Menu')
                  ]),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    TextEditingController _ctr = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        titlePadding: EdgeInsets.all(0),
                        title: Container(
                            padding: EdgeInsets.all(8),
                            child: Text('Write Your Feedback',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white)),
                            color: Cache.appBarColor),
                        content: Container(
                          width: 200,
                          height: 100,
                          child: TextField(
                            controller: _ctr,
                            maxLines: 8,
                            decoration: InputDecoration(
                                labelText: '', border: OutlineInputBorder()),
                          ),
                        ),
                        actions: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                  child: FlatButton(
                                color: Cache.appBarColor,
                                child: Text('Save Feedback',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  postMap(
                                      '/customer/save-feedback',
                                      {
                                        'customerId': id,
                                        'password': password,
                                        'feedback': _ctr.text
                                      },
                                      context);
                                  if (Navigator.canPop(context))
                                    Navigator.pop(context);
                                },
                              )))
                        ],
                      ),
                    );
                  },
                  child: Row(children: [
                    Icon(Icons.feedback, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Give Feedback')
                  ]),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutUs()));
                  },
                  child: Row(children: [
                    Image.asset('assets/logo.png',
                        height: 24, width: 24, fit: BoxFit.fill),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('About Us')
                  ]),
                ),
              ],
            ),
            Column(
              children: [
                Divider(),
                InkWell(
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    showDialog(
                        context: context, builder: (context) => Pending());
                    dynamic config;
                    if (Cache.isWeb)
                      config = WebFile("config");
                    else
                      config = File(
                          (await getApplicationDocumentsDirectory()).path +
                              '/config');
                    if (config.existsSync()) config.deleteSync();
                    id = null;
                    password = null;
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                        (Route<dynamic> route) => false);
                  },
                  child: Row(children: [
                    Icon(Icons.logout, color: Colors.brown),
                    Padding(padding: EdgeInsets.all(16)),
                    Text('Logout')
                  ]),
                ),
              ],
            )
          ],
        ))
      ],
    ));
  }

  Future searchItems(String query) async {
    showDialog(context: context, builder: (context) => Pending());
    var response = await postMap('/customer/search',
        {'customerId': id, 'password': password, 'query': query}, context);
    if (response.statusCode == 200) {
      List<StoreItem> results = (json.decode(response.body) as List)
          .map((e) => StoreItem.fromJson(e))
          .toList();
      if (Navigator.canPop(context)) Navigator.pop(context);
      sectionItems.clear();
      sectionItems = results;
      searching = false;
      searchedItems.clear();
      search.clear();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StoreDetails(
                  store: BrowseStore('Results', '10', '1234', []))));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (!initialized && !Cache.isWeb) {
      homeContext = context;
      initialized = true;
      new Timer(Duration(seconds: 1), getOutletsData);
    } else if (!initialized && Cache.isWeb) {
      Cache.placeholder = AssetImage('assets/no-image.png');
      homeContext = context;
      initialized = true;
      new Timer(Duration(seconds: 1), getOutletsData);
    }

    Widget scaffold = Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            textTheme:
                TextTheme(title: TextStyle(fontSize: 16, color: Colors.black)),
            elevation: 0,
            title: Container(
                margin: EdgeInsets.only(left: 0, right: 0),
                width: screenWidth - 16,
                child: TextField(
                    onSubmitted: (val) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      searching = false;
                    },
                    controller: query,
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                            child:
                                Icon(Icons.send, size: 18, color: Colors.green),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              searching = false;
                              if (query.text.trim().isEmpty)
                                return;
                              else
                                searchItems(query.text);
                            }),
                        hintText: customerName +
                            ', Search ' +
                            Cache.vendor.businessName,
                        contentPadding: EdgeInsets.only(left: 8, right: 8),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder())))),
        drawer: getDrawer(),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Cache.appBarColor,
            onPressed: () {
              showCart(context);
            },
            child: CartButton()),
        body: SafeArea(
            child: Container(
          //color: Colors.blue,
          width: screenWidth,
          child: Stack(
            children: [
              Container(
                
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  //color: Colors.black,
                  ),
              ),
              Positioned(
                top: 5,
                width: MediaQuery.of(context).size.width,
                child: Center(child: OrderTypeSelector()),
              ),
              Positioned(
                  top: 40,
                  height: MediaQuery.of(context).size.height - 44,
                  width: screenWidth,
                  child: Container(
                    //color: Colors.purple
                    child: fetchingStores
                        ? Center(
                            child: Card(
                                shape: CircleBorder(),
                                //color: Color(0xA0000000),
                                child: Padding(
                                    child: PendingDialog(),
                                    padding: EdgeInsets.all(8))))
                        : bodyList.length == 0
                            ? Center(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Text('It seems empty here!!\n',
                                        style: TextStyle(color: Colors.grey)),
                                    FlatButton(
                                        color: Cache.appBarColor,
                                        child: Text('Refresh',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          setState(() {
                                            fetchingStores = true;
                                          });
                                          getOutletsData();
                                        })
                                  ]))
                            : 
                            //Text("Diamg ka bhosdda"),
                            ListView(
                                physics: BouncingScrollPhysics(),
                                children: bodyList
                                ),
                    width: screenWidth - 8,
                    padding: EdgeInsets.only(top: 10),
                    margin:
                        EdgeInsets.only(top: 4, left: 0, right: 0, bottom: 0),
                    height: MediaQuery.of(context).size.height - 144,
                    decoration: BoxDecoration( 
                      color: Colors.white70,
                      border: Border.all(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                  )),
            ],
          ),
        )));
    return scaffold;
  }

  Future getVendorStores() async {
    try {
      var response = await postMap(
          '/customer/vendor-stores',
          {
            'customerId': id,
            'password': password,
          },
          context);
      dashboardItems.clear();
      bodyList.clear();
      if (couponOffers.isNotEmpty)
        bodyList.add(
          CarouselSlider(
            items: couponOffers
                .map((item) => Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Container(
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Image.network(s3Domain + item,
                              fit: BoxFit.cover, width: 1000.0),
                        ),
                      ),
                    )))
                .toList(),
            options: CarouselOptions(
                height: 150,
                autoPlay: couponOffers.length <= 1 ? false : true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
        );
      nearbyStores.clear();
      edvOffers.clear();
      if (response.statusCode == 200) {
        var jsonArray = json.decode(response.body) as List;
        nearbyStores =
            jsonArray.map((store) => BrowseStore.fromJson(store)).toList();
      } else
        throw 'errro';
      var boom = await postMap(
          '/customer/get-edv-offers',
          {
            'customerId': id,
            'password': password,
          },
          context);
      if (boom.statusCode == 200) {
        edvOffers = (json.decode(boom.body) as List)
            .map((b) => EdvOffer.fromJson(b))
            .toList();
      }
      var res = await postMap('/customer/dashboard-items',
          {'customerId': id, 'password': password}, context);
      if (res.statusCode == 200) {
        var jsonBody = json.decode(res.body) as Map;
        for (var key in jsonBody.keys) {
          if (key == 'Name')
            customerName = jsonBody[key].toString();
          else
            dashboardItems.putIfAbsent(
                key,
                () => (jsonBody[key] as List)
                    .map((item) => StoreItem.fromJson(item))
                    .toList());
        }
        jsonBody.remove('Name');
      } else
        throw 'error';
      bodyList.add(SectionListView());
      if (edvOffers.isNotEmpty) bodyList.add(EdvOfferListView());
      for (var title in dashboardItems.keys) {
        bodyList.add(DashboardItemView(
            items: dashboardItems[title], title: title, storeId: title));
      }
      for (var st in nearbyStores) {
        bodyList.add(DashboardItemView(
            items: st.items, title: st.businessName, storeId: st.storeId));
      }
      setState(() {
        fetchingStores = false;
      });
    } catch (err) {
      print(err);
      nearbyStores.clear();
      dashboardItems.clear();
      setState(() {
        fetchingStores = false;
      });
    }
  }

  Future getOrderDetails(String orderId) async {
    showDialog(context: context, builder: (context) => PendingDialog());
    var response = await postMap('/customer/get-order-details',
        {'customerId': id, 'password': password, 'orderId': orderId}, context);
    if (response.statusCode == 200) {
      CustomerOrder order =
          CustomerOrder.fromJson(json.decode(response.body), context);
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetails(
                      order: order,
                    )));
      }
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

class OrderTypeSelector extends StatefulWidget {
  @override
  _OrderTypeSelectorState createState() => _OrderTypeSelectorState();
}

class _OrderTypeSelectorState extends State<OrderTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (Cache.orderType == 0)
              return;
            else
              setState(() {
                Cache.orderType = 0;
              });
          },
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: Text('Delivery',
                style: GoogleFonts.poppins(
                  fontWeight: Cache.orderType == 0 ?FontWeight.w600:FontWeight.w200,
                  fontSize:17,
                  color: Cache.orderType == 0 ? Colors.red : Colors.black
                )
                    ),
            decoration: BoxDecoration(
              //color: Colors.red,
              //color: Cache.orderType == 0 ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (Cache.orderType == 1)
              return;
            else
              setState(() {
                Cache.orderType = 1;
              });
          },
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: Text('Takeaway',
                style: GoogleFonts.poppins(
                  fontWeight: Cache.orderType == 1 ?FontWeight.w600:FontWeight.w200,
                  fontSize: 17,
                  color: Cache.orderType == 1 ? Colors.red : Colors.black
                )
                    ),
            decoration: BoxDecoration(
              //color: Cache.orderType == 1 ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (Cache.orderType == 2)
              return;
            else
              setState(() {
                Cache.orderType = 2;
              });
          },
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            child: Text('Dine-In',
                style: GoogleFonts.poppins(
                  fontWeight: Cache.orderType == 2 ?FontWeight.w600:FontWeight.w200,
                  fontSize: 17,
                  color: Cache.orderType ==  2 ? Colors.red : Colors.black
                )
                    ),
            decoration: BoxDecoration(
              //color: Cache.orderType == 2 ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

Future getStoreItems(BrowseStore store, BuildContext context,
    {String itemId}) async {
      print("Calling getStore Items");
  showDialog(context: context, builder: (context) => PendingDialog());
  var response = await postMap(
      '/customer/get-store-items',
      {'customerId': id, 'password': password, 'storeId': store.storeId},
      context);
  if (response.statusCode == 200 && Navigator.canPop(context)) {
    var jsonArray = json.decode(response.body) as List;
    sectionItems.clear();
    sectionItems = jsonArray.map((item) => StoreItem.fromJson(item)).toList();
    var itms = sectionItems.where((e) => e.itemId == itemId);
    if (itms.isNotEmpty) {
      var itm = itms.first;
      sectionItems.removeWhere((e) => e.itemId == itemId);
      sectionItems.insert(0, itm);
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      searching = false;
      searchedItems.clear();
      search.clear();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => StoreDetails(store: store)));
    }
  } else if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

class SectionView extends StatelessWidget {
  const SectionView({
    @required this.st,
  });

  final BrowseStore st;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      //color: Colors.amber,
      //height: 200,
      child: Column(children: [
        Card(
          elevation: 5,
          shadowColor: Colors.red[200],
          child:
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                decoration: new BoxDecoration(
                  //color:Colors.red[50],
                  borderRadius: BorderRadius.circular(0)
              ),
                width: 200,
                height:150,                             
                child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: FadeInImage.assetNetwork(
              image: s3Domain + st.storeId,
              placeholder: 'assets/no-image.png',
              height: 100,
              width: 100,
              fit: BoxFit.fill,
              )),
              ),
              Center(
              child: Text(st.businessName,
                  style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  )
                    )
                  )  
            ],
          ),
                //elevation:100,
              ),
            // Center(
            //   child: Text(st.businessName,
            //       style: TextStyle(
            //           color: Colors.black87,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w400)
            //         )
            //       )          
            ]
           ),
    );
  }
}

class NotificationIcon extends StatefulWidget {
  final _NotificationIconState state = _NotificationIconState();
  @override
  _NotificationIconState createState() => state;
}

class _NotificationIconState extends State<NotificationIcon> {
  bool fetchingNotifications = false;
  int notificationCount = 0;
  List<CtsNotification> notifications = [];
  @override
  Widget build(BuildContext context) {
    if (!searching) FocusScope.of(context).requestFocus(FocusNode());
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          IconButton(
            icon: Icon(Icons.notifications,
                color:
                    notificationCount > 0 ? Colors.yellow : Cache.appBarColor),
            onPressed: () {
              getNotifications();
            },
          ),
          Positioned(
              right: 0,
              child: notificationCount == 0
                  ? Card()
                  : Card(
                      color: Colors.orange,
                      child: Padding(
                          padding: EdgeInsets.all(2),
                          child: Text(notificationCount.toString(),
                              style: TextStyle(color: Colors.white))),
                      shape: CircleBorder()))
        ],
      ),
    );
  }

  Future getNotifications() async {
    try {
      showDialog(context: context, builder: (context) => PendingDialog());
      var response = await postMap(
          '/customer/notifications',
          {
            'customerId': id,
            'password': password,
          },
          context);
      if (response.statusCode == 200) {
        notifications.clear();
        var jsonArray = json.decode(response.body) as List;
        notifications = jsonArray
            .map((not) => CtsNotification.fromJson(not, context))
            .toList();
        if (Navigator.canPop(context)) Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => cts.Notifications(
                      notifications: notifications,
                    )));
      }
    } catch (err) {}
  }

  Future checkNotifications() async {
    if (fetchingNotifications == true) return;
    fetchingNotifications = true;
    var response = await http.post(domain + '/customer/check-notifications',
        body: {
          'customerId': id,
          'password': password,
          'vendorId': Cache.vendorId
        });
    try {
      notificationCount = int.parse(response.body);
    } catch (err) {
      notificationCount = 0;
    }
    if (mounted) setState(() {});
    fetchingNotifications = false;
  }
}

class CartButton extends StatefulWidget {
  @override
  _CartButtonState createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  bool initialized = false;
  int itemCount = 0;
  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      initialized = true;
      Timer.periodic(Duration(seconds: 10), (timer) {
        if (mounted)
          setState(() {
            itemCount = cart.cartItems.length;
          });
      });
    }
    return Stack(
      children: [
        Icon(Icons.shopping_cart, color: Colors.white),
        Positioned(
            right: 0,
            top: 0,
            child: itemCount == 0
                ? Padding(padding: EdgeInsets.all(0))
                : Card(
                    margin: EdgeInsets.all(0),
                    color: Colors.orange,
                    shape: CircleBorder(),
                    child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Text(itemCount.toString(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 8)))))
      ],
    );
  }
}

class SectionListView extends StatefulWidget {
  @override
  _SectionListViewState createState() => _SectionListViewState();
}

class _SectionListViewState extends State<SectionListView> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return 
    Stack(
      children: [
        Card(
          elevation: 0,
          margin: EdgeInsets.all(4),
          color: Colors.orange[100],
          child: Container(
              height: 240,
              decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(100),
                  //     topRight: Radius.circular(00))
                      ),
              margin: EdgeInsets.all(0)),
        ),
        Positioned(
            top: 10,
            left: 12,
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text( 
                  "Explore",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
        Positioned(
            top: 40,
            width: screenWidth,
            child: Container(
              width: screenWidth,
              margin: EdgeInsets.only(left: 4, right: 12),
              height: 200,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: nearbyStores.map((st) {
                    return InkWell(
                        child: SectionView(st: st),
                        onTap: () {
                          getStoreItems(st, context);
                        });
                  }).toList()),
            )),
      ],
    );
  }
}

class DashboardItemView extends StatefulWidget {
  final List<StoreItem> items;
  final String title;
  final String storeId;
  DashboardItemView(
      {@required this.items, @required this.title, @required this.storeId});
  @override
  _DashboardItemViewState createState() =>
      _DashboardItemViewState(this.items, this.title);
}

class _DashboardItemViewState extends State<DashboardItemView> {
  List<StoreItem> items;
  String title;
  _DashboardItemViewState(List<StoreItem> it, String tit) {
    items = it;
    title = tit;
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Text(" "); 
    //Stack(
    //   children: [
    //     Card(
    //       elevation: 0,
    //       margin: EdgeInsets.all(4),
    //       color: Colors.orange[100],
    //       child: Container(
    //           height: 240,
    //           decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(170),
    //                   topRight: Radius.circular(00))),
    //           margin: EdgeInsets.all(0)),
    //     ),
    //     Positioned(
    //         top: 10,
    //         left: 12,
    //         width: screenWidth,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(title,
    //                 style: TextStyle(
    //                     fontWeight: FontWeight.bold, color: Colors.black)),
    //             InkWell(
    //                 child: Padding(
    //                     child: Text('View All',
    //                         style: TextStyle(color: Colors.blue)),
    //                     padding: EdgeInsets.only(right: 28)),
    //                 onTap: () {
    //                   getStoreItems(
    //                       BrowseStore(title, '10', widget.storeId, []),
    //                       context);
    //                 })
    //           ],
    //         )),
    //     Positioned(
    //         top: 40,
    //         width: screenWidth,
    //         child: Container(
    //           margin: EdgeInsets.only(left: 4, right: 12),
    //           height: 200,
    //           child: ListView(
    //               scrollDirection: Axis.horizontal,
    //               children: items.map((itm) {
    //                 return InkWell(
    //                     onTap: () {
    //                       getStoreItems(
    //                           BrowseStore(title, '10', widget.storeId, []),
    //                           context,
    //                           itemId: itm.itemId);
    //                     },
    //                     child: Stack(children: [
    //                       Container(
    //                         width: 150,
    //                         child: Card(
    //                             elevation: 1,
    //                             child: Column(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 ClipRRect(
    //                                   borderRadius: BorderRadius.circular(96),
    //                                   child: CachedImage(
    //                                       id: itm.itemId,
    //                                       width: 96,
    //                                       height: 96),
    //                                 ),
    //                                 Text(
    //                                   itm.header,
    //                                   style: TextStyle(),
    //                                   textAlign: TextAlign.center,
    //                                   maxLines: 2,
    //                                 ),
    //                                 Padding(padding: EdgeInsets.all(4)),
    //                                 (double.parse(itm.discount) > 0)
    //                                     ? Text(Cache.currency + ' ' + itm.price,
    //                                         style: TextStyle(
    //                                             color: Colors.grey,
    //                                             decoration:
    //                                                 TextDecoration.lineThrough))
    //                                     : Padding(padding: EdgeInsets.all(0)),
    //                                 Container(
    //                                   padding: EdgeInsets.all(8),
    //                                   child: Text(
    //                                       Cache.currency +
    //                                           ' ' +
    //                                           (double.parse(itm.price) -
    //                                                   double.parse(
    //                                                       itm.discount))
    //                                               .toStringAsFixed(2),
    //                                       style: TextStyle(
    //                                           fontSize: 17,
    //                                           fontWeight: FontWeight.bold)),
    //                                   decoration: BoxDecoration(
    //                                       borderRadius:
    //                                           BorderRadius.circular(20),
    //                                       color: Colors.green[100]),
    //                                 ),
    //                                 Padding(padding: EdgeInsets.all(8))
    //                               ],
    //                             )),
    //                       ),
    //                       Positioned(
    //                           child: CircleAvatar(
    //                               radius: 18,
    //                               backgroundColor: Colors.green,
    //                               child: title == 'Discounts'
    //                                   ? Text(
    //                                       (double.parse(itm.discount) /
    //                                                   double.parse(itm.price) *
    //                                                   100)
    //                                               .toStringAsFixed(0) +
    //                                           '%\nOff',
    //                                       style: TextStyle(
    //                                           fontSize: 10,
    //                                           color: Colors.white),
    //                                       textAlign: TextAlign.center,
    //                                     )
    //                                   : Row(
    //                                       mainAxisSize: MainAxisSize.min,
    //                                       crossAxisAlignment:
    //                                           CrossAxisAlignment.center,
    //                                       children: [
    //                                         Text(
    //                                           itm.rating.toStringAsFixed(1),
    //                                           style: TextStyle(
    //                                               fontSize: 10,
    //                                               color: Colors.white),
    //                                           textAlign: TextAlign.center,
    //                                         ),
    //                                         Icon(Icons.star,
    //                                             color: Colors.yellow, size: 12)
    //                                       ],
    //                                     )),
    //                           right: 0)
    //                     ]));
    //               }).toList()),
    //         )),
    //   ],
    // );
  }
}

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    Key key,
    @required this.screenWidth,
  }) : super(key: key);

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Cache.appBarColor,
      elevation: 8,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
              child: InkWell(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.local_offer, color: Colors.white),
                    Text('Offers',
                        style: TextStyle(color: Colors.white, fontSize: 14))
                  ]),
                  onTap: () {}),
              padding: EdgeInsets.all(4)),
          Padding(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CartButton(),
                Text('Cart',
                    style: TextStyle(color: Colors.white, fontSize: 14))
              ]),
              padding: EdgeInsets.all(4)),
          Padding(
              child: InkWell(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restaurant_menu, color: Colors.white),
                  Text('Menu',
                      style: TextStyle(color: Colors.white, fontSize: 14))
                ]),
                onTap: () {},
              ),
              padding: EdgeInsets.all(4)),
          Padding(
              child: InkWell(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.history, color: Colors.white),
                    Text('My Orders',
                        style: TextStyle(fontSize: 14, color: Colors.white))
                  ]),
                  onTap: () {
                    getOrderHistory(context, null);
                  }),
              padding: EdgeInsets.all(4)),
          Padding(
              child: InkWell(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.person, color: Colors.white),
                    Text('Profile',
                        style: TextStyle(fontSize: 14, color: Colors.white))
                  ]),
                  onTap: () {
                    editDetails(context);
                  }),
              padding: EdgeInsets.all(4)),
        ],
      ),
    );
  }
}

class PopupMenuItems extends StatefulWidget {
  @override
  _PopupMenuItemsState createState() => _PopupMenuItemsState();
}

class _PopupMenuItemsState extends State<PopupMenuItems> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      child: Icon(Icons.dehaze_rounded, color: Cache.appBarColor),
      itemBuilder: (context) => [
        PopupMenuItem(child: Text('About Us'), value: 'about'),
        PopupMenuItem(child: Text('Give Feedback'), value: 'feedback'),
        PopupMenuItem(child: Text('Logout'), value: 'logout'),
      ],
      onSelected: (val) async {
        if (val == 'about') {
        } else if (val == 'logout') {
        } else if (val == 'feedback') {}
      },
    );
  }
}

class EdvOfferListView extends StatefulWidget {
  @override
  _EdvOfferListViewState createState() => _EdvOfferListViewState();
}

class _EdvOfferListViewState extends State<EdvOfferListView> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Card(
          elevation: 0,
          margin: EdgeInsets.all(400),
          color: Colors.orange[100],
          child: Container(
              height: 240,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(170),
                      topRight: Radius.circular(00))),
              margin: EdgeInsets.all(0)),
        ),
        Positioned(
            top: 10,
            left: 12,
            width: screenWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Everyday Value Offers',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            )),
        Positioned(
            top: 40,
            width: screenWidth,
            child: Container(
              margin: EdgeInsets.only(left: 4, right: 12),
              height: 200,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: edvOffers.map((st) {
                    return InkWell(
                        child: SectionView(
                            st: BrowseStore(
                                st.title, '20', st.selectableId, [])),
                        onTap: () {
                          getSelectables(st, context);
                        });
                  }).toList()),
            )),
      ],
    );
  }
}

Future getSelectables(EdvOffer edvOffer, BuildContext context) async {
  showDialog(context: context, builder: (context) => Pending());
  var response = await postMap(
      '/customer/get-edv-offer-items',
      {
        'customerId': id,
        'password': password,
        'selectableId': edvOffer.selectableId
      },
      context);
  if (response.statusCode == 200) {
    var jsonBody = json.decode(response.body) as Map;
    List<StoreItem> purchasables = (jsonBody['purchasables'] as List)
        .map((p) => StoreItem.fromJson(p))
        .toList();
    List<StoreItem> choosables = (jsonBody['choosables'] as List)
        .map((c) => StoreItem.fromJson(c))
        .toList();
    if (Navigator.canPop(context)) {
      SelectableData.clear();
      SelectableData.initialize(edvOffer.buyN, edvOffer.getM, 0, 0,
          edvOffer.selectableId, edvOffer.title);
      Navigator.pop(context);
      if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Selectables(
                    purchaseItems: purchasables,
                    choosableItems: choosables,
                  )));
    }
  }
}

Future getOrderHistory(BuildContext context, String type) async {
  showDialog(context: context, builder: (context) => PendingDialog());
  var response = await postMap('/customer/get-order-history',
      {'customerId': id, 'password': password}, context);
  if (response.statusCode == 200) {
    var jsonArray = json.decode(response.body) as List;
    List<MiniOrder> orders =
        jsonArray.map((order) => MiniOrder.fromJson(order, context)).toList();
    if (type != null) orders.removeWhere((e) => e.status != 'Accepted');
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Orders(
                    orders: orders,
                  )));
    }
  } else if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

Future editDetails(BuildContext context) async {
  showDialog(context: context, builder: (context) => PendingDialog());
  var response = await postMap('/customer/get-details',
      {'customerId': id, 'password': password}, context);
  if (response.statusCode == 200) {
    Map<String, dynamic> details = json.decode(response.body);
    String name = details['Name'] as String;
    String address = details['Address'] as String;
    String mobile = details['Mobile'];
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
                    newMember: false,
                    name: name,
                    address: address,
                    mobile: mobile,
                  )));
    }
  } else if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}
