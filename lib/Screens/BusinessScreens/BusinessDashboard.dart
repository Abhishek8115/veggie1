import 'package:flutter/material.dart';
import 'package:swap/Screens/BusinessScreens/BusinessOrders.dart';
import 'package:swap/Screens/BusinessScreens/BusinessSupport.dart';
import 'package:swap/Screens/BusinessScreens/ChatPage.dart';
import 'package:swap/Screens/BusinessScreens/MyPosts.dart';
import 'package:swap/Screens/BusinessScreens/Wallet.dart';
import 'package:swap/Screens/BusinessScreens/AddItems.dart';
import 'package:swap/Screens/BusinessScreens/ShopRoutine.dart';
import 'package:swap/Screens/BusinessScreens/BusinessFlashSale.dart';
import 'package:swap/Widgets/CategoriesList.dart';
import 'package:swap/Screens/Cart.dart';
import 'package:swap/Screens/donate.dart';
import 'package:swap/Screens/fresh_sale.dart';
import 'package:swap/SplashScreen.dart';
import 'package:swap/Models/DataSchema.dart';
import 'BusinessEditProfile.dart';
class BusinessDashboard extends StatefulWidget {
  @override
  _BusinessDashboardState createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int itemCount =5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          child: ListView(
        children: [
          SizedBox(
            height: 30,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 30.0,
                //backgroundImage: Image.asset('user.png'),
                backgroundColor: Colors.transparent,
                child: Image.asset('assets/user.png'),
              ),
              Column(
                children: [
                  Text(
                    "Name",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    "Business Owner",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 16),
                  )
                ],
              )
            ],
          ),

          SizedBox(
            height: 25,
          ),

          // InkWell(
          //   onTap: (){
          //
          //
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(10, 10, 0,0),
          //     child: ListTile(
          //       leading: ConstrainedBox(
          //         constraints: BoxConstraints(
          //           maxWidth: 30,
          //           maxHeight: 30,
          //         ),
          //         child: Image.asset("assets/home.png", fit: BoxFit.cover),
          //       ),
          //       title: Text("Home"),
          //     ),
          //   ),
          // ),

          ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EditPost()));
            //   showModalBottomSheet(
            //     context: context,
            //     builder: (BuildContext bc) {
            //       return SafeArea(
            //         child: Container(
            //           child: new Wrap(
            //             children: <Widget>[
            //               new ListTile(
            //                   //leading: new Icon(Icons.giv),
            //                   title: new Text('Donate'),
            //                   onTap: () {
            //                     //_imgFromGallery();
            //                     Navigator.of(context).pop();
            //                   }),
            // 
            //               new ListTile(
            //                 //leading: new Icon(Icons.photo_camera),
            //                 title: new Text('Flash Sale'),
            //                 onTap: () {
            //                   //_imgFromCamera();
            //                   Navigator.of(context).pop();
            //                 },
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }
            // );
            },
            title: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10,0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child: Image.asset("assets/category.png", fit: BoxFit.cover),
                ),
                title: Text("Add Item"),
              ),
            ),
            //children: <Widget>[Text("children 1"), Text("children 2")],
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPosts_Business()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Image.asset("assets/myposts.png", fit: BoxFit.cover),
                ),
                title: Text("My Posts"),
              ),
            ),
          ),
            InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) =>BusinessEditProfile()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0,0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child: Icon(Icons.mode_edit),
                ),
                title: Text("Edit Profile"),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Business_ChatPage()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child: Image.asset("assets/chat.png", fit: BoxFit.cover),
                ),
                title: Text("Chat"),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Icon(Icons.shopping_cart_outlined, color: Colors.purpleAccent, size: MediaQuery.of(context).size.height*0.04)
                      //Image.asset("assets/myposts.png", fit: BoxFit.cover),
                ),
                title: Text("Cart"),
              ),
            ),
          ),

          // InkWell(
          //   onTap: (){
          //
          //     //Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
          //
          //
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(10, 0, 0,0),
          //     child: ListTile(
          //       leading: ConstrainedBox(
          //         constraints: BoxConstraints(
          //           maxWidth: 30,
          //           maxHeight: 30,
          //         ),
          //         child: Image.asset("assets/user.png", fit: BoxFit.cover),
          //       ),
          //       title: Text("Dashboard"),
          //     ),
          //   ),
          // ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Wallet_Business()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Image.asset("assets/wallet.png", fit: BoxFit.cover),
                ),
                title: Text("My Wallet"),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Business_Orders()));
              // Navigator.push(context, MaterialPageRoute(builder: (context) => Parking_Lot_Screen()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child: Image.asset("assets/bell.png", fit: BoxFit.cover),
                ),
                title: Text("Orders"),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Business_Support()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Image.asset("assets/support.png", fit: BoxFit.cover),
                ),
                title: Text("Support"),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShoppingRoutine()));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Icon(Icons.shop, color: Colors.blue)
                ),
                title: Text("Shop Details"),
              ),
            ),
          ),
          // InkWell(
          //   onTap: () {},
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          //     child: ListTile(
          //       leading: ConstrainedBox(
          //         constraints: BoxConstraints(
          //           maxWidth: 30,
          //           maxHeight: 30,
          //         ),
          //         child: Image.asset("assets/faq.png", fit: BoxFit.cover),
          //       ),
          //       title: Text("FAQ"),
          //     ),
          //   ),
          // ),

          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Splash()),
                  (Route<dynamic> route) => false);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ListTile(
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  child:
                      Image.asset("assets/logout2.png", fit: BoxFit.cover),
                ),
                title: Text("Logout"),
              ),
            ),
          ),

          SizedBox(
            height: 20,
          )
        ],
      )
      ),

      backgroundColor: Color(0xffE9E9E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => _scaffoldKey.currentState.openDrawer(),
          child: Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),
        title: Text("Dashboard", style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
              height: 150.0,
              width: 30.0,
              child: new GestureDetector(
                onTap: () {
                },
                child: Stack(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        onPressed: () {

                        }),
                    itemCount == 0
                        ? new Container()
                        : new Positioned(
                            child: new Stack(
                            children: <Widget>[
                              new Icon(Icons.brightness_1,
                                  size: 20.0, color: Colors.orange.shade500),
                              new Positioned(
                                  top: 4.0,
                                  right: 5.0,
                                  child: new Center(
                                    child: new Text(
                                      itemCount.toString(),
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                            ],
                          )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: BusinessFlashSale()
      // Column(
      //   children: [
      //     SizedBox(
      //       height: 10,
      //     ),
      //     Padding(
      //       padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //       child: Container(
      //         height: 40,
      //         color: Color(0xffE9E9E9),
      //         child:  FreshSale()
              // TabBar(
              //     unselectedLabelColor: Color(0xff656565),
              //     indicator: BoxDecoration(
              //         borderRadius: BorderRadius.only(
              //             topRight: Radius.circular(20),
              //             bottomLeft: Radius.circular(20)),
              //         color: Color(0xff62319E)),
              //     tabs: [
              //       Tab(
              //         child: Align(
              //           alignment: Alignment.center,
              //           child: Text(
              //             "Flash Sale",
              //             style: TextStyle(fontSize: 15),
              //           ),
              //         ),
              //       ),
                    // Tab(
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       "Friendly",
                    //       style: TextStyle(fontSize: 10),
                    //     ),
                    //   ),
                    // ),
                    // Tab(
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       "Bartering",
                    //       style: TextStyle(fontSize: 10),
                    //     ),
                    //   ),
                    // ),
                    // Tab(
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       "Donate",
                    //       style: TextStyle(fontSize: 15),
                    //     ),
                    //   ),
                    // ),
                  //]),
          //   ),
          // ),
          // Expanded(
          //   flex: 1,
          //   child: TabBarView(
          //     // Tab Bar View
          //     physics: BouncingScrollPhysics(),

          //     children: <Widget>[
          //       FreshSale(),
          //       //Friendly(),
          //       //Bartering(),
          //       //Donate(),
          //       //Donate()
          //     ],
          //   ),
          // ),
      //   ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color(0xff62319E),
      //   foregroundColor: Color(0xff62319E),
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      //   onPressed: () {
      //
      //     // Navigator.pushReplacement(
      //     //   context,
      //     //   CupertinoPageRoute(
      //     //     builder: (context) {
      //     //       return GetPostImage();
      //     //     },
      //     //   ),
      //     // );
      //
      //   },
      // ),
    );
  }
}
