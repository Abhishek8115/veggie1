import 'dart:convert';
import 'dart:async';
import 'cache.dart';
import 'server.dart';
import 'widgets.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import 'live-track.dart';
import 'payment.dart';

int rating = 0;
CustomerOrder globalOrder;

class OrderDetails extends StatefulWidget {
  final CustomerOrder order;
  OrderDetails({@required this.order});
  @override
  _OrderDetailsState createState() => _OrderDetailsState(this.order.rated);
}

class _OrderDetailsState extends State<OrderDetails> {
  bool initialized;
  _OrderDetailsState(bool rated) {
    initialized = rated;
  }
  @override
  Widget build(BuildContext context) {
    globalOrder = widget.order;
    var scaffold = Scaffold(
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
            title: Text('Order Details',
                style: TextStyle(color: Cache.appBarActionsColor)),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.call, color: Cache.appBarActionsColor),
                  onPressed: () {
                    launch('tel://' + widget.order.vendorId);
                  })
            ]),
        body: ListView(children: <Widget>[
          Padding(padding: EdgeInsets.all(8), child: null),
          Row(
            children: <Widget>[
              Text('Order Id : ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.order.orderId),
            ],
          ),
          Row(
            children: <Widget>[
              Text('Total : ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(Cache.currency + ' ' + widget.order.total),
            ],
          ),
          Row(
            children: <Widget>[
              Text('Payment : ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.order.payment),
            ],
          ),
          Row(
            children: <Widget>[
              Text('Status : ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.order.status),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Date : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.order.date),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Time : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.order.time),
            ],
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(
              'Address : ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(widget.order.deliveryAddress)),
          ]),
          widget.order.notes.trim().length == 0
              ? Padding(padding: EdgeInsets.all(0))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Text(
                        'Notes : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(widget.order.notes))
                    ]),
          widget.order.reasonOfCancellation.length == 0
              ? Padding(padding: EdgeInsets.all(0))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Text(
                        'Reason Of Cancellation : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text(widget.order.reasonOfCancellation))
                    ]),
          Padding(padding: EdgeInsets.all(4)),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.delivery_dining),
            title: Text('Delivery Charge'),
            trailing: Card(
              elevation: 0,
              color: Colors.orange,
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    Cache.currency + ' ' + widget.order.deliveryCharge,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Service Charge + GST'),
            trailing: Card(
              elevation: 0,
              color: Colors.orange,
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    Cache.currency + ' ' + widget.order.serviceCharge,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
          Divider(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.order.items
                .map((e) => ListTile(
                    leading: InkWell(
                        child: ClipRRect(
                            child: FadeInImage.assetNetwork(
                              image: s3Domain + e.itemId,
                              placeholder: 'assets/no-image.png',
                              height: 64,
                              width: 64,
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowImage(
                                        itemId: e.itemId,
                                        description: '',
                                        header: e.header,
                                      )));
                        }),
                    isThreeLine: true,
                    title: Text(
                      e.header,
                    ),
                    subtitle: Text(e.details),
                    trailing: Card(
                      elevation: 0,
                      color: Colors.orange,
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            Cache.currency + ' ' + e.price,
                            style: TextStyle(color: Colors.white),
                          )),
                    )))
                .toList(),
          ),
          Divider(),
          widget.order.couponCode != null
              ? ListTile(
                  leading: Card(
                    child: Padding(
                        child: Text('%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        padding: EdgeInsets.all(16)),
                    color: Colors.green,
                    shape: CircleBorder(),
                  ),
                  title: Text('Coupon Applied'),
                  subtitle: Text(widget.order.couponCode),
                  trailing: Card(
                    elevation: 0,
                    color: Colors.green,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          '- ' +
                              Cache.currency +
                              ' ' +
                              widget.order.couponDiscount.toStringAsFixed(2),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                )
              : Padding(padding: EdgeInsets.all(0)),
          (widget.order.status == 'Cancelled' ||
                  widget.order.status == 'Delivered')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      child: Text(
                        'Order ' + widget.order.status,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                    widget.order.status == 'Delivered' &&
                            widget.order.payment == 'Pending'
                        ? FlatButton(
                            onPressed: () {
                              payOnline();
                            },
                            color: Colors.green,
                            child: Text('Pay Now',
                                style: TextStyle(color: Colors.white)))
                        : Card()
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SimpleBtn(
                        backColor: Cache.appBarColor,
                        onPressed: () async {
                          await cancelOrder();
                          setState(() {});
                        },
                        child: Text('Cancel')),
                    widget.order.payment == 'Pending'
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                onPressed: () {
                                  payOnline();
                                },
                                color: Colors.green,
                                child: Text('Pay Now',
                                    style: TextStyle(color: Colors.white))),
                          )
                        : Card()
                  ],
                ), widget.order.status != 'Accepted'? Padding(padding: EdgeInsets.all(0)) : 
          FlatButton(color: Colors.green, 
              child: Row(mainAxisSize: MainAxisSize.min, 
                children: [
                  Icon(Icons.location_pin, color: Colors.white),
                  Padding(padding: EdgeInsets.all(4)),
                  Text('Start Tracking', style: TextStyle(color: Colors.white)),
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LiveTracker(orderId: widget.order.orderId)));
              })
        ]));
    if (!initialized) {
      initialized = true;
      if (widget.order.status == 'Delivered') {
        new Timer(Duration(seconds: 1), () {
          Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xB0000000),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your Feedback is Valuable',
                    style: TextStyle(color: Colors.white)),
                Rating(),
              ],
            ),
          ));
        });
      }
    }
    return scaffold;
  }

  Future payOnline() async {
    showDialog(context: context, builder: (context) => Pending());
    var response = await http
        .post('https://www.archerstack.com/payments/prod/pay-online', body: {
      "amount": widget.order.total,
      "customerName": customerName,
      "customerId": id,
      "mobile": widget.order.mobile,
    });
    if (response.statusCode != 200) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => MessageDialog(message: response.body));
      return;
    }
    var response1 = await http.post(
        'https://www.archerstack.com/payments/prod/create-payment-link',
        body: {"paymentId": response.body, "orderId": widget.order.orderId});
    if (response1.statusCode != 200) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => MessageDialog(message: response.body));
      return;
    }
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentView(url: response1.body, data: null)));
  }

  Future cancelOrder() async {
    var reason = TextEditingController();
    bool proceed = false;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              titlePadding: EdgeInsets.all(0),
              title: Container(
                  padding: EdgeInsets.all(8),
                  child: Text('Reason to cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                  color: Cache.appBarColor),
              content: Container(
                width: 200,
                height: 100,
                child: TextField(
                  controller: reason,
                  maxLines: 8,
                  decoration: InputDecoration(
                      labelText: '', border: OutlineInputBorder()),
                ),
              ),
              actions: [
                FlatButton(
                  color: Colors.transparent,
                  child: Text('Proceed', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    proceed = true;
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
                FlatButton(
                  color: Colors.transparent,
                  child: Text('Cancel without reason',
                      style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    reason.clear();
                    proceed = true;
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                ),
              ],
            ));
    if (!proceed) return;
    var response = await postMap(
        '/customer/cancel-order',
        {
          'customerId': id,
          'password': password,
          'orderId': widget.order.orderId,
          'reason': reason.text.trim(),
        },
        context);
    if (response.statusCode == 200) {
      setState(() {
        widget.order.status = 'Cancelled';
      });
    }
  }
}

Future saveRating(int rating, BuildContext context) async {
  List<String> itemIds = globalOrder.items.map((item) => item.itemId).toList();
  var response = await postMap(
      '/customer/rate-order',
      {
        'customerId': id,
        'password': password,
        'orderId': globalOrder.orderId,
        'items': json.encode(itemIds),
        'rating': rating.toString()
      },
      context);
  if (response.statusCode == 200) {
    globalOrder.rated = true;
  }
}

class Rating extends StatefulWidget {
  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: rating >= 1 ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              saveRating(1, context);
              setState(() {
                rating = 1;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: rating >= 2 ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              saveRating(2, context);
              setState(() {
                rating = 2;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: rating >= 3 ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              saveRating(3, context);
              setState(() {
                rating = 3;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: rating >= 4 ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              saveRating(4, context);
              setState(() {
                rating = 4;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: rating >= 5 ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              saveRating(5, context);
              setState(() {
                rating = 5;
              });
            },
          )
        ],
      ),
    ]);
  }
}
