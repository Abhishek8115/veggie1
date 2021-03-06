import 'cache.dart';
import 'models.dart';
import 'package:flutter/material.dart';
import 'server.dart';
import 'widgets.dart';
import 'orderdetails.dart';
import 'dart:convert';

class Notifications extends StatefulWidget {
  final List<CtsNotification> notifications;
  Notifications({@required this.notifications});
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Cache.appBarActionsColor,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }),
        title: Text('Notifications',
            style: TextStyle(
              color: Cache.appBarActionsColor,
            )),
        centerTitle: false,
      ),
      body: widget.notifications.length == 0
          ? Center(
              child: Text('No Messages', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                return InkWell(
                  child: Card(
                      margin: EdgeInsets.all(5),
                      color: Colors.white,
                      elevation: 5,
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  widget.notifications[index].message,
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                                Padding(
                                  child: null,
                                  padding: EdgeInsets.all(10),
                                ),
                                Text(
                                  widget.notifications[index].time,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]))),
                  onTap: () {
                    if (widget.notifications[index].orderId.length < 20) return;
                    getOrderDetails(
                        widget.notifications[index].orderId, context);
                  },
                );
              }),
    );
  }

  Future getOrderDetails(String orderId, BuildContext context) async {
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
