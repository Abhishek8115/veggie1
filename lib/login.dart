import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'server.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'widgets.dart';
import 'cache.dart';
import 'home.dart';
import 'profile.dart';
import 'dart:async';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _email = new TextEditingController();
  List<TextEditingController> _otps = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  List<FocusNode> _nodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];
  String emailErrorText;
  bool showOtp = false;
  bool checkingLoggedIn = true;
  ImageProvider logo = AssetImage('assets/logo.png');
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Widget container = Scaffold(
        backgroundColor: Cache.loginBackgroundColor,
        body: Center(
            child: Container(
          width: (screenWidth > 480 ? 360 : screenWidth),
          child: ListView(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(8)),
              Center(
                  child: Image(
                      image: logo, height: 128, width: 128, fit: BoxFit.fill)),
              Padding(padding: EdgeInsets.all(4), child: null),
              Padding(padding: EdgeInsets.all(40), child: null),
              Text('Sign Up / Log In',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 18, color: Cache.appBarActionsColor)),
              Padding(padding: EdgeInsets.all(4), child: null),
              Padding(padding: EdgeInsets.all(10), child: null),
              checkingLoggedIn
                  ? Pending()
                  : (!showOtp)
                      ? Container(
                          padding: EdgeInsets.all(10),
                          child: TextField(
                            onTap: () {
                              setState(() {
                                emailErrorText = null;
                              });
                            },
                            controller: _email,
                            decoration: InputDecoration(
                                errorText: emailErrorText,
                                errorStyle: TextStyle(color: Colors.red),
                                hintText: 'Email Id',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Cache.appBarActionsColor),
                                    borderRadius: BorderRadius.circular(4)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(4))),
                            textInputAction: TextInputAction.done,
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.all(5),
                                  width: 40,
                                  child: TextFormField(
                                    decoration:
                                        InputDecoration(counterText: ''),
                                    focusNode: _nodes[0],
                                    controller: _otps[0],
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      if (new RegExp(r'^[0-9]+$')
                                          .hasMatch(_otps[0].text))
                                        FocusScope.of(context)
                                            .requestFocus(_nodes[1]);
                                    },
                                    maxLength: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Cache.appBarActionsColor,
                                        fontSize: 20),
                                  )),
                              Container(
                                  width: 40,
                                  margin: EdgeInsets.all(5),
                                  child: TextFormField(
                                    decoration:
                                        InputDecoration(counterText: ''),
                                    focusNode: _nodes[1],
                                    controller: _otps[1],
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      if (new RegExp(r'^[0-9]+$')
                                          .hasMatch(_otps[1].text))
                                        FocusScope.of(context)
                                            .requestFocus(_nodes[2]);
                                    },
                                    maxLength: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Cache.appBarActionsColor,
                                        fontSize: 20),
                                  )),
                              Container(
                                  margin: EdgeInsets.all(5),
                                  width: 40,
                                  child: TextFormField(
                                    decoration:
                                        InputDecoration(counterText: ''),
                                    focusNode: _nodes[2],
                                    controller: _otps[2],
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {
                                      if (new RegExp(r'^[0-9]+$')
                                          .hasMatch(_otps[2].text))
                                        FocusScope.of(context)
                                            .requestFocus(_nodes[3]);
                                    },
                                    maxLength: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Cache.appBarActionsColor,
                                        fontSize: 20),
                                  )),
                              Container(
                                  margin: EdgeInsets.all(5),
                                  width: 40,
                                  child: TextFormField(
                                    decoration:
                                        InputDecoration(counterText: ''),
                                    focusNode: _nodes[3],
                                    controller: _otps[3],
                                    keyboardType: TextInputType.number,
                                    onChanged: (val) {},
                                    textInputAction: TextInputAction.done,
                                    maxLength: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Cache.appBarActionsColor,
                                        fontSize: 20),
                                  ))
                            ],
                          )),
              Padding(
                padding: EdgeInsets.all(8),
                child: SimpleBtn(
                    backColor: Cache.appBarColor,
                    onPressed: (showOtp)
                        ? () async {
                            await verifyOtp();
                          }
                        : () async {
                            await sendOtp();
                          },
                    child: Text(
                      (showOtp ? 'Verify Otp' : 'Next'),
                    )),
              ),
              Text("Or",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center),
              InkWell(
                  child: Text(
                    'Login as Guest',
                    style: TextStyle(
                        color: Colors.blue,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {logInAsGuest();
                  })
            ],
          ),
        )));
    Timer(Duration(seconds: 1), () {
      if (checkingLoggedIn) checkLoggedIn();
    });
    return container;
  }

  Future<void> logInAsGuest() async {
    showDialog(context: context, builder: (context) => Pending());
    var response = await postMap('/customer/guest-login', {}, context);
    if (response.statusCode == 200) {
      var decoded = json.decode(response.body);
      id = decoded['id'].toString();
      password = decoded['password'].toString();
      if (Cache.isWeb) {
        WebFile config = new WebFile('config');
        config.writeAsStringSync(
            id + '-' + (int.parse(password) * 1024).toString());
      } else {
        File config = new File(
            (await getApplicationDocumentsDirectory()).path + '/config');
        config.writeAsStringSync(
            id + '-' + (int.parse(password) * 1024).toString());
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) => MessageDialog(message: response.body));
      }
    }
  }

  Future<void> checkLoggedIn() async {
    try {
      String path = !Cache.isWeb
          ? ((await getApplicationDocumentsDirectory()).path + '/config')
          : "config";
      dynamic config = Cache.isWeb ? WebFile(path) : File(path);
      if (config.existsSync()) {
        List<String> credentials = config.readAsStringSync().split('-');
        id = credentials[0];
        password = ((int.parse(credentials[1])) / 1024).toInt().toString();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false);
      } else
        setState(() {
          checkingLoggedIn = false;
        });
    } catch (err) {
      print(err);
    }
    setState(() {
      checkingLoggedIn = false;
    });
  }

  Future sendOtp() async {
    int a = _email.text.lastIndexOf('@');
    int b = _email.text.lastIndexOf('.');
    if (a == 0) {
      setState(() {
        emailErrorText = "Invalid Email";
      });
      return;
    }
    if (b == _email.text.length - 1) {
      setState(() {
        emailErrorText = "Invalid Email";
      });
      return;
    }
    if (b - a <= 1) {
      setState(() {
        emailErrorText = "Invalid Email";
      });
      return;
    }
    var response = await postMap(
        '/customer/verify-contact', {'email': _email.text.trim()}, context);
    if (response.statusCode == 200) {
      setState(() {
        showOtp = true;
      });
    }
  }

  Future verifyOtp() async {
    String savedMobile = _email.text.trim();
    var random = Random();
    int newPass = 0;
    for (int i = 0; i < 8; i++) {
      newPass = newPass + ((random.nextInt(10) + 1) * pow(6, i));
    }
    String otp = _otps[0].text.trim() +
        _otps[1].text.trim() +
        _otps[2].text.trim() +
        _otps[3].text.trim();
    var response = await postMap(
        '/customer/verify-otp',
        {
          'email': _email.text.trim(),
          'otp': otp,
          'password': newPass.toString(),
          'vendorId': Cache.vendorId
        },
        context);
    if (response.statusCode == 200) {
      id = savedMobile;
      password = newPass.toString();
      if (response.body == 'New Member') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Profile(
                      newMember: true,
                    )),
            (Route<dynamic> route) => false);
      } else {
        if (Cache.isWeb) {
          WebFile config = new WebFile('config');
          config.writeAsStringSync(id + '-' + (newPass * 1024).toString());
        } else {
          File config = new File(
              (await getApplicationDocumentsDirectory()).path + '/config');
          config.writeAsStringSync(id + '-' + (newPass * 1024).toString());
        }
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (Route<dynamic> route) => false);
      }
    }
  }
}
