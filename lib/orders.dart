import 'dart:convert';
import 'server.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'orderdetails.dart';
import 'cache.dart';

class Orders extends StatelessWidget {
  final List<MiniOrder> orders;
  Orders({@required this.orders});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Your Orders',
            style: TextStyle(color: Cache.appBarActionsColor)),
        centerTitle: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Cache.appBarActionsColor),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ListView(
        children: orders.map((order) {
          return Card(
              child: ListTile(
                leading: Card(elevation: 0,shape: CircleBorder(), 
color: order.status=='Pending'? Colors.orange : order.status=='Cancelled'? Colors.red: order.status=='Accepted'?Colors.green[200] : Colors.green[600]
,child: Padding(padding: EdgeInsets.all(10), child: Text(order.status[0], textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 24, )))),
                title: Text(order.status),
                subtitle: Text(order.date + '\n' + order.time),
                trailing: Card(elevation: 0,
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(Cache.currency + ' ' + order.total,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                onTap: () {
                  getOrderDetails(order.orderId, context);
                },
              ),
              color: Colors.white);
        }).toList(),
      ),
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
