import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:convert/convert.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool passwordSet = false;
  TextEditingController username = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordSet = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE9E9E9),
      appBar:AppBar(
        backgroundColor: Colors.purple,
        title: Text("Reset Password")
      ),
      body: passwordSet?
      Center(
        child:Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height*0.3,),
            Text("Password Changed", style: TextStyle(color: Colors.black54,fontSize: MediaQuery.of(context).size.height*0.035)),
            SizedBox(height: MediaQuery.of(context).size.height*0.02,),
            Icon(Icons.check_circle_outlined, color: Colors.greenAccent[400], size: MediaQuery.of(context).size.height*0.1)
          ]
        )
      ):
      Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height*0.1),
           Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey,
                primaryColorDark: Color(0xffFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                    controller: username,
                    cursorColor: Color(0xff90E5BF),
                    decoration: InputDecoration(
                    filled: true,
                    hintText: "mobile number",
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
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(100.0),
                      ),
                    )
                  )
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.04),
           Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey,
                primaryColorDark: Color(0xffFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                    controller: username,
                    cursorColor: Color(0xff90E5BF),
                    decoration: InputDecoration(
                    filled: true,
                    hintText: "new password",
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
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(100.0),
                      ),
                    )
                  )
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.04),
           Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey,
                primaryColorDark: Color(0xffFFFFFF),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                    controller: username,
                    cursorColor: Color(0xff90E5BF),
                    decoration: InputDecoration(
                    filled: true,
                    hintText: "old password",
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
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(100.0),
                      ),
                    )
                  )
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: MediaQuery.of(context).size.width*0.2),
            child: ButtonTheme(  
              buttonColor: Color(0xff62319E),                  
              height: MediaQuery.of(context).size.height*0.05,
              shape: RoundedRectangleBorder(borderRadius: Bord.erRadius.circular(30)),
              child: RaisedButton(
                child: Text("Change password", style :Text.  Style(color: Colors.white)),
                onPressed: ()async{
                  // http.Response response = await http.patch(
                  //   'https://food2swap.herokuapp.com/api/auth/6072a27393b8790015b04e2c/change_password',
                  //   body: {
                  //     "newPassword": "nyapassword",
                  //     "oldPassword": "puranaPassoword"
                  //   }
                  // );
                  setState(() {
                    passwordSet = true;
                  });
                //   Navigator.push(context,
                // MaterialPageRoute(builder: (context) => LoginPageNGO()));
                  print("Do nothing");}
              ),
            ),
          ), 
        ],
      ),
    );
  }
}
