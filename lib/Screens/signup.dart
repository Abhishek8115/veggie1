import 'dart:convert' ;
import 'package:flutter/material.dart';
import 'package:swap/Screens/phoneVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:swap/global.dart';
class SignUp extends StatefulWidget {
  final Function() updateParent;
  SignUp({this.updateParent});
  @override
  _SignUpState createState() => _SignUpState();
}
Size size;
 
class _SignUpState extends State<SignUp> with TickerProviderStateMixin{
  AnimationController _animationController;
  //int selectedIndex = -1;
  Future<String> pushData(
    
      String name, String email, String password, String phoneNo, int sIndex) async {
    String res = jsonEncode({
              	"name": "name", 
                "email": "abhitod7fewfewf66@gmail.com", 
                "password": "password",
                "contactNumber": "9352314227",
                "userType": sIndex==0?"business":"individual"
            }).toString();
    print(res);
    sIndex==0?print("Business"):print("Individual");
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
    final response = await http.post(
        'https://foodswap-backend.herokuapp.com/signup',
        headers: {"Content-Type": "application/json"},
        body:jsonEncode({
              	"name": "name", 
                "email": "abhitod766@gmail.com", 
                "password": "password",
                "contactNumber": "9358114227",
                "userType": sIndex==0?"business":"individual"
            }));
    Navigator.pop(context);
    print('response: ${response.statusCode}');
    if (response.statusCode == 200) {
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
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    _animationController.repeat();
  }
 
  bool error = false;

  TextEditingController name = TextEditingController();

  TextEditingController username = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Create Account",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            width: 240,
            child: Text(
              'Enter Your Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 20.0),
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
                        hintText: "Name",
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
          SizedBox(height: 10.0),
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
                    controller: phoneNo,
                    cursorColor: Color(0xff90E5BF),
                    decoration: InputDecoration(
                        filled: true,
                        hintText: "Phone Number",
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
          SizedBox(height: 10.0),
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
                    controller: email,
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
          SizedBox(height: 10.0),
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
                      fillColor: Color(0xffFFFFFF),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(100.0),
                        ),
                      ))),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Center(
                child: Text('Account Type', style: TextStyle(fontSize: 20))),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      print(selectedIndex);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(selectedIndex == index
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                      SizedBox(
                        width: 10,
                      ),
                      Text(index == 0 ? 'Business Owner' : index == 1 ?'User': 'NGO')
                    ],
                  ),
                );
              }),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xff62319E))),
            child: TextFormField(
                validator: (val) {
                  setState(() {
                    val.isEmpty ? error = true : error = false;
                  });
                  return null;
                },
                onTap: () {
                  setState(() {
                    error = false;
                  });
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText:
                      error ? "Description can't be empty" : "Description",
                  errorMaxLines: 3,
                  hintStyle: TextStyle(
                      color:
                          error ? Colors.deepOrangeAccent : Color(0xff62319E)),
                )),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              print(selectedIndex);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PhoneVerification()));
              // if(username.text.isEmpty||phoneNo.text.isEmpty||email.text.isEmpty||password.text.isEmpty||selectedIndex==-1)
              // {
              //   Toast.show(
              //     "Please Enter Valid Details", 
              //     context,
              //     duration: 1,
              //     gravity: 0,
              //     backgroundColor: Colors.indigo[200]
              //   );
              // }
              // //print(username.text.isEmpty);
              // print(username.text);
              // String result = await pushData(
              //     username.text, email.text, password.text, phoneNo.text, selectedIndex);
              // if (result.contains("success!")) {
              //   Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => PhoneVerification()));
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
                  child: Text('Sign Up',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat')),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Text(
          //   'By pressing JOIN US you agree to our terms & conditions',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(fontSize: 15.0, color: Colors.grey),
          // ),
        ],
      ),
    );
  }
}
