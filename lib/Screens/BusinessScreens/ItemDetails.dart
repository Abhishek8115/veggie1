import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  @override
  _ItemDetailState createState() => _ItemDetailState();
}
Size size;
class _ItemDetailState extends State<ItemDetail> {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar:AppBar(),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              height: size.height*0.3,
              width: size.width*1,
              child: ClipRect(
                child: Image.asset("assets/burger.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(size.width*0.04, 0, 0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                            child: Container(
                              height: size.height*0.06,
                              //color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Burger ",
                                maxLines:2,
                                style: TextStyle(fontSize:25,fontWeight: FontWeight.w500),),
                              ),
                            ),
              ),
            ),
                        Padding(
                         padding: EdgeInsets.fromLTRB(size.width*0.04, 0, 0, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text.rich(TextSpan(
                      text: '\u20b9 200',
                      style: TextStyle(
                                fontSize: size.height*0.03,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                      )
                    ),),
                    
                    Text("\u20b9 100", style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600, 
                      fontSize: size.height*0.04)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(size.width*0.04, 0, 0, 0),
                          child: Text("Best before March 15, 2021", style: TextStyle(color: Colors.black54)),
                        ),
                        SizedBox(
                          height: size.height*0.1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.add, color: Colors.purple), onPressed:(){}),
                            Text("1", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 30)),
                            IconButton(icon: Icon(Icons.remove, color: Colors.purple), onPressed:(){})
                          ],
                        ),
                        SizedBox(
                          height: size.height*0.32
                        ),
                        FlatButton(
                          splashColor: Colors.purple[200],
                            height: size.height*0.06,
                            color: Colors.purple,
                            onPressed: (){},
                            child: Text("Add to cart",  style: TextStyle(color: Colors.white))
                          )
          ]
        ),
      )
    );
  }
}