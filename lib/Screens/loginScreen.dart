import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swap/Screens/landing_page.dart';
import 'package:swap/Screens/signup.dart';
import 'package:swap/Screens/Check.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin{

  var _razorpay = Razorpay();
  AnimationController _animationController;
  var data;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<String> getData(String username, String password) async {
    final response = await http.post('https://foodswap-backend.herokuapp.com/login',
        headers: {"Content-Type": "application/json"},
        body: convert.jsonEncode({"email": username, "password": password}));
    print('response: ${response.statusCode}');
  
    if (response.statusCode == 200) {
      print('Success');
      return "success!";
    } else if (response.statusCode == 400) {
      print(response.statusCode);
      return "failure";
    }
    return 'error';
  }

   @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //_razorpay.clear(); // Removes all listeners
    _animationController.dispose();
  }
  var options;
  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // options = {
    //   'key': 'rzp_test_1ns0ChyiK9yBT1',
    //   'amount': 50000, //in the smallest currency sub-unit.
    //   'name': 'Laxman private limited',
    //   'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
    //   'description': 'Food Swap application for android as well as iOS',
    //   'timeout': 60, // in seconds
    //   'prefill': {
    //     'contact': '9123456789',
    //     'email': 'gaurav.kumar@example.com'
    //   }
    // };
    
    _animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    _animationController.repeat();
  }
  
// Future payRazor()async
// {
//   try{
//     _razorpay.open(options);
//   }catch(e){
//     debugPrint(e);
//   }
//   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// }
  // try{
  //   _razorpay.open(options);
  // }catch(e){
  //   debugPrint(e);
  // }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//   // Do something when payment succeeds
// }

// void _handlePaymentError(PaymentFailureResponse response) {
//   // Do something when payment fails
// }

// void _handleExternalWallet(ExternalWalletResponse response) {
//   // Do something when an external wallet is selected
// }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 50,),
          Center(
            child: Container(
              width: 150,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xffFFFFFF), width: 10),
                image: DecorationImage(
                  image: AssetImage("assets/food.png"),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0.0, 0.0),
            child: Center(
              child: Text('Log in', style: TextStyle(fontSize: 30.0, color: Colors.black , fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Center(
          //   child: Container(
          //     width: 150,
          //     height: 170,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(color: Color(0xffFFFFFF), width: 10),
          //       image: DecorationImage(
          //         image: AssetImage("assets/man.png"),
          //           fit: BoxFit.cover),
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Theme(
              data: ThemeData(
                primaryColor: Color(0xffFFFFFF),
                primaryColorDark: Color(0xffFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                    controller: username,
                    cursorColor: Color(0xff90E5BF),
                    decoration: InputDecoration(
                        filled: true,
                        hintText: "Email",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: GestureDetector(
                            child: Text(
                              " ",
                              style: TextStyle(
                                color: Color(0xff90E5BF),
                              ),
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        fillColor: Color(0xffFFFFFF),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(100.0),
                          ),
                        ))),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Theme(
              data: ThemeData(
                primaryColor: Color(0xffFFFFFF),
                primaryColorDark: Color(0xffFFFFFF),
              ),
              child: TextField(
                  obscureText: true,
                  controller: password,
                  cursorColor: Color(0xff90E5BF),
                  decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "Password",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          child: Text(
                            "Forgot?",
                            style: TextStyle(color: Color(0xff90E5BF)),
                          ),
                        ),
                      ),
                      fillColor: Color(0xffFFFFFF),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(100.0),
                        ),
                      ))),
            ),
          ),
          SizedBox(height: 40.0),
          InkWell(
            onTap: () async {

              print("hello");
              print("email: ${username.text}");
              print("password: ${password.text}");
              //String result = await getData(username.text, password.text);
              showGeneralDialog(
              barrierColor: Colors.black.withOpacity(0.5),
              transitionBuilder: (context, a1, a2, widget) {
                return Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                    title:Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        CircularProgressIndicator(
                          backgroundColor: Colors.indigo, 
                          valueColor: _animationController.drive(ColorTween(begin: Colors.indigo, end: Colors.deepPurple[100])),                  
                          strokeWidth: 6.0,
                        ),
                        SizedBox(width: size.width*0.1),
                        Text("Loading")
                      ]
                    )
                  ),
                  ),
                );
              },
              transitionDuration: Duration(milliseconds: 300),
              barrierDismissible: false,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {});
              //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LandingPage()), (Route<dynamic> route) => false);

              // print("hello");
              // print("email: ${username.text}");
              // print("password: ${password.text}");
              // String result = await getData(username.text, password.text);
              // if (result.contains("success!")) {
              //
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LandingPage()));
              // }
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 1.0),
                    color: Color(0xff62319E),
                    borderRadius: BorderRadius.circular(100.0)),
                child: Center(
                  child: Text('Log in',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat')),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          InkWell(
              onTap: ()async{
                // debugPrint("Function called");
                //  Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(
                //     builder: (context) => CheckRazor(),
                //   ),
                //   (Route<dynamic> route) => false);
                // return WebView(
                //   initialUrl: "https://medium.com/@naveenyadav4116/razorpay-integration-with-flutter-df9ecb8a810a",
                //   //onWebViewCreated:await payRazor(),
                // );
                // payRazor();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignUp()));


              },
              child: Text("SignUp")),


        ],
      ),
    );
  }
}
